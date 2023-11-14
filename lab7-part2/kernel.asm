
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
8010002d:	b8 17 2b 10 80       	mov    $0x80102b17,%eax
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
80100046:	e8 c3 3d 00 00       	call   80103e0e <acquire>

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
8010007c:	e8 f2 3d 00 00       	call   80103e73 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 6e 3b 00 00       	call   80103bfa <acquiresleep>
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
801000ca:	e8 a4 3d 00 00       	call   80103e73 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 20 3b 00 00       	call   80103bfa <acquiresleep>
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
801000ea:	68 40 69 10 80       	push   $0x80106940
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 51 69 10 80       	push   $0x80106951
80100100:	68 20 a5 10 80       	push   $0x8010a520
80100105:	e8 c8 3b 00 00       	call   80103cd2 <initlock>
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
8010013a:	68 58 69 10 80       	push   $0x80106958
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 7f 3a 00 00       	call   80103bc7 <initsleeplock>
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
801001a8:	e8 d7 3a 00 00       	call   80103c84 <holdingsleep>
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
801001cb:	68 5f 69 10 80       	push   $0x8010695f
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
801001e4:	e8 9b 3a 00 00       	call   80103c84 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 50 3a 00 00       	call   80103c49 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100200:	e8 09 3c 00 00       	call   80103e0e <acquire>
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
8010024c:	e8 22 3c 00 00       	call   80103e73 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 66 69 10 80       	push   $0x80106966
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
8010028a:	e8 7f 3b 00 00       	call   80103e0e <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
8010029f:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 06 30 00 00       	call   801032b2 <myproc>
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
801002bf:	e8 90 34 00 00       	call   80103754 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 ef 10 80       	push   $0x8010ef20
801002d1:	e8 9d 3b 00 00       	call   80103e73 <release>
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
80100331:	e8 3d 3b 00 00       	call   80103e73 <release>
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
8010035a:	e8 cb 20 00 00       	call   8010242a <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 6d 69 10 80       	push   $0x8010696d
80100368:	e8 9a 02 00 00       	call   80100607 <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	push   0x8(%ebp)
80100373:	e8 8f 02 00 00       	call   80100607 <cprintf>
  cprintf("\n");
80100378:	c7 04 24 ab 73 10 80 	movl   $0x801073ab,(%esp)
8010037f:	e8 83 02 00 00       	call   80100607 <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 59 39 00 00       	call   80103ced <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
801003a5:	68 81 69 10 80       	push   $0x80106981
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
80100492:	68 85 69 10 80       	push   $0x80106985
80100497:	e8 ac fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010049c:	83 ec 04             	sub    $0x4,%esp
8010049f:	68 60 0e 00 00       	push   $0xe60
801004a4:	68 a0 80 0b 80       	push   $0x800b80a0
801004a9:	68 00 80 0b 80       	push   $0x800b8000
801004ae:	e8 7f 3a 00 00       	call   80103f32 <memmove>
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
801004cd:	e8 e8 39 00 00       	call   80103eba <memset>
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
801004fa:	e8 ae 4d 00 00       	call   801052ad <uartputc>
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
80100513:	e8 95 4d 00 00       	call   801052ad <uartputc>
80100518:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010051f:	e8 89 4d 00 00       	call   801052ad <uartputc>
80100524:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010052b:	e8 7d 4d 00 00       	call   801052ad <uartputc>
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
80100568:	0f b6 92 b0 69 10 80 	movzbl -0x7fef9650(%edx),%edx
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
801005c6:	e8 43 38 00 00       	call   80103e0e <acquire>
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
801005ed:	e8 81 38 00 00       	call   80103e73 <release>
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
80100634:	e8 d5 37 00 00       	call   80103e0e <acquire>
80100639:	83 c4 10             	add    $0x10,%esp
8010063c:	eb de                	jmp    8010061c <cprintf+0x15>
    panic("null fmt");
8010063e:	83 ec 0c             	sub    $0xc,%esp
80100641:	68 9f 69 10 80       	push   $0x8010699f
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
801006cd:	bb 98 69 10 80       	mov    $0x80106998,%ebx
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
80100729:	e8 45 37 00 00       	call   80103e73 <release>
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
80100744:	e8 c5 36 00 00       	call   80103e0e <acquire>
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
801007f2:	e8 c2 30 00 00       	call   801038b9 <wakeup>
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
8010086f:	e8 ff 35 00 00       	call   80103e73 <release>
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
80100883:	e8 ce 30 00 00       	call   80103956 <procdump>
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
80100890:	68 a8 69 10 80       	push   $0x801069a8
80100895:	68 20 ef 10 80       	push   $0x8010ef20
8010089a:	e8 33 34 00 00       	call   80103cd2 <initlock>

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
801008da:	e8 d3 29 00 00       	call   801032b2 <myproc>
801008df:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
801008e5:	e8 5e 1f 00 00       	call   80102848 <begin_op>

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
8010093d:	e8 80 1f 00 00       	call   801028c2 <end_op>
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
80100952:	e8 6b 1f 00 00       	call   801028c2 <end_op>
    cprintf("exec: fail\n");
80100957:	83 ec 0c             	sub    $0xc,%esp
8010095a:	68 c1 69 10 80       	push   $0x801069c1
8010095f:	e8 a3 fc ff ff       	call   80100607 <cprintf>
    return -1;
80100964:	83 c4 10             	add    $0x10,%esp
80100967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096c:	eb dc                	jmp    8010094a <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
8010096e:	e8 30 5d 00 00       	call   801066a3 <setupkvm>
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
80100a02:	e8 18 5b 00 00       	call   8010651f <allocuvm>
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
80100a34:	e8 89 59 00 00       	call   801063c2 <loaduvm>
80100a39:	83 c4 20             	add    $0x20,%esp
80100a3c:	85 c0                	test   %eax,%eax
80100a3e:	0f 89 4f ff ff ff    	jns    80100993 <exec+0xc5>
80100a44:	eb 44                	jmp    80100a8a <exec+0x1bc>
  iunlockput(ip);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	53                   	push   %ebx
80100a4a:	e8 c7 0c 00 00       	call   80101716 <iunlockput>
  end_op();
80100a4f:	e8 6e 1e 00 00       	call   801028c2 <end_op>
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
80100a71:	e8 a9 5a 00 00       	call   8010651f <allocuvm>
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
80100a9c:	e8 80 5b 00 00       	call   80106621 <freevm>
80100aa1:	83 c4 10             	add    $0x10,%esp
80100aa4:	e9 83 fe ff ff       	jmp    8010092c <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aa9:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100aaf:	83 ec 08             	sub    $0x8,%esp
80100ab2:	50                   	push   %eax
80100ab3:	57                   	push   %edi
80100ab4:	e8 6f 5c 00 00       	call   80106728 <clearpteu>
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
80100ae6:	e8 78 35 00 00       	call   80104063 <strlen>
80100aeb:	29 c6                	sub    %eax,%esi
80100aed:	83 ee 01             	sub    $0x1,%esi
80100af0:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100af3:	83 c4 04             	add    $0x4,%esp
80100af6:	ff 33                	push   (%ebx)
80100af8:	e8 66 35 00 00       	call   80104063 <strlen>
80100afd:	83 c0 01             	add    $0x1,%eax
80100b00:	50                   	push   %eax
80100b01:	ff 33                	push   (%ebx)
80100b03:	56                   	push   %esi
80100b04:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100b0a:	e8 ab 5d 00 00       	call   801068ba <copyout>
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
80100b6a:	e8 4b 5d 00 00       	call   801068ba <copyout>
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
80100ba7:	e8 7a 34 00 00       	call   80104026 <safestrcpy>
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
80100bd5:	e8 f3 55 00 00       	call   801061cd <switchuvm>
  freevm(oldpgdir);
80100bda:	89 1c 24             	mov    %ebx,(%esp)
80100bdd:	e8 3f 5a 00 00       	call   80106621 <freevm>
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
80100c09:	68 cd 69 10 80       	push   $0x801069cd
80100c0e:	68 60 ef 10 80       	push   $0x8010ef60
80100c13:	e8 ba 30 00 00       	call   80103cd2 <initlock>
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
80100c29:	e8 e0 31 00 00       	call   80103e0e <acquire>
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
80100c58:	e8 16 32 00 00       	call   80103e73 <release>
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
80100c6f:	e8 ff 31 00 00       	call   80103e73 <release>
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
80100c8d:	e8 7c 31 00 00       	call   80103e0e <acquire>
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
80100caa:	e8 c4 31 00 00       	call   80103e73 <release>
  return f;
}
80100caf:	89 d8                	mov    %ebx,%eax
80100cb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cb4:	c9                   	leave  
80100cb5:	c3                   	ret    
    panic("filedup");
80100cb6:	83 ec 0c             	sub    $0xc,%esp
80100cb9:	68 d4 69 10 80       	push   $0x801069d4
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
80100cd2:	e8 37 31 00 00       	call   80103e0e <acquire>
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
80100d23:	e8 4b 31 00 00       	call   80103e73 <release>

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
80100d38:	e8 0b 1b 00 00       	call   80102848 <begin_op>
    iput(ff.ip);
80100d3d:	83 ec 0c             	sub    $0xc,%esp
80100d40:	ff 75 f0             	push   -0x10(%ebp)
80100d43:	e8 2e 09 00 00       	call   80101676 <iput>
    end_op();
80100d48:	e8 75 1b 00 00       	call   801028c2 <end_op>
80100d4d:	83 c4 10             	add    $0x10,%esp
80100d50:	eb 1d                	jmp    80100d6f <fileclose+0xac>
    panic("fileclose");
80100d52:	83 ec 0c             	sub    $0xc,%esp
80100d55:	68 dc 69 10 80       	push   $0x801069dc
80100d5a:	e8 e9 f5 ff ff       	call   80100348 <panic>
    release(&ftable.lock);
80100d5f:	83 ec 0c             	sub    $0xc,%esp
80100d62:	68 60 ef 10 80       	push   $0x8010ef60
80100d67:	e8 07 31 00 00       	call   80103e73 <release>
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
80100d7f:	e8 6a 21 00 00       	call   80102eee <pipeclose>
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
80100e35:	e8 05 22 00 00       	call   8010303f <piperead>
80100e3a:	89 c6                	mov    %eax,%esi
80100e3c:	83 c4 10             	add    $0x10,%esp
80100e3f:	eb df                	jmp    80100e20 <fileread+0x50>
  panic("fileread");
80100e41:	83 ec 0c             	sub    $0xc,%esp
80100e44:	68 e6 69 10 80       	push   $0x801069e6
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
80100e90:	e8 e5 20 00 00       	call   80102f7a <pipewrite>
80100e95:	83 c4 10             	add    $0x10,%esp
80100e98:	e9 84 00 00 00       	jmp    80100f21 <filewrite+0xcc>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100e9d:	e8 a6 19 00 00       	call   80102848 <begin_op>
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
80100ed7:	e8 e6 19 00 00       	call   801028c2 <end_op>

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
80100f0a:	68 ef 69 10 80       	push   $0x801069ef
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
80100f31:	68 f5 69 10 80       	push   $0x801069f5
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
80100f81:	e8 ac 2f 00 00       	call   80103f32 <memmove>
80100f86:	83 c4 10             	add    $0x10,%esp
80100f89:	eb 17                	jmp    80100fa2 <skipelem+0x60>
  else {
    memmove(name, s, len);
80100f8b:	83 ec 04             	sub    $0x4,%esp
80100f8e:	57                   	push   %edi
80100f8f:	50                   	push   %eax
80100f90:	56                   	push   %esi
80100f91:	e8 9c 2f 00 00       	call   80103f32 <memmove>
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
80100fd6:	e8 df 2e 00 00       	call   80103eba <memset>
  log_write(bp);
80100fdb:	89 1c 24             	mov    %ebx,(%esp)
80100fde:	e8 8e 19 00 00       	call   80102971 <log_write>
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
80101045:	e8 27 19 00 00       	call   80102971 <log_write>
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
8010105f:	68 ff 69 10 80       	push   $0x801069ff
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
80101116:	68 12 6a 10 80       	push   $0x80106a12
8010111b:	e8 28 f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
80101120:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101123:	09 f1                	or     %esi,%ecx
80101125:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101128:	88 4c 17 5c          	mov    %cl,0x5c(%edi,%edx,1)
        log_write(bp);
8010112c:	83 ec 0c             	sub    $0xc,%esp
8010112f:	57                   	push   %edi
80101130:	e8 3c 18 00 00       	call   80102971 <log_write>
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
801011e0:	e8 8c 17 00 00       	call   80102971 <log_write>
801011e5:	83 c4 10             	add    $0x10,%esp
801011e8:	eb a8                	jmp    80101192 <bmap+0x41>
  panic("bmap: out of range");
801011ea:	83 ec 0c             	sub    $0xc,%esp
801011ed:	68 28 6a 10 80       	push   $0x80106a28
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
8010120a:	e8 ff 2b 00 00       	call   80103e0e <acquire>
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
80101251:	e8 1d 2c 00 00       	call   80103e73 <release>
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
80101287:	e8 e7 2b 00 00       	call   80103e73 <release>
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
8010129c:	68 3b 6a 10 80       	push   $0x80106a3b
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
801012c5:	e8 68 2c 00 00       	call   80103f32 <memmove>
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
801012e1:	68 4b 6a 10 80       	push   $0x80106a4b
801012e6:	68 60 f9 10 80       	push   $0x8010f960
801012eb:	e8 e2 29 00 00       	call   80103cd2 <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 52 6a 10 80       	push   $0x80106a52
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 a0 f9 10 80       	add    $0x8010f9a0,%eax
8010130f:	50                   	push   %eax
80101310:	e8 b2 28 00 00       	call   80103bc7 <initsleeplock>
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
8010135a:	68 b8 6a 10 80       	push   $0x80106ab8
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
801013cd:	68 58 6a 10 80       	push   $0x80106a58
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 d6 2a 00 00       	call   80103eba <memset>
      dip->type = type;
801013e4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013e8:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013eb:	89 34 24             	mov    %esi,(%esp)
801013ee:	e8 7e 15 00 00       	call   80102971 <log_write>
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
8010146e:	e8 bf 2a 00 00       	call   80103f32 <memmove>
  log_write(bp);
80101473:	89 34 24             	mov    %esi,(%esp)
80101476:	e8 f6 14 00 00       	call   80102971 <log_write>
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
8010154e:	e8 bb 28 00 00       	call   80103e0e <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101563:	e8 0b 29 00 00       	call   80103e73 <release>
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
80101588:	e8 6d 26 00 00       	call   80103bfa <acquiresleep>
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
801015a0:	68 6a 6a 10 80       	push   $0x80106a6a
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
80101602:	e8 2b 29 00 00       	call   80103f32 <memmove>
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
80101627:	68 70 6a 10 80       	push   $0x80106a70
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
80101644:	e8 3b 26 00 00       	call   80103c84 <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 ea 25 00 00       	call   80103c49 <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 7f 6a 10 80       	push   $0x80106a7f
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
80101686:	e8 6f 25 00 00       	call   80103bfa <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 a5 25 00 00       	call   80103c49 <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016ab:	e8 5e 27 00 00       	call   80103e0e <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016c0:	e8 ae 27 00 00       	call   80103e73 <release>
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
801016d8:	e8 31 27 00 00       	call   80103e0e <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016e7:	e8 87 27 00 00       	call   80103e73 <release>
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
80101818:	e8 15 27 00 00       	call   80103f32 <memmove>
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
80101915:	e8 18 26 00 00       	call   80103f32 <memmove>
    log_write(bp);
8010191a:	89 34 24             	mov    %esi,(%esp)
8010191d:	e8 4f 10 00 00       	call   80102971 <log_write>
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
80101998:	e8 01 26 00 00       	call   80103f9e <strncmp>
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
801019bf:	68 87 6a 10 80       	push   $0x80106a87
801019c4:	e8 7f e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c9:	83 ec 0c             	sub    $0xc,%esp
801019cc:	68 99 6a 10 80       	push   $0x80106a99
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
80101a49:	e8 64 18 00 00       	call   801032b2 <myproc>
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
80101b7e:	68 a8 6a 10 80       	push   $0x80106aa8
80101b83:	e8 c0 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b88:	83 ec 04             	sub    $0x4,%esp
80101b8b:	6a 0e                	push   $0xe
80101b8d:	57                   	push   %edi
80101b8e:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b91:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b94:	50                   	push   %eax
80101b95:	e8 43 24 00 00       	call   80103fdd <strncpy>
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
80101bc3:	68 a4 71 10 80       	push   $0x801071a4
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
80101cc5:	68 0b 6b 10 80       	push   $0x80106b0b
80101cca:	e8 79 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101ccf:	83 ec 0c             	sub    $0xc,%esp
80101cd2:	68 14 6b 10 80       	push   $0x80106b14
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
80101cef:	68 26 6b 10 80       	push   $0x80106b26
80101cf4:	68 00 16 11 80       	push   $0x80111600
80101cf9:	e8 d4 1f 00 00       	call   80103cd2 <initlock>
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
80101d69:	e8 a0 20 00 00       	call   80103e0e <acquire>

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
80101d98:	e8 1c 1b 00 00       	call   801038b9 <wakeup>

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
80101db6:	e8 b8 20 00 00       	call   80103e73 <release>
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
80101dcd:	e8 a1 20 00 00       	call   80103e73 <release>
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
80101e05:	e8 7a 1e 00 00       	call   80103c84 <holdingsleep>
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
80101e32:	e8 d7 1f 00 00       	call   80103e0e <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e37:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e3e:	83 c4 10             	add    $0x10,%esp
80101e41:	ba e4 15 11 80       	mov    $0x801115e4,%edx
80101e46:	eb 2a                	jmp    80101e72 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e48:	83 ec 0c             	sub    $0xc,%esp
80101e4b:	68 2a 6b 10 80       	push   $0x80106b2a
80101e50:	e8 f3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e55:	83 ec 0c             	sub    $0xc,%esp
80101e58:	68 40 6b 10 80       	push   $0x80106b40
80101e5d:	e8 e6 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e62:	83 ec 0c             	sub    $0xc,%esp
80101e65:	68 55 6b 10 80       	push   $0x80106b55
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
80101e94:	e8 bb 18 00 00       	call   80103754 <sleep>
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
80101eae:	e8 c0 1f 00 00       	call   80103e73 <release>
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
80101f22:	68 74 6b 10 80       	push   $0x80106b74
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
80101fc6:	e8 ef 1e 00 00       	call   80103eba <memset>

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
80101ff5:	68 a8 6b 10 80       	push   $0x80106ba8
80101ffa:	e8 49 e3 ff ff       	call   80100348 <panic>
    panic("kfree");
80101fff:	83 ec 0c             	sub    $0xc,%esp
80102002:	68 36 6c 10 80       	push   $0x80106c36
80102007:	e8 3c e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200c:	83 ec 0c             	sub    $0xc,%esp
8010200f:	68 40 16 11 80       	push   $0x80111640
80102014:	e8 f5 1d 00 00       	call   80103e0e <acquire>
80102019:	83 c4 10             	add    $0x10,%esp
8010201c:	eb b9                	jmp    80101fd7 <kfree+0x4b>
    release(&kmem.lock);
8010201e:	83 ec 0c             	sub    $0xc,%esp
80102021:	68 40 16 11 80       	push   $0x80111640
80102026:	e8 48 1e 00 00       	call   80103e73 <release>
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
8010204e:	68 3c 6c 10 80       	push   $0x80106c3c
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
8010207d:	68 46 6c 10 80       	push   $0x80106c46
80102082:	68 40 16 11 80       	push   $0x80111640
80102087:	e8 46 1c 00 00       	call   80103cd2 <initlock>
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
80102102:	e8 07 1d 00 00       	call   80103e0e <acquire>
80102107:	83 c4 10             	add    $0x10,%esp
8010210a:	eb cd                	jmp    801020d9 <kalloc+0x10>
    release(&kmem.lock);
8010210c:	83 ec 0c             	sub    $0xc,%esp
8010210f:	68 40 16 11 80       	push   $0x80111640
80102114:	e8 5a 1d 00 00       	call   80103e73 <release>
80102119:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010211c:	eb d5                	jmp    801020f3 <kalloc+0x2a>

8010211e <kphysicalpagefree>:

int kphysicalpagefree(int ppn) {
8010211e:	55                   	push   %ebp
8010211f:	89 e5                	mov    %esp,%ebp
80102121:	53                   	push   %ebx
80102122:	83 ec 04             	sub    $0x4,%esp
80102125:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(kmem.use_lock) {
80102128:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
8010212f:	75 21                	jne    80102152 <kphysicalpagefree+0x34>
    acquire(&kmem.lock);
  }
  // do stuff
  struct run *r;
  r = kmem.freelist;
80102131:	a1 78 16 11 80       	mov    0x80111678,%eax
  while (r) {
80102136:	85 c0                	test   %eax,%eax
80102138:	74 5c                	je     80102196 <kphysicalpagefree+0x78>
    if (a < (void*) KERNBASE)
8010213a:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
8010213f:	76 23                	jbe    80102164 <kphysicalpagefree+0x46>
    return (uint)a - KERNBASE;
80102141:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
    // cprintf("r = %d\n", (int)(V2P(r) >> 12));
    
    if ( (int)(V2P(r) >> 12) == ppn) {
80102147:	c1 ea 0c             	shr    $0xc,%edx
8010214a:	39 da                	cmp    %ebx,%edx
8010214c:	74 23                	je     80102171 <kphysicalpagefree+0x53>
        release(&kmem.lock);
      }
      return 1;
    }
    
    r = r->next;
8010214e:	8b 00                	mov    (%eax),%eax
80102150:	eb e4                	jmp    80102136 <kphysicalpagefree+0x18>
    acquire(&kmem.lock);
80102152:	83 ec 0c             	sub    $0xc,%esp
80102155:	68 40 16 11 80       	push   $0x80111640
8010215a:	e8 af 1c 00 00       	call   80103e0e <acquire>
8010215f:	83 c4 10             	add    $0x10,%esp
80102162:	eb cd                	jmp    80102131 <kphysicalpagefree+0x13>
        panic("V2P on address < KERNBASE "
80102164:	83 ec 0c             	sub    $0xc,%esp
80102167:	68 a8 6b 10 80       	push   $0x80106ba8
8010216c:	e8 d7 e1 ff ff       	call   80100348 <panic>
      if(kmem.use_lock) {
80102171:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80102178:	75 0a                	jne    80102184 <kphysicalpagefree+0x66>
      return 1;
8010217a:	b8 01 00 00 00       	mov    $0x1,%eax
  }
  if(kmem.use_lock) {
    release(&kmem.lock);
  }
  return 0;
8010217f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102182:	c9                   	leave  
80102183:	c3                   	ret    
        release(&kmem.lock);
80102184:	83 ec 0c             	sub    $0xc,%esp
80102187:	68 40 16 11 80       	push   $0x80111640
8010218c:	e8 e2 1c 00 00       	call   80103e73 <release>
80102191:	83 c4 10             	add    $0x10,%esp
80102194:	eb e4                	jmp    8010217a <kphysicalpagefree+0x5c>
  if(kmem.use_lock) {
80102196:	a1 74 16 11 80       	mov    0x80111674,%eax
8010219b:	85 c0                	test   %eax,%eax
8010219d:	74 e0                	je     8010217f <kphysicalpagefree+0x61>
    release(&kmem.lock);
8010219f:	83 ec 0c             	sub    $0xc,%esp
801021a2:	68 40 16 11 80       	push   $0x80111640
801021a7:	e8 c7 1c 00 00       	call   80103e73 <release>
801021ac:	83 c4 10             	add    $0x10,%esp
  return 0;
801021af:	b8 00 00 00 00       	mov    $0x0,%eax
801021b4:	eb c9                	jmp    8010217f <kphysicalpagefree+0x61>

801021b6 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021b6:	ba 64 00 00 00       	mov    $0x64,%edx
801021bb:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801021bc:	a8 01                	test   $0x1,%al
801021be:	0f 84 b4 00 00 00    	je     80102278 <kbdgetc+0xc2>
801021c4:	ba 60 00 00 00       	mov    $0x60,%edx
801021c9:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801021ca:	0f b6 c8             	movzbl %al,%ecx

  if(data == 0xE0){
801021cd:	3c e0                	cmp    $0xe0,%al
801021cf:	74 61                	je     80102232 <kbdgetc+0x7c>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801021d1:	84 c0                	test   %al,%al
801021d3:	78 6a                	js     8010223f <kbdgetc+0x89>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801021d5:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
801021db:	f6 c2 40             	test   $0x40,%dl
801021de:	74 0f                	je     801021ef <kbdgetc+0x39>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801021e0:	83 c8 80             	or     $0xffffff80,%eax
801021e3:	0f b6 c8             	movzbl %al,%ecx
    shift &= ~E0ESC;
801021e6:	83 e2 bf             	and    $0xffffffbf,%edx
801021e9:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  }

  shift |= shiftcode[data];
801021ef:	0f b6 91 80 6d 10 80 	movzbl -0x7fef9280(%ecx),%edx
801021f6:	0b 15 7c 16 11 80    	or     0x8011167c,%edx
801021fc:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  shift ^= togglecode[data];
80102202:	0f b6 81 80 6c 10 80 	movzbl -0x7fef9380(%ecx),%eax
80102209:	31 c2                	xor    %eax,%edx
8010220b:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
80102211:	89 d0                	mov    %edx,%eax
80102213:	83 e0 03             	and    $0x3,%eax
80102216:	8b 04 85 60 6c 10 80 	mov    -0x7fef93a0(,%eax,4),%eax
8010221d:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102221:	f6 c2 08             	test   $0x8,%dl
80102224:	74 57                	je     8010227d <kbdgetc+0xc7>
    if('a' <= c && c <= 'z')
80102226:	8d 50 9f             	lea    -0x61(%eax),%edx
80102229:	83 fa 19             	cmp    $0x19,%edx
8010222c:	77 3e                	ja     8010226c <kbdgetc+0xb6>
      c += 'A' - 'a';
8010222e:	83 e8 20             	sub    $0x20,%eax
80102231:	c3                   	ret    
    shift |= E0ESC;
80102232:	83 0d 7c 16 11 80 40 	orl    $0x40,0x8011167c
    return 0;
80102239:	b8 00 00 00 00       	mov    $0x0,%eax
8010223e:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010223f:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
80102245:	f6 c2 40             	test   $0x40,%dl
80102248:	75 05                	jne    8010224f <kbdgetc+0x99>
8010224a:	89 c1                	mov    %eax,%ecx
8010224c:	83 e1 7f             	and    $0x7f,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
8010224f:	0f b6 81 80 6d 10 80 	movzbl -0x7fef9280(%ecx),%eax
80102256:	83 c8 40             	or     $0x40,%eax
80102259:	0f b6 c0             	movzbl %al,%eax
8010225c:	f7 d0                	not    %eax
8010225e:	21 c2                	and    %eax,%edx
80102260:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
    return 0;
80102266:	b8 00 00 00 00       	mov    $0x0,%eax
8010226b:	c3                   	ret    
    else if('A' <= c && c <= 'Z')
8010226c:	8d 50 bf             	lea    -0x41(%eax),%edx
8010226f:	83 fa 19             	cmp    $0x19,%edx
80102272:	77 09                	ja     8010227d <kbdgetc+0xc7>
      c += 'a' - 'A';
80102274:	83 c0 20             	add    $0x20,%eax
  }
  return c;
80102277:	c3                   	ret    
    return -1;
80102278:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010227d:	c3                   	ret    

8010227e <kbdintr>:

void
kbdintr(void)
{
8010227e:	55                   	push   %ebp
8010227f:	89 e5                	mov    %esp,%ebp
80102281:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102284:	68 b6 21 10 80       	push   $0x801021b6
80102289:	e8 a5 e4 ff ff       	call   80100733 <consoleintr>
}
8010228e:	83 c4 10             	add    $0x10,%esp
80102291:	c9                   	leave  
80102292:	c3                   	ret    

80102293 <shutdown>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102293:	b8 00 00 00 00       	mov    $0x0,%eax
80102298:	ba 01 05 00 00       	mov    $0x501,%edx
8010229d:	ee                   	out    %al,(%dx)
  /*
     This only works in QEMU and assumes QEMU was run 
     with -device isa-debug-exit
   */
  outb(0x501, 0x0);
}
8010229e:	c3                   	ret    

8010229f <lapicw>:

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010229f:	8b 0d 80 16 11 80    	mov    0x80111680,%ecx
801022a5:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801022a8:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801022aa:	a1 80 16 11 80       	mov    0x80111680,%eax
801022af:	8b 40 20             	mov    0x20(%eax),%eax
}
801022b2:	c3                   	ret    

801022b3 <cmos_read>:
801022b3:	ba 70 00 00 00       	mov    $0x70,%edx
801022b8:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022b9:	ba 71 00 00 00       	mov    $0x71,%edx
801022be:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801022bf:	0f b6 c0             	movzbl %al,%eax
}
801022c2:	c3                   	ret    

801022c3 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801022c3:	55                   	push   %ebp
801022c4:	89 e5                	mov    %esp,%ebp
801022c6:	53                   	push   %ebx
801022c7:	83 ec 04             	sub    $0x4,%esp
801022ca:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801022cc:	b8 00 00 00 00       	mov    $0x0,%eax
801022d1:	e8 dd ff ff ff       	call   801022b3 <cmos_read>
801022d6:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801022d8:	b8 02 00 00 00       	mov    $0x2,%eax
801022dd:	e8 d1 ff ff ff       	call   801022b3 <cmos_read>
801022e2:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801022e5:	b8 04 00 00 00       	mov    $0x4,%eax
801022ea:	e8 c4 ff ff ff       	call   801022b3 <cmos_read>
801022ef:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801022f2:	b8 07 00 00 00       	mov    $0x7,%eax
801022f7:	e8 b7 ff ff ff       	call   801022b3 <cmos_read>
801022fc:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801022ff:	b8 08 00 00 00       	mov    $0x8,%eax
80102304:	e8 aa ff ff ff       	call   801022b3 <cmos_read>
80102309:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
8010230c:	b8 09 00 00 00       	mov    $0x9,%eax
80102311:	e8 9d ff ff ff       	call   801022b3 <cmos_read>
80102316:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102319:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010231c:	c9                   	leave  
8010231d:	c3                   	ret    

8010231e <lapicinit>:
  if(!lapic)
8010231e:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
80102325:	0f 84 fe 00 00 00    	je     80102429 <lapicinit+0x10b>
{
8010232b:	55                   	push   %ebp
8010232c:	89 e5                	mov    %esp,%ebp
8010232e:	83 ec 08             	sub    $0x8,%esp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102331:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102336:	b8 3c 00 00 00       	mov    $0x3c,%eax
8010233b:	e8 5f ff ff ff       	call   8010229f <lapicw>
  lapicw(TDCR, X1);
80102340:	ba 0b 00 00 00       	mov    $0xb,%edx
80102345:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010234a:	e8 50 ff ff ff       	call   8010229f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010234f:	ba 20 00 02 00       	mov    $0x20020,%edx
80102354:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102359:	e8 41 ff ff ff       	call   8010229f <lapicw>
  lapicw(TICR, 10000000);
8010235e:	ba 80 96 98 00       	mov    $0x989680,%edx
80102363:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102368:	e8 32 ff ff ff       	call   8010229f <lapicw>
  lapicw(LINT0, MASKED);
8010236d:	ba 00 00 01 00       	mov    $0x10000,%edx
80102372:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102377:	e8 23 ff ff ff       	call   8010229f <lapicw>
  lapicw(LINT1, MASKED);
8010237c:	ba 00 00 01 00       	mov    $0x10000,%edx
80102381:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102386:	e8 14 ff ff ff       	call   8010229f <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010238b:	a1 80 16 11 80       	mov    0x80111680,%eax
80102390:	8b 40 30             	mov    0x30(%eax),%eax
80102393:	c1 e8 10             	shr    $0x10,%eax
80102396:	a8 fc                	test   $0xfc,%al
80102398:	75 7b                	jne    80102415 <lapicinit+0xf7>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010239a:	ba 33 00 00 00       	mov    $0x33,%edx
8010239f:	b8 dc 00 00 00       	mov    $0xdc,%eax
801023a4:	e8 f6 fe ff ff       	call   8010229f <lapicw>
  lapicw(ESR, 0);
801023a9:	ba 00 00 00 00       	mov    $0x0,%edx
801023ae:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023b3:	e8 e7 fe ff ff       	call   8010229f <lapicw>
  lapicw(ESR, 0);
801023b8:	ba 00 00 00 00       	mov    $0x0,%edx
801023bd:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023c2:	e8 d8 fe ff ff       	call   8010229f <lapicw>
  lapicw(EOI, 0);
801023c7:	ba 00 00 00 00       	mov    $0x0,%edx
801023cc:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023d1:	e8 c9 fe ff ff       	call   8010229f <lapicw>
  lapicw(ICRHI, 0);
801023d6:	ba 00 00 00 00       	mov    $0x0,%edx
801023db:	b8 c4 00 00 00       	mov    $0xc4,%eax
801023e0:	e8 ba fe ff ff       	call   8010229f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801023e5:	ba 00 85 08 00       	mov    $0x88500,%edx
801023ea:	b8 c0 00 00 00       	mov    $0xc0,%eax
801023ef:	e8 ab fe ff ff       	call   8010229f <lapicw>
  while(lapic[ICRLO] & DELIVS)
801023f4:	a1 80 16 11 80       	mov    0x80111680,%eax
801023f9:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801023ff:	f6 c4 10             	test   $0x10,%ah
80102402:	75 f0                	jne    801023f4 <lapicinit+0xd6>
  lapicw(TPR, 0);
80102404:	ba 00 00 00 00       	mov    $0x0,%edx
80102409:	b8 20 00 00 00       	mov    $0x20,%eax
8010240e:	e8 8c fe ff ff       	call   8010229f <lapicw>
}
80102413:	c9                   	leave  
80102414:	c3                   	ret    
    lapicw(PCINT, MASKED);
80102415:	ba 00 00 01 00       	mov    $0x10000,%edx
8010241a:	b8 d0 00 00 00       	mov    $0xd0,%eax
8010241f:	e8 7b fe ff ff       	call   8010229f <lapicw>
80102424:	e9 71 ff ff ff       	jmp    8010239a <lapicinit+0x7c>
80102429:	c3                   	ret    

8010242a <lapicid>:
  if (!lapic)
8010242a:	a1 80 16 11 80       	mov    0x80111680,%eax
8010242f:	85 c0                	test   %eax,%eax
80102431:	74 07                	je     8010243a <lapicid+0x10>
  return lapic[ID] >> 24;
80102433:	8b 40 20             	mov    0x20(%eax),%eax
80102436:	c1 e8 18             	shr    $0x18,%eax
80102439:	c3                   	ret    
    return 0;
8010243a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010243f:	c3                   	ret    

80102440 <lapiceoi>:
  if(lapic)
80102440:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
80102447:	74 17                	je     80102460 <lapiceoi+0x20>
{
80102449:	55                   	push   %ebp
8010244a:	89 e5                	mov    %esp,%ebp
8010244c:	83 ec 08             	sub    $0x8,%esp
    lapicw(EOI, 0);
8010244f:	ba 00 00 00 00       	mov    $0x0,%edx
80102454:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102459:	e8 41 fe ff ff       	call   8010229f <lapicw>
}
8010245e:	c9                   	leave  
8010245f:	c3                   	ret    
80102460:	c3                   	ret    

80102461 <microdelay>:
}
80102461:	c3                   	ret    

80102462 <lapicstartap>:
{
80102462:	55                   	push   %ebp
80102463:	89 e5                	mov    %esp,%ebp
80102465:	57                   	push   %edi
80102466:	56                   	push   %esi
80102467:	53                   	push   %ebx
80102468:	83 ec 0c             	sub    $0xc,%esp
8010246b:	8b 75 08             	mov    0x8(%ebp),%esi
8010246e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102471:	b8 0f 00 00 00       	mov    $0xf,%eax
80102476:	ba 70 00 00 00       	mov    $0x70,%edx
8010247b:	ee                   	out    %al,(%dx)
8010247c:	b8 0a 00 00 00       	mov    $0xa,%eax
80102481:	ba 71 00 00 00       	mov    $0x71,%edx
80102486:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102487:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
8010248e:	00 00 
  wrv[1] = addr >> 4;
80102490:	89 f8                	mov    %edi,%eax
80102492:	c1 e8 04             	shr    $0x4,%eax
80102495:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
8010249b:	c1 e6 18             	shl    $0x18,%esi
8010249e:	89 f2                	mov    %esi,%edx
801024a0:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024a5:	e8 f5 fd ff ff       	call   8010229f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801024aa:	ba 00 c5 00 00       	mov    $0xc500,%edx
801024af:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024b4:	e8 e6 fd ff ff       	call   8010229f <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801024b9:	ba 00 85 00 00       	mov    $0x8500,%edx
801024be:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024c3:	e8 d7 fd ff ff       	call   8010229f <lapicw>
  for(i = 0; i < 2; i++){
801024c8:	bb 00 00 00 00       	mov    $0x0,%ebx
801024cd:	eb 21                	jmp    801024f0 <lapicstartap+0x8e>
    lapicw(ICRHI, apicid<<24);
801024cf:	89 f2                	mov    %esi,%edx
801024d1:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024d6:	e8 c4 fd ff ff       	call   8010229f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801024db:	89 fa                	mov    %edi,%edx
801024dd:	c1 ea 0c             	shr    $0xc,%edx
801024e0:	80 ce 06             	or     $0x6,%dh
801024e3:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024e8:	e8 b2 fd ff ff       	call   8010229f <lapicw>
  for(i = 0; i < 2; i++){
801024ed:	83 c3 01             	add    $0x1,%ebx
801024f0:	83 fb 01             	cmp    $0x1,%ebx
801024f3:	7e da                	jle    801024cf <lapicstartap+0x6d>
}
801024f5:	83 c4 0c             	add    $0xc,%esp
801024f8:	5b                   	pop    %ebx
801024f9:	5e                   	pop    %esi
801024fa:	5f                   	pop    %edi
801024fb:	5d                   	pop    %ebp
801024fc:	c3                   	ret    

801024fd <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801024fd:	55                   	push   %ebp
801024fe:	89 e5                	mov    %esp,%ebp
80102500:	57                   	push   %edi
80102501:	56                   	push   %esi
80102502:	53                   	push   %ebx
80102503:	83 ec 3c             	sub    $0x3c,%esp
80102506:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102509:	b8 0b 00 00 00       	mov    $0xb,%eax
8010250e:	e8 a0 fd ff ff       	call   801022b3 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
80102513:	83 e0 04             	and    $0x4,%eax
80102516:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102518:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010251b:	e8 a3 fd ff ff       	call   801022c3 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102520:	b8 0a 00 00 00       	mov    $0xa,%eax
80102525:	e8 89 fd ff ff       	call   801022b3 <cmos_read>
8010252a:	a8 80                	test   $0x80,%al
8010252c:	75 ea                	jne    80102518 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
8010252e:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102531:	89 d8                	mov    %ebx,%eax
80102533:	e8 8b fd ff ff       	call   801022c3 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102538:	83 ec 04             	sub    $0x4,%esp
8010253b:	6a 18                	push   $0x18
8010253d:	53                   	push   %ebx
8010253e:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102541:	50                   	push   %eax
80102542:	e8 b6 19 00 00       	call   80103efd <memcmp>
80102547:	83 c4 10             	add    $0x10,%esp
8010254a:	85 c0                	test   %eax,%eax
8010254c:	75 ca                	jne    80102518 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
8010254e:	85 ff                	test   %edi,%edi
80102550:	75 78                	jne    801025ca <cmostime+0xcd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102552:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102555:	89 c2                	mov    %eax,%edx
80102557:	c1 ea 04             	shr    $0x4,%edx
8010255a:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010255d:	83 e0 0f             	and    $0xf,%eax
80102560:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102563:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102566:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102569:	89 c2                	mov    %eax,%edx
8010256b:	c1 ea 04             	shr    $0x4,%edx
8010256e:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102571:	83 e0 0f             	and    $0xf,%eax
80102574:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102577:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
8010257a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010257d:	89 c2                	mov    %eax,%edx
8010257f:	c1 ea 04             	shr    $0x4,%edx
80102582:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102585:	83 e0 0f             	and    $0xf,%eax
80102588:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010258b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
8010258e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102591:	89 c2                	mov    %eax,%edx
80102593:	c1 ea 04             	shr    $0x4,%edx
80102596:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102599:	83 e0 0f             	and    $0xf,%eax
8010259c:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010259f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
801025a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801025a5:	89 c2                	mov    %eax,%edx
801025a7:	c1 ea 04             	shr    $0x4,%edx
801025aa:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025ad:	83 e0 0f             	and    $0xf,%eax
801025b0:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801025b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801025b9:	89 c2                	mov    %eax,%edx
801025bb:	c1 ea 04             	shr    $0x4,%edx
801025be:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025c1:	83 e0 0f             	and    $0xf,%eax
801025c4:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
801025ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
801025cd:	89 06                	mov    %eax,(%esi)
801025cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801025d2:	89 46 04             	mov    %eax,0x4(%esi)
801025d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801025d8:	89 46 08             	mov    %eax,0x8(%esi)
801025db:	8b 45 dc             	mov    -0x24(%ebp),%eax
801025de:	89 46 0c             	mov    %eax,0xc(%esi)
801025e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801025e4:	89 46 10             	mov    %eax,0x10(%esi)
801025e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801025ea:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801025ed:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
801025f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801025f7:	5b                   	pop    %ebx
801025f8:	5e                   	pop    %esi
801025f9:	5f                   	pop    %edi
801025fa:	5d                   	pop    %ebp
801025fb:	c3                   	ret    

801025fc <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801025fc:	55                   	push   %ebp
801025fd:	89 e5                	mov    %esp,%ebp
801025ff:	53                   	push   %ebx
80102600:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102603:	ff 35 d4 16 11 80    	push   0x801116d4
80102609:	ff 35 e4 16 11 80    	push   0x801116e4
8010260f:	e8 58 db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102614:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102617:	89 1d e8 16 11 80    	mov    %ebx,0x801116e8
  for (i = 0; i < log.lh.n; i++) {
8010261d:	83 c4 10             	add    $0x10,%esp
80102620:	ba 00 00 00 00       	mov    $0x0,%edx
80102625:	eb 0e                	jmp    80102635 <read_head+0x39>
    log.lh.block[i] = lh->block[i];
80102627:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
8010262b:	89 0c 95 ec 16 11 80 	mov    %ecx,-0x7feee914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102632:	83 c2 01             	add    $0x1,%edx
80102635:	39 d3                	cmp    %edx,%ebx
80102637:	7f ee                	jg     80102627 <read_head+0x2b>
  }
  brelse(buf);
80102639:	83 ec 0c             	sub    $0xc,%esp
8010263c:	50                   	push   %eax
8010263d:	e8 93 db ff ff       	call   801001d5 <brelse>
}
80102642:	83 c4 10             	add    $0x10,%esp
80102645:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102648:	c9                   	leave  
80102649:	c3                   	ret    

8010264a <install_trans>:
{
8010264a:	55                   	push   %ebp
8010264b:	89 e5                	mov    %esp,%ebp
8010264d:	57                   	push   %edi
8010264e:	56                   	push   %esi
8010264f:	53                   	push   %ebx
80102650:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102653:	be 00 00 00 00       	mov    $0x0,%esi
80102658:	eb 66                	jmp    801026c0 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010265a:	89 f0                	mov    %esi,%eax
8010265c:	03 05 d4 16 11 80    	add    0x801116d4,%eax
80102662:	83 c0 01             	add    $0x1,%eax
80102665:	83 ec 08             	sub    $0x8,%esp
80102668:	50                   	push   %eax
80102669:	ff 35 e4 16 11 80    	push   0x801116e4
8010266f:	e8 f8 da ff ff       	call   8010016c <bread>
80102674:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102676:	83 c4 08             	add    $0x8,%esp
80102679:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
80102680:	ff 35 e4 16 11 80    	push   0x801116e4
80102686:	e8 e1 da ff ff       	call   8010016c <bread>
8010268b:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010268d:	8d 57 5c             	lea    0x5c(%edi),%edx
80102690:	8d 40 5c             	lea    0x5c(%eax),%eax
80102693:	83 c4 0c             	add    $0xc,%esp
80102696:	68 00 02 00 00       	push   $0x200
8010269b:	52                   	push   %edx
8010269c:	50                   	push   %eax
8010269d:	e8 90 18 00 00       	call   80103f32 <memmove>
    bwrite(dbuf);  // write dst to disk
801026a2:	89 1c 24             	mov    %ebx,(%esp)
801026a5:	e8 f0 da ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
801026aa:	89 3c 24             	mov    %edi,(%esp)
801026ad:	e8 23 db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
801026b2:	89 1c 24             	mov    %ebx,(%esp)
801026b5:	e8 1b db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801026ba:	83 c6 01             	add    $0x1,%esi
801026bd:	83 c4 10             	add    $0x10,%esp
801026c0:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
801026c6:	7f 92                	jg     8010265a <install_trans+0x10>
}
801026c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801026cb:	5b                   	pop    %ebx
801026cc:	5e                   	pop    %esi
801026cd:	5f                   	pop    %edi
801026ce:	5d                   	pop    %ebp
801026cf:	c3                   	ret    

801026d0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	53                   	push   %ebx
801026d4:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801026d7:	ff 35 d4 16 11 80    	push   0x801116d4
801026dd:	ff 35 e4 16 11 80    	push   0x801116e4
801026e3:	e8 84 da ff ff       	call   8010016c <bread>
801026e8:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801026ea:	8b 0d e8 16 11 80    	mov    0x801116e8,%ecx
801026f0:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801026f3:	83 c4 10             	add    $0x10,%esp
801026f6:	b8 00 00 00 00       	mov    $0x0,%eax
801026fb:	eb 0e                	jmp    8010270b <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
801026fd:	8b 14 85 ec 16 11 80 	mov    -0x7feee914(,%eax,4),%edx
80102704:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
80102708:	83 c0 01             	add    $0x1,%eax
8010270b:	39 c1                	cmp    %eax,%ecx
8010270d:	7f ee                	jg     801026fd <write_head+0x2d>
  }
  bwrite(buf);
8010270f:	83 ec 0c             	sub    $0xc,%esp
80102712:	53                   	push   %ebx
80102713:	e8 82 da ff ff       	call   8010019a <bwrite>
  brelse(buf);
80102718:	89 1c 24             	mov    %ebx,(%esp)
8010271b:	e8 b5 da ff ff       	call   801001d5 <brelse>
}
80102720:	83 c4 10             	add    $0x10,%esp
80102723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102726:	c9                   	leave  
80102727:	c3                   	ret    

80102728 <recover_from_log>:

static void
recover_from_log(void)
{
80102728:	55                   	push   %ebp
80102729:	89 e5                	mov    %esp,%ebp
8010272b:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010272e:	e8 c9 fe ff ff       	call   801025fc <read_head>
  install_trans(); // if committed, copy from log to disk
80102733:	e8 12 ff ff ff       	call   8010264a <install_trans>
  log.lh.n = 0;
80102738:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
8010273f:	00 00 00 
  write_head(); // clear the log
80102742:	e8 89 ff ff ff       	call   801026d0 <write_head>
}
80102747:	c9                   	leave  
80102748:	c3                   	ret    

80102749 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102749:	55                   	push   %ebp
8010274a:	89 e5                	mov    %esp,%ebp
8010274c:	57                   	push   %edi
8010274d:	56                   	push   %esi
8010274e:	53                   	push   %ebx
8010274f:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102752:	be 00 00 00 00       	mov    $0x0,%esi
80102757:	eb 66                	jmp    801027bf <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102759:	89 f0                	mov    %esi,%eax
8010275b:	03 05 d4 16 11 80    	add    0x801116d4,%eax
80102761:	83 c0 01             	add    $0x1,%eax
80102764:	83 ec 08             	sub    $0x8,%esp
80102767:	50                   	push   %eax
80102768:	ff 35 e4 16 11 80    	push   0x801116e4
8010276e:	e8 f9 d9 ff ff       	call   8010016c <bread>
80102773:	89 c3                	mov    %eax,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102775:	83 c4 08             	add    $0x8,%esp
80102778:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
8010277f:	ff 35 e4 16 11 80    	push   0x801116e4
80102785:	e8 e2 d9 ff ff       	call   8010016c <bread>
8010278a:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
8010278c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010278f:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102792:	83 c4 0c             	add    $0xc,%esp
80102795:	68 00 02 00 00       	push   $0x200
8010279a:	52                   	push   %edx
8010279b:	50                   	push   %eax
8010279c:	e8 91 17 00 00       	call   80103f32 <memmove>
    bwrite(to);  // write the log
801027a1:	89 1c 24             	mov    %ebx,(%esp)
801027a4:	e8 f1 d9 ff ff       	call   8010019a <bwrite>
    brelse(from);
801027a9:	89 3c 24             	mov    %edi,(%esp)
801027ac:	e8 24 da ff ff       	call   801001d5 <brelse>
    brelse(to);
801027b1:	89 1c 24             	mov    %ebx,(%esp)
801027b4:	e8 1c da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801027b9:	83 c6 01             	add    $0x1,%esi
801027bc:	83 c4 10             	add    $0x10,%esp
801027bf:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
801027c5:	7f 92                	jg     80102759 <write_log+0x10>
  }
}
801027c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801027ca:	5b                   	pop    %ebx
801027cb:	5e                   	pop    %esi
801027cc:	5f                   	pop    %edi
801027cd:	5d                   	pop    %ebp
801027ce:	c3                   	ret    

801027cf <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
801027cf:	83 3d e8 16 11 80 00 	cmpl   $0x0,0x801116e8
801027d6:	7f 01                	jg     801027d9 <commit+0xa>
801027d8:	c3                   	ret    
{
801027d9:	55                   	push   %ebp
801027da:	89 e5                	mov    %esp,%ebp
801027dc:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
801027df:	e8 65 ff ff ff       	call   80102749 <write_log>
    write_head();    // Write header to disk -- the real commit
801027e4:	e8 e7 fe ff ff       	call   801026d0 <write_head>
    install_trans(); // Now install writes to home locations
801027e9:	e8 5c fe ff ff       	call   8010264a <install_trans>
    log.lh.n = 0;
801027ee:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
801027f5:	00 00 00 
    write_head();    // Erase the transaction from the log
801027f8:	e8 d3 fe ff ff       	call   801026d0 <write_head>
  }
}
801027fd:	c9                   	leave  
801027fe:	c3                   	ret    

801027ff <initlog>:
{
801027ff:	55                   	push   %ebp
80102800:	89 e5                	mov    %esp,%ebp
80102802:	53                   	push   %ebx
80102803:	83 ec 2c             	sub    $0x2c,%esp
80102806:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102809:	68 80 6e 10 80       	push   $0x80106e80
8010280e:	68 a0 16 11 80       	push   $0x801116a0
80102813:	e8 ba 14 00 00       	call   80103cd2 <initlock>
  readsb(dev, &sb);
80102818:	83 c4 08             	add    $0x8,%esp
8010281b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010281e:	50                   	push   %eax
8010281f:	53                   	push   %ebx
80102820:	e8 81 ea ff ff       	call   801012a6 <readsb>
  log.start = sb.logstart;
80102825:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102828:	a3 d4 16 11 80       	mov    %eax,0x801116d4
  log.size = sb.nlog;
8010282d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102830:	a3 d8 16 11 80       	mov    %eax,0x801116d8
  log.dev = dev;
80102835:	89 1d e4 16 11 80    	mov    %ebx,0x801116e4
  recover_from_log();
8010283b:	e8 e8 fe ff ff       	call   80102728 <recover_from_log>
}
80102840:	83 c4 10             	add    $0x10,%esp
80102843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102846:	c9                   	leave  
80102847:	c3                   	ret    

80102848 <begin_op>:
{
80102848:	55                   	push   %ebp
80102849:	89 e5                	mov    %esp,%ebp
8010284b:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
8010284e:	68 a0 16 11 80       	push   $0x801116a0
80102853:	e8 b6 15 00 00       	call   80103e0e <acquire>
80102858:	83 c4 10             	add    $0x10,%esp
8010285b:	eb 15                	jmp    80102872 <begin_op+0x2a>
      sleep(&log, &log.lock);
8010285d:	83 ec 08             	sub    $0x8,%esp
80102860:	68 a0 16 11 80       	push   $0x801116a0
80102865:	68 a0 16 11 80       	push   $0x801116a0
8010286a:	e8 e5 0e 00 00       	call   80103754 <sleep>
8010286f:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102872:	83 3d e0 16 11 80 00 	cmpl   $0x0,0x801116e0
80102879:	75 e2                	jne    8010285d <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010287b:	a1 dc 16 11 80       	mov    0x801116dc,%eax
80102880:	83 c0 01             	add    $0x1,%eax
80102883:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102886:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102889:	03 15 e8 16 11 80    	add    0x801116e8,%edx
8010288f:	83 fa 1e             	cmp    $0x1e,%edx
80102892:	7e 17                	jle    801028ab <begin_op+0x63>
      sleep(&log, &log.lock);
80102894:	83 ec 08             	sub    $0x8,%esp
80102897:	68 a0 16 11 80       	push   $0x801116a0
8010289c:	68 a0 16 11 80       	push   $0x801116a0
801028a1:	e8 ae 0e 00 00       	call   80103754 <sleep>
801028a6:	83 c4 10             	add    $0x10,%esp
801028a9:	eb c7                	jmp    80102872 <begin_op+0x2a>
      log.outstanding += 1;
801028ab:	a3 dc 16 11 80       	mov    %eax,0x801116dc
      release(&log.lock);
801028b0:	83 ec 0c             	sub    $0xc,%esp
801028b3:	68 a0 16 11 80       	push   $0x801116a0
801028b8:	e8 b6 15 00 00       	call   80103e73 <release>
}
801028bd:	83 c4 10             	add    $0x10,%esp
801028c0:	c9                   	leave  
801028c1:	c3                   	ret    

801028c2 <end_op>:
{
801028c2:	55                   	push   %ebp
801028c3:	89 e5                	mov    %esp,%ebp
801028c5:	53                   	push   %ebx
801028c6:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
801028c9:	68 a0 16 11 80       	push   $0x801116a0
801028ce:	e8 3b 15 00 00       	call   80103e0e <acquire>
  log.outstanding -= 1;
801028d3:	a1 dc 16 11 80       	mov    0x801116dc,%eax
801028d8:	83 e8 01             	sub    $0x1,%eax
801028db:	a3 dc 16 11 80       	mov    %eax,0x801116dc
  if(log.committing)
801028e0:	8b 1d e0 16 11 80    	mov    0x801116e0,%ebx
801028e6:	83 c4 10             	add    $0x10,%esp
801028e9:	85 db                	test   %ebx,%ebx
801028eb:	75 2c                	jne    80102919 <end_op+0x57>
  if(log.outstanding == 0){
801028ed:	85 c0                	test   %eax,%eax
801028ef:	75 35                	jne    80102926 <end_op+0x64>
    log.committing = 1;
801028f1:	c7 05 e0 16 11 80 01 	movl   $0x1,0x801116e0
801028f8:	00 00 00 
    do_commit = 1;
801028fb:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102900:	83 ec 0c             	sub    $0xc,%esp
80102903:	68 a0 16 11 80       	push   $0x801116a0
80102908:	e8 66 15 00 00       	call   80103e73 <release>
  if(do_commit){
8010290d:	83 c4 10             	add    $0x10,%esp
80102910:	85 db                	test   %ebx,%ebx
80102912:	75 24                	jne    80102938 <end_op+0x76>
}
80102914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102917:	c9                   	leave  
80102918:	c3                   	ret    
    panic("log.committing");
80102919:	83 ec 0c             	sub    $0xc,%esp
8010291c:	68 84 6e 10 80       	push   $0x80106e84
80102921:	e8 22 da ff ff       	call   80100348 <panic>
    wakeup(&log);
80102926:	83 ec 0c             	sub    $0xc,%esp
80102929:	68 a0 16 11 80       	push   $0x801116a0
8010292e:	e8 86 0f 00 00       	call   801038b9 <wakeup>
80102933:	83 c4 10             	add    $0x10,%esp
80102936:	eb c8                	jmp    80102900 <end_op+0x3e>
    commit();
80102938:	e8 92 fe ff ff       	call   801027cf <commit>
    acquire(&log.lock);
8010293d:	83 ec 0c             	sub    $0xc,%esp
80102940:	68 a0 16 11 80       	push   $0x801116a0
80102945:	e8 c4 14 00 00       	call   80103e0e <acquire>
    log.committing = 0;
8010294a:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
80102951:	00 00 00 
    wakeup(&log);
80102954:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
8010295b:	e8 59 0f 00 00       	call   801038b9 <wakeup>
    release(&log.lock);
80102960:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
80102967:	e8 07 15 00 00       	call   80103e73 <release>
8010296c:	83 c4 10             	add    $0x10,%esp
}
8010296f:	eb a3                	jmp    80102914 <end_op+0x52>

80102971 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102971:	55                   	push   %ebp
80102972:	89 e5                	mov    %esp,%ebp
80102974:	53                   	push   %ebx
80102975:	83 ec 04             	sub    $0x4,%esp
80102978:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010297b:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
80102981:	83 fa 1d             	cmp    $0x1d,%edx
80102984:	7f 2c                	jg     801029b2 <log_write+0x41>
80102986:	a1 d8 16 11 80       	mov    0x801116d8,%eax
8010298b:	83 e8 01             	sub    $0x1,%eax
8010298e:	39 c2                	cmp    %eax,%edx
80102990:	7d 20                	jge    801029b2 <log_write+0x41>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102992:	83 3d dc 16 11 80 00 	cmpl   $0x0,0x801116dc
80102999:	7e 24                	jle    801029bf <log_write+0x4e>
    panic("log_write outside of trans");

  acquire(&log.lock);
8010299b:	83 ec 0c             	sub    $0xc,%esp
8010299e:	68 a0 16 11 80       	push   $0x801116a0
801029a3:	e8 66 14 00 00       	call   80103e0e <acquire>
  for (i = 0; i < log.lh.n; i++) {
801029a8:	83 c4 10             	add    $0x10,%esp
801029ab:	b8 00 00 00 00       	mov    $0x0,%eax
801029b0:	eb 1d                	jmp    801029cf <log_write+0x5e>
    panic("too big a transaction");
801029b2:	83 ec 0c             	sub    $0xc,%esp
801029b5:	68 93 6e 10 80       	push   $0x80106e93
801029ba:	e8 89 d9 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
801029bf:	83 ec 0c             	sub    $0xc,%esp
801029c2:	68 a9 6e 10 80       	push   $0x80106ea9
801029c7:	e8 7c d9 ff ff       	call   80100348 <panic>
  for (i = 0; i < log.lh.n; i++) {
801029cc:	83 c0 01             	add    $0x1,%eax
801029cf:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
801029d5:	39 c2                	cmp    %eax,%edx
801029d7:	7e 0c                	jle    801029e5 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801029d9:	8b 4b 08             	mov    0x8(%ebx),%ecx
801029dc:	39 0c 85 ec 16 11 80 	cmp    %ecx,-0x7feee914(,%eax,4)
801029e3:	75 e7                	jne    801029cc <log_write+0x5b>
      break;
  }
  log.lh.block[i] = b->blockno;
801029e5:	8b 4b 08             	mov    0x8(%ebx),%ecx
801029e8:	89 0c 85 ec 16 11 80 	mov    %ecx,-0x7feee914(,%eax,4)
  if (i == log.lh.n)
801029ef:	39 c2                	cmp    %eax,%edx
801029f1:	74 18                	je     80102a0b <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
801029f3:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
801029f6:	83 ec 0c             	sub    $0xc,%esp
801029f9:	68 a0 16 11 80       	push   $0x801116a0
801029fe:	e8 70 14 00 00       	call   80103e73 <release>
}
80102a03:	83 c4 10             	add    $0x10,%esp
80102a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a09:	c9                   	leave  
80102a0a:	c3                   	ret    
    log.lh.n++;
80102a0b:	83 c2 01             	add    $0x1,%edx
80102a0e:	89 15 e8 16 11 80    	mov    %edx,0x801116e8
80102a14:	eb dd                	jmp    801029f3 <log_write+0x82>

80102a16 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102a16:	55                   	push   %ebp
80102a17:	89 e5                	mov    %esp,%ebp
80102a19:	53                   	push   %ebx
80102a1a:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102a1d:	68 8a 00 00 00       	push   $0x8a
80102a22:	68 8c a4 10 80       	push   $0x8010a48c
80102a27:	68 00 70 00 80       	push   $0x80007000
80102a2c:	e8 01 15 00 00       	call   80103f32 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102a31:	83 c4 10             	add    $0x10,%esp
80102a34:	bb a0 17 11 80       	mov    $0x801117a0,%ebx
80102a39:	eb 13                	jmp    80102a4e <startothers+0x38>
80102a3b:	83 ec 0c             	sub    $0xc,%esp
80102a3e:	68 a8 6b 10 80       	push   $0x80106ba8
80102a43:	e8 00 d9 ff ff       	call   80100348 <panic>
80102a48:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102a4e:	69 05 84 17 11 80 b0 	imul   $0xb0,0x80111784,%eax
80102a55:	00 00 00 
80102a58:	05 a0 17 11 80       	add    $0x801117a0,%eax
80102a5d:	39 d8                	cmp    %ebx,%eax
80102a5f:	76 58                	jbe    80102ab9 <startothers+0xa3>
    if(c == mycpu())  // We've started already.
80102a61:	e8 d5 07 00 00       	call   8010323b <mycpu>
80102a66:	39 c3                	cmp    %eax,%ebx
80102a68:	74 de                	je     80102a48 <startothers+0x32>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102a6a:	e8 5a f6 ff ff       	call   801020c9 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102a6f:	05 00 10 00 00       	add    $0x1000,%eax
80102a74:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102a79:	c7 05 f8 6f 00 80 fd 	movl   $0x80102afd,0x80006ff8
80102a80:	2a 10 80 
    if (a < (void*) KERNBASE)
80102a83:	b8 00 90 10 80       	mov    $0x80109000,%eax
80102a88:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80102a8d:	76 ac                	jbe    80102a3b <startothers+0x25>
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102a8f:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102a96:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102a99:	83 ec 08             	sub    $0x8,%esp
80102a9c:	68 00 70 00 00       	push   $0x7000
80102aa1:	0f b6 03             	movzbl (%ebx),%eax
80102aa4:	50                   	push   %eax
80102aa5:	e8 b8 f9 ff ff       	call   80102462 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102aaa:	83 c4 10             	add    $0x10,%esp
80102aad:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102ab3:	85 c0                	test   %eax,%eax
80102ab5:	74 f6                	je     80102aad <startothers+0x97>
80102ab7:	eb 8f                	jmp    80102a48 <startothers+0x32>
      ;
  }
}
80102ab9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102abc:	c9                   	leave  
80102abd:	c3                   	ret    

80102abe <mpmain>:
{
80102abe:	55                   	push   %ebp
80102abf:	89 e5                	mov    %esp,%ebp
80102ac1:	53                   	push   %ebx
80102ac2:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102ac5:	e8 cd 07 00 00       	call   80103297 <cpuid>
80102aca:	89 c3                	mov    %eax,%ebx
80102acc:	e8 c6 07 00 00       	call   80103297 <cpuid>
80102ad1:	83 ec 04             	sub    $0x4,%esp
80102ad4:	53                   	push   %ebx
80102ad5:	50                   	push   %eax
80102ad6:	68 c4 6e 10 80       	push   $0x80106ec4
80102adb:	e8 27 db ff ff       	call   80100607 <cprintf>
  idtinit();       // load idt register
80102ae0:	e8 66 25 00 00       	call   8010504b <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102ae5:	e8 51 07 00 00       	call   8010323b <mycpu>
80102aea:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102aec:	b8 01 00 00 00       	mov    $0x1,%eax
80102af1:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102af8:	e8 32 0a 00 00       	call   8010352f <scheduler>

80102afd <mpenter>:
{
80102afd:	55                   	push   %ebp
80102afe:	89 e5                	mov    %esp,%ebp
80102b00:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102b03:	e8 a0 36 00 00       	call   801061a8 <switchkvm>
  seginit();
80102b08:	e8 0e 33 00 00       	call   80105e1b <seginit>
  lapicinit();
80102b0d:	e8 0c f8 ff ff       	call   8010231e <lapicinit>
  mpmain();
80102b12:	e8 a7 ff ff ff       	call   80102abe <mpmain>

80102b17 <main>:
{
80102b17:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102b1b:	83 e4 f0             	and    $0xfffffff0,%esp
80102b1e:	ff 71 fc             	push   -0x4(%ecx)
80102b21:	55                   	push   %ebp
80102b22:	89 e5                	mov    %esp,%ebp
80102b24:	51                   	push   %ecx
80102b25:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102b28:	68 00 00 40 80       	push   $0x80400000
80102b2d:	68 d0 54 11 80       	push   $0x801154d0
80102b32:	e8 40 f5 ff ff       	call   80102077 <kinit1>
  kvmalloc();      // kernel page table
80102b37:	e8 d5 3b 00 00       	call   80106711 <kvmalloc>
  mpinit();        // detect other processors
80102b3c:	e8 db 01 00 00       	call   80102d1c <mpinit>
  lapicinit();     // interrupt controller
80102b41:	e8 d8 f7 ff ff       	call   8010231e <lapicinit>
  seginit();       // segment descriptors
80102b46:	e8 d0 32 00 00       	call   80105e1b <seginit>
  picinit();       // disable pic
80102b4b:	e8 a2 02 00 00       	call   80102df2 <picinit>
  ioapicinit();    // another interrupt controller
80102b50:	e8 88 f3 ff ff       	call   80101edd <ioapicinit>
  consoleinit();   // console hardware
80102b55:	e8 30 dd ff ff       	call   8010088a <consoleinit>
  uartinit();      // serial port
80102b5a:	e8 93 27 00 00       	call   801052f2 <uartinit>
  pinit();         // process table
80102b5f:	e8 bd 06 00 00       	call   80103221 <pinit>
  tvinit();        // trap vectors
80102b64:	e8 dd 23 00 00       	call   80104f46 <tvinit>
  binit();         // buffer cache
80102b69:	e8 86 d5 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102b6e:	e8 90 e0 ff ff       	call   80100c03 <fileinit>
  ideinit();       // disk 
80102b73:	e8 71 f1 ff ff       	call   80101ce9 <ideinit>
  startothers();   // start other processors
80102b78:	e8 99 fe ff ff       	call   80102a16 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102b7d:	83 c4 08             	add    $0x8,%esp
80102b80:	68 00 00 00 8e       	push   $0x8e000000
80102b85:	68 00 00 40 80       	push   $0x80400000
80102b8a:	e8 1a f5 ff ff       	call   801020a9 <kinit2>
  userinit();      // first user process
80102b8f:	e8 41 07 00 00       	call   801032d5 <userinit>
  mpmain();        // finish this processor's setup
80102b94:	e8 25 ff ff ff       	call   80102abe <mpmain>

80102b99 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102b99:	55                   	push   %ebp
80102b9a:	89 e5                	mov    %esp,%ebp
80102b9c:	56                   	push   %esi
80102b9d:	53                   	push   %ebx
80102b9e:	89 c6                	mov    %eax,%esi
  int i, sum;

  sum = 0;
80102ba0:	b8 00 00 00 00       	mov    $0x0,%eax
  for(i=0; i<len; i++)
80102ba5:	b9 00 00 00 00       	mov    $0x0,%ecx
80102baa:	eb 09                	jmp    80102bb5 <sum+0x1c>
    sum += addr[i];
80102bac:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
80102bb0:	01 d8                	add    %ebx,%eax
  for(i=0; i<len; i++)
80102bb2:	83 c1 01             	add    $0x1,%ecx
80102bb5:	39 d1                	cmp    %edx,%ecx
80102bb7:	7c f3                	jl     80102bac <sum+0x13>
  return sum;
}
80102bb9:	5b                   	pop    %ebx
80102bba:	5e                   	pop    %esi
80102bbb:	5d                   	pop    %ebp
80102bbc:	c3                   	ret    

80102bbd <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102bbd:	55                   	push   %ebp
80102bbe:	89 e5                	mov    %esp,%ebp
80102bc0:	56                   	push   %esi
80102bc1:	53                   	push   %ebx
}

// Convert physical address to kernel virtual address
static inline void *P2V(uint a) {
    extern void panic(char*) __attribute__((noreturn));
    if (a > KERNBASE)
80102bc2:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80102bc7:	77 0b                	ja     80102bd4 <mpsearch1+0x17>
        panic("P2V on address > KERNBASE");
    return (char*)a + KERNBASE;
80102bc9:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
80102bcf:	8d 34 13             	lea    (%ebx,%edx,1),%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102bd2:	eb 10                	jmp    80102be4 <mpsearch1+0x27>
        panic("P2V on address > KERNBASE");
80102bd4:	83 ec 0c             	sub    $0xc,%esp
80102bd7:	68 d8 6e 10 80       	push   $0x80106ed8
80102bdc:	e8 67 d7 ff ff       	call   80100348 <panic>
80102be1:	83 c3 10             	add    $0x10,%ebx
80102be4:	39 f3                	cmp    %esi,%ebx
80102be6:	73 29                	jae    80102c11 <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102be8:	83 ec 04             	sub    $0x4,%esp
80102beb:	6a 04                	push   $0x4
80102bed:	68 f2 6e 10 80       	push   $0x80106ef2
80102bf2:	53                   	push   %ebx
80102bf3:	e8 05 13 00 00       	call   80103efd <memcmp>
80102bf8:	83 c4 10             	add    $0x10,%esp
80102bfb:	85 c0                	test   %eax,%eax
80102bfd:	75 e2                	jne    80102be1 <mpsearch1+0x24>
80102bff:	ba 10 00 00 00       	mov    $0x10,%edx
80102c04:	89 d8                	mov    %ebx,%eax
80102c06:	e8 8e ff ff ff       	call   80102b99 <sum>
80102c0b:	84 c0                	test   %al,%al
80102c0d:	75 d2                	jne    80102be1 <mpsearch1+0x24>
80102c0f:	eb 05                	jmp    80102c16 <mpsearch1+0x59>
      return (struct mp*)p;
  return 0;
80102c11:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102c16:	89 d8                	mov    %ebx,%eax
80102c18:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102c1b:	5b                   	pop    %ebx
80102c1c:	5e                   	pop    %esi
80102c1d:	5d                   	pop    %ebp
80102c1e:	c3                   	ret    

80102c1f <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102c1f:	55                   	push   %ebp
80102c20:	89 e5                	mov    %esp,%ebp
80102c22:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102c25:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102c2c:	c1 e0 08             	shl    $0x8,%eax
80102c2f:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102c36:	09 d0                	or     %edx,%eax
80102c38:	c1 e0 04             	shl    $0x4,%eax
80102c3b:	74 1f                	je     80102c5c <mpsearch+0x3d>
    if((mp = mpsearch1(p, 1024)))
80102c3d:	ba 00 04 00 00       	mov    $0x400,%edx
80102c42:	e8 76 ff ff ff       	call   80102bbd <mpsearch1>
80102c47:	85 c0                	test   %eax,%eax
80102c49:	75 0f                	jne    80102c5a <mpsearch+0x3b>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102c4b:	ba 00 00 01 00       	mov    $0x10000,%edx
80102c50:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102c55:	e8 63 ff ff ff       	call   80102bbd <mpsearch1>
}
80102c5a:	c9                   	leave  
80102c5b:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102c5c:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102c63:	c1 e0 08             	shl    $0x8,%eax
80102c66:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102c6d:	09 d0                	or     %edx,%eax
80102c6f:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102c72:	2d 00 04 00 00       	sub    $0x400,%eax
80102c77:	ba 00 04 00 00       	mov    $0x400,%edx
80102c7c:	e8 3c ff ff ff       	call   80102bbd <mpsearch1>
80102c81:	85 c0                	test   %eax,%eax
80102c83:	75 d5                	jne    80102c5a <mpsearch+0x3b>
80102c85:	eb c4                	jmp    80102c4b <mpsearch+0x2c>

80102c87 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102c87:	55                   	push   %ebp
80102c88:	89 e5                	mov    %esp,%ebp
80102c8a:	57                   	push   %edi
80102c8b:	56                   	push   %esi
80102c8c:	53                   	push   %ebx
80102c8d:	83 ec 0c             	sub    $0xc,%esp
80102c90:	89 c7                	mov    %eax,%edi
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102c92:	e8 88 ff ff ff       	call   80102c1f <mpsearch>
80102c97:	89 c6                	mov    %eax,%esi
80102c99:	85 c0                	test   %eax,%eax
80102c9b:	74 66                	je     80102d03 <mpconfig+0x7c>
80102c9d:	8b 58 04             	mov    0x4(%eax),%ebx
80102ca0:	85 db                	test   %ebx,%ebx
80102ca2:	74 48                	je     80102cec <mpconfig+0x65>
    if (a > KERNBASE)
80102ca4:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80102caa:	77 4a                	ja     80102cf6 <mpconfig+0x6f>
    return (char*)a + KERNBASE;
80102cac:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
80102cb2:	83 ec 04             	sub    $0x4,%esp
80102cb5:	6a 04                	push   $0x4
80102cb7:	68 f7 6e 10 80       	push   $0x80106ef7
80102cbc:	53                   	push   %ebx
80102cbd:	e8 3b 12 00 00       	call   80103efd <memcmp>
80102cc2:	83 c4 10             	add    $0x10,%esp
80102cc5:	85 c0                	test   %eax,%eax
80102cc7:	75 3e                	jne    80102d07 <mpconfig+0x80>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102cc9:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
80102ccd:	3c 01                	cmp    $0x1,%al
80102ccf:	0f 95 c2             	setne  %dl
80102cd2:	3c 04                	cmp    $0x4,%al
80102cd4:	0f 95 c0             	setne  %al
80102cd7:	84 c2                	test   %al,%dl
80102cd9:	75 33                	jne    80102d0e <mpconfig+0x87>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102cdb:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
80102cdf:	89 d8                	mov    %ebx,%eax
80102ce1:	e8 b3 fe ff ff       	call   80102b99 <sum>
80102ce6:	84 c0                	test   %al,%al
80102ce8:	75 2b                	jne    80102d15 <mpconfig+0x8e>
    return 0;
  *pmp = mp;
80102cea:	89 37                	mov    %esi,(%edi)
  return conf;
}
80102cec:	89 d8                	mov    %ebx,%eax
80102cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102cf1:	5b                   	pop    %ebx
80102cf2:	5e                   	pop    %esi
80102cf3:	5f                   	pop    %edi
80102cf4:	5d                   	pop    %ebp
80102cf5:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80102cf6:	83 ec 0c             	sub    $0xc,%esp
80102cf9:	68 d8 6e 10 80       	push   $0x80106ed8
80102cfe:	e8 45 d6 ff ff       	call   80100348 <panic>
    return 0;
80102d03:	89 c3                	mov    %eax,%ebx
80102d05:	eb e5                	jmp    80102cec <mpconfig+0x65>
    return 0;
80102d07:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d0c:	eb de                	jmp    80102cec <mpconfig+0x65>
    return 0;
80102d0e:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d13:	eb d7                	jmp    80102cec <mpconfig+0x65>
    return 0;
80102d15:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d1a:	eb d0                	jmp    80102cec <mpconfig+0x65>

80102d1c <mpinit>:

void
mpinit(void)
{
80102d1c:	55                   	push   %ebp
80102d1d:	89 e5                	mov    %esp,%ebp
80102d1f:	57                   	push   %edi
80102d20:	56                   	push   %esi
80102d21:	53                   	push   %ebx
80102d22:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102d25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102d28:	e8 5a ff ff ff       	call   80102c87 <mpconfig>
80102d2d:	85 c0                	test   %eax,%eax
80102d2f:	74 19                	je     80102d4a <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102d31:	8b 50 24             	mov    0x24(%eax),%edx
80102d34:	89 15 80 16 11 80    	mov    %edx,0x80111680
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d3a:	8d 50 2c             	lea    0x2c(%eax),%edx
80102d3d:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102d41:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102d43:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d48:	eb 20                	jmp    80102d6a <mpinit+0x4e>
    panic("Expect to run on an SMP");
80102d4a:	83 ec 0c             	sub    $0xc,%esp
80102d4d:	68 fc 6e 10 80       	push   $0x80106efc
80102d52:	e8 f1 d5 ff ff       	call   80100348 <panic>
    switch(*p){
80102d57:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d5c:	eb 0c                	jmp    80102d6a <mpinit+0x4e>
80102d5e:	83 e8 03             	sub    $0x3,%eax
80102d61:	3c 01                	cmp    $0x1,%al
80102d63:	76 1a                	jbe    80102d7f <mpinit+0x63>
80102d65:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d6a:	39 ca                	cmp    %ecx,%edx
80102d6c:	73 4d                	jae    80102dbb <mpinit+0x9f>
    switch(*p){
80102d6e:	0f b6 02             	movzbl (%edx),%eax
80102d71:	3c 02                	cmp    $0x2,%al
80102d73:	74 38                	je     80102dad <mpinit+0x91>
80102d75:	77 e7                	ja     80102d5e <mpinit+0x42>
80102d77:	84 c0                	test   %al,%al
80102d79:	74 09                	je     80102d84 <mpinit+0x68>
80102d7b:	3c 01                	cmp    $0x1,%al
80102d7d:	75 d8                	jne    80102d57 <mpinit+0x3b>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102d7f:	83 c2 08             	add    $0x8,%edx
      continue;
80102d82:	eb e6                	jmp    80102d6a <mpinit+0x4e>
      if(ncpu < NCPU) {
80102d84:	8b 35 84 17 11 80    	mov    0x80111784,%esi
80102d8a:	83 fe 07             	cmp    $0x7,%esi
80102d8d:	7f 19                	jg     80102da8 <mpinit+0x8c>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102d8f:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d93:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102d99:	88 87 a0 17 11 80    	mov    %al,-0x7feee860(%edi)
        ncpu++;
80102d9f:	83 c6 01             	add    $0x1,%esi
80102da2:	89 35 84 17 11 80    	mov    %esi,0x80111784
      p += sizeof(struct mpproc);
80102da8:	83 c2 14             	add    $0x14,%edx
      continue;
80102dab:	eb bd                	jmp    80102d6a <mpinit+0x4e>
      ioapicid = ioapic->apicno;
80102dad:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102db1:	a2 80 17 11 80       	mov    %al,0x80111780
      p += sizeof(struct mpioapic);
80102db6:	83 c2 08             	add    $0x8,%edx
      continue;
80102db9:	eb af                	jmp    80102d6a <mpinit+0x4e>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102dbb:	85 db                	test   %ebx,%ebx
80102dbd:	74 26                	je     80102de5 <mpinit+0xc9>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102dbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102dc2:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102dc6:	74 15                	je     80102ddd <mpinit+0xc1>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102dc8:	b8 70 00 00 00       	mov    $0x70,%eax
80102dcd:	ba 22 00 00 00       	mov    $0x22,%edx
80102dd2:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dd3:	ba 23 00 00 00       	mov    $0x23,%edx
80102dd8:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102dd9:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ddc:	ee                   	out    %al,(%dx)
  }
}
80102ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102de0:	5b                   	pop    %ebx
80102de1:	5e                   	pop    %esi
80102de2:	5f                   	pop    %edi
80102de3:	5d                   	pop    %ebp
80102de4:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102de5:	83 ec 0c             	sub    $0xc,%esp
80102de8:	68 14 6f 10 80       	push   $0x80106f14
80102ded:	e8 56 d5 ff ff       	call   80100348 <panic>

80102df2 <picinit>:
80102df2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102df7:	ba 21 00 00 00       	mov    $0x21,%edx
80102dfc:	ee                   	out    %al,(%dx)
80102dfd:	ba a1 00 00 00       	mov    $0xa1,%edx
80102e02:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102e03:	c3                   	ret    

80102e04 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102e04:	55                   	push   %ebp
80102e05:	89 e5                	mov    %esp,%ebp
80102e07:	57                   	push   %edi
80102e08:	56                   	push   %esi
80102e09:	53                   	push   %ebx
80102e0a:	83 ec 0c             	sub    $0xc,%esp
80102e0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e10:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102e13:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102e19:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102e1f:	e8 f9 dd ff ff       	call   80100c1d <filealloc>
80102e24:	89 03                	mov    %eax,(%ebx)
80102e26:	85 c0                	test   %eax,%eax
80102e28:	0f 84 88 00 00 00    	je     80102eb6 <pipealloc+0xb2>
80102e2e:	e8 ea dd ff ff       	call   80100c1d <filealloc>
80102e33:	89 06                	mov    %eax,(%esi)
80102e35:	85 c0                	test   %eax,%eax
80102e37:	74 7d                	je     80102eb6 <pipealloc+0xb2>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102e39:	e8 8b f2 ff ff       	call   801020c9 <kalloc>
80102e3e:	89 c7                	mov    %eax,%edi
80102e40:	85 c0                	test   %eax,%eax
80102e42:	74 72                	je     80102eb6 <pipealloc+0xb2>
    goto bad;
  p->readopen = 1;
80102e44:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102e4b:	00 00 00 
  p->writeopen = 1;
80102e4e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102e55:	00 00 00 
  p->nwrite = 0;
80102e58:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102e5f:	00 00 00 
  p->nread = 0;
80102e62:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102e69:	00 00 00 
  initlock(&p->lock, "pipe");
80102e6c:	83 ec 08             	sub    $0x8,%esp
80102e6f:	68 33 6f 10 80       	push   $0x80106f33
80102e74:	50                   	push   %eax
80102e75:	e8 58 0e 00 00       	call   80103cd2 <initlock>
  (*f0)->type = FD_PIPE;
80102e7a:	8b 03                	mov    (%ebx),%eax
80102e7c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102e82:	8b 03                	mov    (%ebx),%eax
80102e84:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102e88:	8b 03                	mov    (%ebx),%eax
80102e8a:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102e8e:	8b 03                	mov    (%ebx),%eax
80102e90:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102e93:	8b 06                	mov    (%esi),%eax
80102e95:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102e9b:	8b 06                	mov    (%esi),%eax
80102e9d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102ea1:	8b 06                	mov    (%esi),%eax
80102ea3:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102ea7:	8b 06                	mov    (%esi),%eax
80102ea9:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102eac:	83 c4 10             	add    $0x10,%esp
80102eaf:	b8 00 00 00 00       	mov    $0x0,%eax
80102eb4:	eb 29                	jmp    80102edf <pipealloc+0xdb>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102eb6:	8b 03                	mov    (%ebx),%eax
80102eb8:	85 c0                	test   %eax,%eax
80102eba:	74 0c                	je     80102ec8 <pipealloc+0xc4>
    fileclose(*f0);
80102ebc:	83 ec 0c             	sub    $0xc,%esp
80102ebf:	50                   	push   %eax
80102ec0:	e8 fe dd ff ff       	call   80100cc3 <fileclose>
80102ec5:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102ec8:	8b 06                	mov    (%esi),%eax
80102eca:	85 c0                	test   %eax,%eax
80102ecc:	74 19                	je     80102ee7 <pipealloc+0xe3>
    fileclose(*f1);
80102ece:	83 ec 0c             	sub    $0xc,%esp
80102ed1:	50                   	push   %eax
80102ed2:	e8 ec dd ff ff       	call   80100cc3 <fileclose>
80102ed7:	83 c4 10             	add    $0x10,%esp
  return -1;
80102eda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102ee2:	5b                   	pop    %ebx
80102ee3:	5e                   	pop    %esi
80102ee4:	5f                   	pop    %edi
80102ee5:	5d                   	pop    %ebp
80102ee6:	c3                   	ret    
  return -1;
80102ee7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102eec:	eb f1                	jmp    80102edf <pipealloc+0xdb>

80102eee <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102eee:	55                   	push   %ebp
80102eef:	89 e5                	mov    %esp,%ebp
80102ef1:	53                   	push   %ebx
80102ef2:	83 ec 10             	sub    $0x10,%esp
80102ef5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102ef8:	53                   	push   %ebx
80102ef9:	e8 10 0f 00 00       	call   80103e0e <acquire>
  if(writable){
80102efe:	83 c4 10             	add    $0x10,%esp
80102f01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102f05:	74 3f                	je     80102f46 <pipeclose+0x58>
    p->writeopen = 0;
80102f07:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102f0e:	00 00 00 
    wakeup(&p->nread);
80102f11:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f17:	83 ec 0c             	sub    $0xc,%esp
80102f1a:	50                   	push   %eax
80102f1b:	e8 99 09 00 00       	call   801038b9 <wakeup>
80102f20:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102f23:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f2a:	75 09                	jne    80102f35 <pipeclose+0x47>
80102f2c:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102f33:	74 2f                	je     80102f64 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102f35:	83 ec 0c             	sub    $0xc,%esp
80102f38:	53                   	push   %ebx
80102f39:	e8 35 0f 00 00       	call   80103e73 <release>
80102f3e:	83 c4 10             	add    $0x10,%esp
}
80102f41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102f44:	c9                   	leave  
80102f45:	c3                   	ret    
    p->readopen = 0;
80102f46:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102f4d:	00 00 00 
    wakeup(&p->nwrite);
80102f50:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f56:	83 ec 0c             	sub    $0xc,%esp
80102f59:	50                   	push   %eax
80102f5a:	e8 5a 09 00 00       	call   801038b9 <wakeup>
80102f5f:	83 c4 10             	add    $0x10,%esp
80102f62:	eb bf                	jmp    80102f23 <pipeclose+0x35>
    release(&p->lock);
80102f64:	83 ec 0c             	sub    $0xc,%esp
80102f67:	53                   	push   %ebx
80102f68:	e8 06 0f 00 00       	call   80103e73 <release>
    kfree((char*)p);
80102f6d:	89 1c 24             	mov    %ebx,(%esp)
80102f70:	e8 17 f0 ff ff       	call   80101f8c <kfree>
80102f75:	83 c4 10             	add    $0x10,%esp
80102f78:	eb c7                	jmp    80102f41 <pipeclose+0x53>

80102f7a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102f7a:	55                   	push   %ebp
80102f7b:	89 e5                	mov    %esp,%ebp
80102f7d:	57                   	push   %edi
80102f7e:	56                   	push   %esi
80102f7f:	53                   	push   %ebx
80102f80:	83 ec 18             	sub    $0x18,%esp
80102f83:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102f86:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  acquire(&p->lock);
80102f89:	53                   	push   %ebx
80102f8a:	e8 7f 0e 00 00       	call   80103e0e <acquire>
  for(i = 0; i < n; i++){
80102f8f:	83 c4 10             	add    $0x10,%esp
80102f92:	bf 00 00 00 00       	mov    $0x0,%edi
80102f97:	39 f7                	cmp    %esi,%edi
80102f99:	7c 40                	jl     80102fdb <pipewrite+0x61>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102f9b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fa1:	83 ec 0c             	sub    $0xc,%esp
80102fa4:	50                   	push   %eax
80102fa5:	e8 0f 09 00 00       	call   801038b9 <wakeup>
  release(&p->lock);
80102faa:	89 1c 24             	mov    %ebx,(%esp)
80102fad:	e8 c1 0e 00 00       	call   80103e73 <release>
  return n;
80102fb2:	83 c4 10             	add    $0x10,%esp
80102fb5:	89 f0                	mov    %esi,%eax
80102fb7:	eb 5c                	jmp    80103015 <pipewrite+0x9b>
      wakeup(&p->nread);
80102fb9:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fbf:	83 ec 0c             	sub    $0xc,%esp
80102fc2:	50                   	push   %eax
80102fc3:	e8 f1 08 00 00       	call   801038b9 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102fc8:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102fce:	83 c4 08             	add    $0x8,%esp
80102fd1:	53                   	push   %ebx
80102fd2:	50                   	push   %eax
80102fd3:	e8 7c 07 00 00       	call   80103754 <sleep>
80102fd8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102fdb:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102fe1:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102fe7:	05 00 02 00 00       	add    $0x200,%eax
80102fec:	39 c2                	cmp    %eax,%edx
80102fee:	75 2d                	jne    8010301d <pipewrite+0xa3>
      if(p->readopen == 0 || myproc()->killed){
80102ff0:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102ff7:	74 0b                	je     80103004 <pipewrite+0x8a>
80102ff9:	e8 b4 02 00 00       	call   801032b2 <myproc>
80102ffe:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103002:	74 b5                	je     80102fb9 <pipewrite+0x3f>
        release(&p->lock);
80103004:	83 ec 0c             	sub    $0xc,%esp
80103007:	53                   	push   %ebx
80103008:	e8 66 0e 00 00       	call   80103e73 <release>
        return -1;
8010300d:	83 c4 10             	add    $0x10,%esp
80103010:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103015:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103018:	5b                   	pop    %ebx
80103019:	5e                   	pop    %esi
8010301a:	5f                   	pop    %edi
8010301b:	5d                   	pop    %ebp
8010301c:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010301d:	8d 42 01             	lea    0x1(%edx),%eax
80103020:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103026:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010302c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010302f:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80103033:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103037:	83 c7 01             	add    $0x1,%edi
8010303a:	e9 58 ff ff ff       	jmp    80102f97 <pipewrite+0x1d>

8010303f <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010303f:	55                   	push   %ebp
80103040:	89 e5                	mov    %esp,%ebp
80103042:	57                   	push   %edi
80103043:	56                   	push   %esi
80103044:	53                   	push   %ebx
80103045:	83 ec 18             	sub    $0x18,%esp
80103048:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010304b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
8010304e:	53                   	push   %ebx
8010304f:	e8 ba 0d 00 00       	call   80103e0e <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103054:	83 c4 10             	add    $0x10,%esp
80103057:	eb 13                	jmp    8010306c <piperead+0x2d>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103059:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010305f:	83 ec 08             	sub    $0x8,%esp
80103062:	53                   	push   %ebx
80103063:	50                   	push   %eax
80103064:	e8 eb 06 00 00       	call   80103754 <sleep>
80103069:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010306c:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103072:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80103078:	75 78                	jne    801030f2 <piperead+0xb3>
8010307a:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103080:	85 f6                	test   %esi,%esi
80103082:	74 37                	je     801030bb <piperead+0x7c>
    if(myproc()->killed){
80103084:	e8 29 02 00 00       	call   801032b2 <myproc>
80103089:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010308d:	74 ca                	je     80103059 <piperead+0x1a>
      release(&p->lock);
8010308f:	83 ec 0c             	sub    $0xc,%esp
80103092:	53                   	push   %ebx
80103093:	e8 db 0d 00 00       	call   80103e73 <release>
      return -1;
80103098:	83 c4 10             	add    $0x10,%esp
8010309b:	be ff ff ff ff       	mov    $0xffffffff,%esi
801030a0:	eb 46                	jmp    801030e8 <piperead+0xa9>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801030a2:	8d 50 01             	lea    0x1(%eax),%edx
801030a5:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
801030ab:	25 ff 01 00 00       	and    $0x1ff,%eax
801030b0:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
801030b5:	88 04 37             	mov    %al,(%edi,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801030b8:	83 c6 01             	add    $0x1,%esi
801030bb:	3b 75 10             	cmp    0x10(%ebp),%esi
801030be:	7d 0e                	jge    801030ce <piperead+0x8f>
    if(p->nread == p->nwrite)
801030c0:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801030c6:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
801030cc:	75 d4                	jne    801030a2 <piperead+0x63>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801030ce:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801030d4:	83 ec 0c             	sub    $0xc,%esp
801030d7:	50                   	push   %eax
801030d8:	e8 dc 07 00 00       	call   801038b9 <wakeup>
  release(&p->lock);
801030dd:	89 1c 24             	mov    %ebx,(%esp)
801030e0:	e8 8e 0d 00 00       	call   80103e73 <release>
  return i;
801030e5:	83 c4 10             	add    $0x10,%esp
}
801030e8:	89 f0                	mov    %esi,%eax
801030ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030ed:	5b                   	pop    %ebx
801030ee:	5e                   	pop    %esi
801030ef:	5f                   	pop    %edi
801030f0:	5d                   	pop    %ebp
801030f1:	c3                   	ret    
801030f2:	be 00 00 00 00       	mov    $0x0,%esi
801030f7:	eb c2                	jmp    801030bb <piperead+0x7c>

801030f9 <wakeup1>:
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030f9:	ba 54 1d 11 80       	mov    $0x80111d54,%edx
801030fe:	eb 03                	jmp    80103103 <wakeup1+0xa>
80103100:	83 c2 7c             	add    $0x7c,%edx
80103103:	81 fa 54 3c 11 80    	cmp    $0x80113c54,%edx
80103109:	73 14                	jae    8010311f <wakeup1+0x26>
    if(p->state == SLEEPING && p->chan == chan)
8010310b:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010310f:	75 ef                	jne    80103100 <wakeup1+0x7>
80103111:	39 42 20             	cmp    %eax,0x20(%edx)
80103114:	75 ea                	jne    80103100 <wakeup1+0x7>
      p->state = RUNNABLE;
80103116:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010311d:	eb e1                	jmp    80103100 <wakeup1+0x7>
}
8010311f:	c3                   	ret    

80103120 <allocproc>:
{
80103120:	55                   	push   %ebp
80103121:	89 e5                	mov    %esp,%ebp
80103123:	53                   	push   %ebx
80103124:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103127:	68 20 1d 11 80       	push   $0x80111d20
8010312c:	e8 dd 0c 00 00       	call   80103e0e <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103131:	83 c4 10             	add    $0x10,%esp
80103134:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103139:	eb 03                	jmp    8010313e <allocproc+0x1e>
8010313b:	83 c3 7c             	add    $0x7c,%ebx
8010313e:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103144:	73 76                	jae    801031bc <allocproc+0x9c>
    if(p->state == UNUSED)
80103146:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
8010314a:	75 ef                	jne    8010313b <allocproc+0x1b>
  p->state = EMBRYO;
8010314c:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103153:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80103158:	8d 50 01             	lea    0x1(%eax),%edx
8010315b:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80103161:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
80103164:	83 ec 0c             	sub    $0xc,%esp
80103167:	68 20 1d 11 80       	push   $0x80111d20
8010316c:	e8 02 0d 00 00       	call   80103e73 <release>
  if((p->kstack = kalloc()) == 0){
80103171:	e8 53 ef ff ff       	call   801020c9 <kalloc>
80103176:	89 43 08             	mov    %eax,0x8(%ebx)
80103179:	83 c4 10             	add    $0x10,%esp
8010317c:	85 c0                	test   %eax,%eax
8010317e:	74 53                	je     801031d3 <allocproc+0xb3>
  sp -= sizeof *p->tf;
80103180:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103186:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103189:	c7 80 b0 0f 00 00 3b 	movl   $0x80104f3b,0xfb0(%eax)
80103190:	4f 10 80 
  sp -= sizeof *p->context;
80103193:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103198:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010319b:	83 ec 04             	sub    $0x4,%esp
8010319e:	6a 14                	push   $0x14
801031a0:	6a 00                	push   $0x0
801031a2:	50                   	push   %eax
801031a3:	e8 12 0d 00 00       	call   80103eba <memset>
  p->context->eip = (uint)forkret;
801031a8:	8b 43 1c             	mov    0x1c(%ebx),%eax
801031ab:	c7 40 10 de 31 10 80 	movl   $0x801031de,0x10(%eax)
  return p;
801031b2:	83 c4 10             	add    $0x10,%esp
}
801031b5:	89 d8                	mov    %ebx,%eax
801031b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801031ba:	c9                   	leave  
801031bb:	c3                   	ret    
  release(&ptable.lock);
801031bc:	83 ec 0c             	sub    $0xc,%esp
801031bf:	68 20 1d 11 80       	push   $0x80111d20
801031c4:	e8 aa 0c 00 00       	call   80103e73 <release>
  return 0;
801031c9:	83 c4 10             	add    $0x10,%esp
801031cc:	bb 00 00 00 00       	mov    $0x0,%ebx
801031d1:	eb e2                	jmp    801031b5 <allocproc+0x95>
    p->state = UNUSED;
801031d3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801031da:	89 c3                	mov    %eax,%ebx
801031dc:	eb d7                	jmp    801031b5 <allocproc+0x95>

801031de <forkret>:
{
801031de:	55                   	push   %ebp
801031df:	89 e5                	mov    %esp,%ebp
801031e1:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
801031e4:	68 20 1d 11 80       	push   $0x80111d20
801031e9:	e8 85 0c 00 00       	call   80103e73 <release>
  if (first) {
801031ee:	83 c4 10             	add    $0x10,%esp
801031f1:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
801031f8:	75 02                	jne    801031fc <forkret+0x1e>
}
801031fa:	c9                   	leave  
801031fb:	c3                   	ret    
    first = 0;
801031fc:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103203:	00 00 00 
    iinit(ROOTDEV);
80103206:	83 ec 0c             	sub    $0xc,%esp
80103209:	6a 01                	push   $0x1
8010320b:	e8 ca e0 ff ff       	call   801012da <iinit>
    initlog(ROOTDEV);
80103210:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103217:	e8 e3 f5 ff ff       	call   801027ff <initlog>
8010321c:	83 c4 10             	add    $0x10,%esp
}
8010321f:	eb d9                	jmp    801031fa <forkret+0x1c>

80103221 <pinit>:
{
80103221:	55                   	push   %ebp
80103222:	89 e5                	mov    %esp,%ebp
80103224:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103227:	68 38 6f 10 80       	push   $0x80106f38
8010322c:	68 20 1d 11 80       	push   $0x80111d20
80103231:	e8 9c 0a 00 00       	call   80103cd2 <initlock>
}
80103236:	83 c4 10             	add    $0x10,%esp
80103239:	c9                   	leave  
8010323a:	c3                   	ret    

8010323b <mycpu>:
{
8010323b:	55                   	push   %ebp
8010323c:	89 e5                	mov    %esp,%ebp
8010323e:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103241:	9c                   	pushf  
80103242:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103243:	f6 c4 02             	test   $0x2,%ah
80103246:	75 28                	jne    80103270 <mycpu+0x35>
  apicid = lapicid();
80103248:	e8 dd f1 ff ff       	call   8010242a <lapicid>
  for (i = 0; i < ncpu; ++i) {
8010324d:	ba 00 00 00 00       	mov    $0x0,%edx
80103252:	39 15 84 17 11 80    	cmp    %edx,0x80111784
80103258:	7e 23                	jle    8010327d <mycpu+0x42>
    if (cpus[i].apicid == apicid)
8010325a:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103260:	0f b6 89 a0 17 11 80 	movzbl -0x7feee860(%ecx),%ecx
80103267:	39 c1                	cmp    %eax,%ecx
80103269:	74 1f                	je     8010328a <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
8010326b:	83 c2 01             	add    $0x1,%edx
8010326e:	eb e2                	jmp    80103252 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103270:	83 ec 0c             	sub    $0xc,%esp
80103273:	68 54 70 10 80       	push   $0x80107054
80103278:	e8 cb d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
8010327d:	83 ec 0c             	sub    $0xc,%esp
80103280:	68 3f 6f 10 80       	push   $0x80106f3f
80103285:	e8 be d0 ff ff       	call   80100348 <panic>
      return &cpus[i];
8010328a:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103290:	05 a0 17 11 80       	add    $0x801117a0,%eax
}
80103295:	c9                   	leave  
80103296:	c3                   	ret    

80103297 <cpuid>:
cpuid() {
80103297:	55                   	push   %ebp
80103298:	89 e5                	mov    %esp,%ebp
8010329a:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010329d:	e8 99 ff ff ff       	call   8010323b <mycpu>
801032a2:	2d a0 17 11 80       	sub    $0x801117a0,%eax
801032a7:	c1 f8 04             	sar    $0x4,%eax
801032aa:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801032b0:	c9                   	leave  
801032b1:	c3                   	ret    

801032b2 <myproc>:
myproc(void) {
801032b2:	55                   	push   %ebp
801032b3:	89 e5                	mov    %esp,%ebp
801032b5:	53                   	push   %ebx
801032b6:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801032b9:	e8 75 0a 00 00       	call   80103d33 <pushcli>
  c = mycpu();
801032be:	e8 78 ff ff ff       	call   8010323b <mycpu>
  p = c->proc;
801032c3:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801032c9:	e8 a1 0a 00 00       	call   80103d6f <popcli>
}
801032ce:	89 d8                	mov    %ebx,%eax
801032d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801032d3:	c9                   	leave  
801032d4:	c3                   	ret    

801032d5 <userinit>:
{
801032d5:	55                   	push   %ebp
801032d6:	89 e5                	mov    %esp,%ebp
801032d8:	53                   	push   %ebx
801032d9:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801032dc:	e8 3f fe ff ff       	call   80103120 <allocproc>
801032e1:	89 c3                	mov    %eax,%ebx
  initproc = p;
801032e3:	a3 54 3c 11 80       	mov    %eax,0x80113c54
  if((p->pgdir = setupkvm()) == 0)
801032e8:	e8 b6 33 00 00       	call   801066a3 <setupkvm>
801032ed:	89 43 04             	mov    %eax,0x4(%ebx)
801032f0:	85 c0                	test   %eax,%eax
801032f2:	0f 84 b8 00 00 00    	je     801033b0 <userinit+0xdb>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801032f8:	83 ec 04             	sub    $0x4,%esp
801032fb:	68 2c 00 00 00       	push   $0x2c
80103300:	68 60 a4 10 80       	push   $0x8010a460
80103305:	50                   	push   %eax
80103306:	e8 36 30 00 00       	call   80106341 <inituvm>
  p->sz = PGSIZE;
8010330b:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103311:	8b 43 18             	mov    0x18(%ebx),%eax
80103314:	83 c4 0c             	add    $0xc,%esp
80103317:	6a 4c                	push   $0x4c
80103319:	6a 00                	push   $0x0
8010331b:	50                   	push   %eax
8010331c:	e8 99 0b 00 00       	call   80103eba <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103321:	8b 43 18             	mov    0x18(%ebx),%eax
80103324:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010332a:	8b 43 18             	mov    0x18(%ebx),%eax
8010332d:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103333:	8b 43 18             	mov    0x18(%ebx),%eax
80103336:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010333a:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010333e:	8b 43 18             	mov    0x18(%ebx),%eax
80103341:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103345:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103349:	8b 43 18             	mov    0x18(%ebx),%eax
8010334c:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103353:	8b 43 18             	mov    0x18(%ebx),%eax
80103356:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010335d:	8b 43 18             	mov    0x18(%ebx),%eax
80103360:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103367:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010336a:	83 c4 0c             	add    $0xc,%esp
8010336d:	6a 10                	push   $0x10
8010336f:	68 68 6f 10 80       	push   $0x80106f68
80103374:	50                   	push   %eax
80103375:	e8 ac 0c 00 00       	call   80104026 <safestrcpy>
  p->cwd = namei("/");
8010337a:	c7 04 24 71 6f 10 80 	movl   $0x80106f71,(%esp)
80103381:	e8 47 e8 ff ff       	call   80101bcd <namei>
80103386:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103389:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103390:	e8 79 0a 00 00       	call   80103e0e <acquire>
  p->state = RUNNABLE;
80103395:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
8010339c:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801033a3:	e8 cb 0a 00 00       	call   80103e73 <release>
}
801033a8:	83 c4 10             	add    $0x10,%esp
801033ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801033ae:	c9                   	leave  
801033af:	c3                   	ret    
    panic("userinit: out of memory?");
801033b0:	83 ec 0c             	sub    $0xc,%esp
801033b3:	68 4f 6f 10 80       	push   $0x80106f4f
801033b8:	e8 8b cf ff ff       	call   80100348 <panic>

801033bd <growproc>:
{
801033bd:	55                   	push   %ebp
801033be:	89 e5                	mov    %esp,%ebp
801033c0:	56                   	push   %esi
801033c1:	53                   	push   %ebx
801033c2:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801033c5:	e8 e8 fe ff ff       	call   801032b2 <myproc>
801033ca:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801033cc:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801033ce:	85 f6                	test   %esi,%esi
801033d0:	7f 1c                	jg     801033ee <growproc+0x31>
  } else if(n < 0){
801033d2:	78 37                	js     8010340b <growproc+0x4e>
  curproc->sz = sz;
801033d4:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801033d6:	83 ec 0c             	sub    $0xc,%esp
801033d9:	53                   	push   %ebx
801033da:	e8 ee 2d 00 00       	call   801061cd <switchuvm>
  return 0;
801033df:	83 c4 10             	add    $0x10,%esp
801033e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801033e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801033ea:	5b                   	pop    %ebx
801033eb:	5e                   	pop    %esi
801033ec:	5d                   	pop    %ebp
801033ed:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033ee:	83 ec 04             	sub    $0x4,%esp
801033f1:	01 c6                	add    %eax,%esi
801033f3:	56                   	push   %esi
801033f4:	50                   	push   %eax
801033f5:	ff 73 04             	push   0x4(%ebx)
801033f8:	e8 22 31 00 00       	call   8010651f <allocuvm>
801033fd:	83 c4 10             	add    $0x10,%esp
80103400:	85 c0                	test   %eax,%eax
80103402:	75 d0                	jne    801033d4 <growproc+0x17>
      return -1;
80103404:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103409:	eb dc                	jmp    801033e7 <growproc+0x2a>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010340b:	83 ec 04             	sub    $0x4,%esp
8010340e:	01 c6                	add    %eax,%esi
80103410:	56                   	push   %esi
80103411:	50                   	push   %eax
80103412:	ff 73 04             	push   0x4(%ebx)
80103415:	e8 5b 30 00 00       	call   80106475 <deallocuvm>
8010341a:	83 c4 10             	add    $0x10,%esp
8010341d:	85 c0                	test   %eax,%eax
8010341f:	75 b3                	jne    801033d4 <growproc+0x17>
      return -1;
80103421:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103426:	eb bf                	jmp    801033e7 <growproc+0x2a>

80103428 <fork>:
{
80103428:	55                   	push   %ebp
80103429:	89 e5                	mov    %esp,%ebp
8010342b:	57                   	push   %edi
8010342c:	56                   	push   %esi
8010342d:	53                   	push   %ebx
8010342e:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103431:	e8 7c fe ff ff       	call   801032b2 <myproc>
80103436:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103438:	e8 e3 fc ff ff       	call   80103120 <allocproc>
8010343d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103440:	85 c0                	test   %eax,%eax
80103442:	0f 84 e0 00 00 00    	je     80103528 <fork+0x100>
80103448:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010344a:	83 ec 08             	sub    $0x8,%esp
8010344d:	ff 33                	push   (%ebx)
8010344f:	ff 73 04             	push   0x4(%ebx)
80103452:	e8 fd 32 00 00       	call   80106754 <copyuvm>
80103457:	89 47 04             	mov    %eax,0x4(%edi)
8010345a:	83 c4 10             	add    $0x10,%esp
8010345d:	85 c0                	test   %eax,%eax
8010345f:	74 2a                	je     8010348b <fork+0x63>
  np->sz = curproc->sz;
80103461:	8b 03                	mov    (%ebx),%eax
80103463:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103466:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
80103468:	89 c8                	mov    %ecx,%eax
8010346a:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
8010346d:	8b 73 18             	mov    0x18(%ebx),%esi
80103470:	8b 79 18             	mov    0x18(%ecx),%edi
80103473:	b9 13 00 00 00       	mov    $0x13,%ecx
80103478:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
8010347a:	8b 40 18             	mov    0x18(%eax),%eax
8010347d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103484:	be 00 00 00 00       	mov    $0x0,%esi
80103489:	eb 29                	jmp    801034b4 <fork+0x8c>
    kfree(np->kstack);
8010348b:	83 ec 0c             	sub    $0xc,%esp
8010348e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103491:	ff 73 08             	push   0x8(%ebx)
80103494:	e8 f3 ea ff ff       	call   80101f8c <kfree>
    np->kstack = 0;
80103499:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
801034a0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
801034a7:	83 c4 10             	add    $0x10,%esp
801034aa:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801034af:	eb 6d                	jmp    8010351e <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
801034b1:	83 c6 01             	add    $0x1,%esi
801034b4:	83 fe 0f             	cmp    $0xf,%esi
801034b7:	7f 1d                	jg     801034d6 <fork+0xae>
    if(curproc->ofile[i])
801034b9:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801034bd:	85 c0                	test   %eax,%eax
801034bf:	74 f0                	je     801034b1 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
801034c1:	83 ec 0c             	sub    $0xc,%esp
801034c4:	50                   	push   %eax
801034c5:	e8 b4 d7 ff ff       	call   80100c7e <filedup>
801034ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034cd:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801034d1:	83 c4 10             	add    $0x10,%esp
801034d4:	eb db                	jmp    801034b1 <fork+0x89>
  np->cwd = idup(curproc->cwd);
801034d6:	83 ec 0c             	sub    $0xc,%esp
801034d9:	ff 73 68             	push   0x68(%ebx)
801034dc:	e8 5e e0 ff ff       	call   8010153f <idup>
801034e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801034e4:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801034e7:	83 c3 6c             	add    $0x6c,%ebx
801034ea:	8d 47 6c             	lea    0x6c(%edi),%eax
801034ed:	83 c4 0c             	add    $0xc,%esp
801034f0:	6a 10                	push   $0x10
801034f2:	53                   	push   %ebx
801034f3:	50                   	push   %eax
801034f4:	e8 2d 0b 00 00       	call   80104026 <safestrcpy>
  pid = np->pid;
801034f9:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801034fc:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103503:	e8 06 09 00 00       	call   80103e0e <acquire>
  np->state = RUNNABLE;
80103508:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
8010350f:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103516:	e8 58 09 00 00       	call   80103e73 <release>
  return pid;
8010351b:	83 c4 10             	add    $0x10,%esp
}
8010351e:	89 d8                	mov    %ebx,%eax
80103520:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103523:	5b                   	pop    %ebx
80103524:	5e                   	pop    %esi
80103525:	5f                   	pop    %edi
80103526:	5d                   	pop    %ebp
80103527:	c3                   	ret    
    return -1;
80103528:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010352d:	eb ef                	jmp    8010351e <fork+0xf6>

8010352f <scheduler>:
{
8010352f:	55                   	push   %ebp
80103530:	89 e5                	mov    %esp,%ebp
80103532:	56                   	push   %esi
80103533:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103534:	e8 02 fd ff ff       	call   8010323b <mycpu>
80103539:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010353b:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103542:	00 00 00 
80103545:	eb 5a                	jmp    801035a1 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103547:	83 c3 7c             	add    $0x7c,%ebx
8010354a:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103550:	73 3f                	jae    80103591 <scheduler+0x62>
      if(p->state != RUNNABLE)
80103552:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103556:	75 ef                	jne    80103547 <scheduler+0x18>
      c->proc = p;
80103558:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010355e:	83 ec 0c             	sub    $0xc,%esp
80103561:	53                   	push   %ebx
80103562:	e8 66 2c 00 00       	call   801061cd <switchuvm>
      p->state = RUNNING;
80103567:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
8010356e:	83 c4 08             	add    $0x8,%esp
80103571:	ff 73 1c             	push   0x1c(%ebx)
80103574:	8d 46 04             	lea    0x4(%esi),%eax
80103577:	50                   	push   %eax
80103578:	e8 fe 0a 00 00       	call   8010407b <swtch>
      switchkvm();
8010357d:	e8 26 2c 00 00       	call   801061a8 <switchkvm>
      c->proc = 0;
80103582:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103589:	00 00 00 
8010358c:	83 c4 10             	add    $0x10,%esp
8010358f:	eb b6                	jmp    80103547 <scheduler+0x18>
    release(&ptable.lock);
80103591:	83 ec 0c             	sub    $0xc,%esp
80103594:	68 20 1d 11 80       	push   $0x80111d20
80103599:	e8 d5 08 00 00       	call   80103e73 <release>
    sti();
8010359e:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
801035a1:	fb                   	sti    
    acquire(&ptable.lock);
801035a2:	83 ec 0c             	sub    $0xc,%esp
801035a5:	68 20 1d 11 80       	push   $0x80111d20
801035aa:	e8 5f 08 00 00       	call   80103e0e <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035af:	83 c4 10             	add    $0x10,%esp
801035b2:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801035b7:	eb 91                	jmp    8010354a <scheduler+0x1b>

801035b9 <sched>:
{
801035b9:	55                   	push   %ebp
801035ba:	89 e5                	mov    %esp,%ebp
801035bc:	56                   	push   %esi
801035bd:	53                   	push   %ebx
  struct proc *p = myproc();
801035be:	e8 ef fc ff ff       	call   801032b2 <myproc>
801035c3:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801035c5:	83 ec 0c             	sub    $0xc,%esp
801035c8:	68 20 1d 11 80       	push   $0x80111d20
801035cd:	e8 fd 07 00 00       	call   80103dcf <holding>
801035d2:	83 c4 10             	add    $0x10,%esp
801035d5:	85 c0                	test   %eax,%eax
801035d7:	74 4f                	je     80103628 <sched+0x6f>
  if(mycpu()->ncli != 1)
801035d9:	e8 5d fc ff ff       	call   8010323b <mycpu>
801035de:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801035e5:	75 4e                	jne    80103635 <sched+0x7c>
  if(p->state == RUNNING)
801035e7:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801035eb:	74 55                	je     80103642 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801035ed:	9c                   	pushf  
801035ee:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801035ef:	f6 c4 02             	test   $0x2,%ah
801035f2:	75 5b                	jne    8010364f <sched+0x96>
  intena = mycpu()->intena;
801035f4:	e8 42 fc ff ff       	call   8010323b <mycpu>
801035f9:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801035ff:	e8 37 fc ff ff       	call   8010323b <mycpu>
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	ff 70 04             	push   0x4(%eax)
8010360a:	83 c3 1c             	add    $0x1c,%ebx
8010360d:	53                   	push   %ebx
8010360e:	e8 68 0a 00 00       	call   8010407b <swtch>
  mycpu()->intena = intena;
80103613:	e8 23 fc ff ff       	call   8010323b <mycpu>
80103618:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010361e:	83 c4 10             	add    $0x10,%esp
80103621:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103624:	5b                   	pop    %ebx
80103625:	5e                   	pop    %esi
80103626:	5d                   	pop    %ebp
80103627:	c3                   	ret    
    panic("sched ptable.lock");
80103628:	83 ec 0c             	sub    $0xc,%esp
8010362b:	68 73 6f 10 80       	push   $0x80106f73
80103630:	e8 13 cd ff ff       	call   80100348 <panic>
    panic("sched locks");
80103635:	83 ec 0c             	sub    $0xc,%esp
80103638:	68 85 6f 10 80       	push   $0x80106f85
8010363d:	e8 06 cd ff ff       	call   80100348 <panic>
    panic("sched running");
80103642:	83 ec 0c             	sub    $0xc,%esp
80103645:	68 91 6f 10 80       	push   $0x80106f91
8010364a:	e8 f9 cc ff ff       	call   80100348 <panic>
    panic("sched interruptible");
8010364f:	83 ec 0c             	sub    $0xc,%esp
80103652:	68 9f 6f 10 80       	push   $0x80106f9f
80103657:	e8 ec cc ff ff       	call   80100348 <panic>

8010365c <exit>:
{
8010365c:	55                   	push   %ebp
8010365d:	89 e5                	mov    %esp,%ebp
8010365f:	56                   	push   %esi
80103660:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103661:	e8 4c fc ff ff       	call   801032b2 <myproc>
  if(curproc == initproc)
80103666:	39 05 54 3c 11 80    	cmp    %eax,0x80113c54
8010366c:	74 09                	je     80103677 <exit+0x1b>
8010366e:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103670:	bb 00 00 00 00       	mov    $0x0,%ebx
80103675:	eb 24                	jmp    8010369b <exit+0x3f>
    panic("init exiting");
80103677:	83 ec 0c             	sub    $0xc,%esp
8010367a:	68 b3 6f 10 80       	push   $0x80106fb3
8010367f:	e8 c4 cc ff ff       	call   80100348 <panic>
      fileclose(curproc->ofile[fd]);
80103684:	83 ec 0c             	sub    $0xc,%esp
80103687:	50                   	push   %eax
80103688:	e8 36 d6 ff ff       	call   80100cc3 <fileclose>
      curproc->ofile[fd] = 0;
8010368d:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103694:	00 
80103695:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103698:	83 c3 01             	add    $0x1,%ebx
8010369b:	83 fb 0f             	cmp    $0xf,%ebx
8010369e:	7f 0a                	jg     801036aa <exit+0x4e>
    if(curproc->ofile[fd]){
801036a0:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801036a4:	85 c0                	test   %eax,%eax
801036a6:	75 dc                	jne    80103684 <exit+0x28>
801036a8:	eb ee                	jmp    80103698 <exit+0x3c>
  begin_op();
801036aa:	e8 99 f1 ff ff       	call   80102848 <begin_op>
  iput(curproc->cwd);
801036af:	83 ec 0c             	sub    $0xc,%esp
801036b2:	ff 76 68             	push   0x68(%esi)
801036b5:	e8 bc df ff ff       	call   80101676 <iput>
  end_op();
801036ba:	e8 03 f2 ff ff       	call   801028c2 <end_op>
  curproc->cwd = 0;
801036bf:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801036c6:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801036cd:	e8 3c 07 00 00       	call   80103e0e <acquire>
  wakeup1(curproc->parent);
801036d2:	8b 46 14             	mov    0x14(%esi),%eax
801036d5:	e8 1f fa ff ff       	call   801030f9 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036da:	83 c4 10             	add    $0x10,%esp
801036dd:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801036e2:	eb 03                	jmp    801036e7 <exit+0x8b>
801036e4:	83 c3 7c             	add    $0x7c,%ebx
801036e7:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
801036ed:	73 1a                	jae    80103709 <exit+0xad>
    if(p->parent == curproc){
801036ef:	39 73 14             	cmp    %esi,0x14(%ebx)
801036f2:	75 f0                	jne    801036e4 <exit+0x88>
      p->parent = initproc;
801036f4:	a1 54 3c 11 80       	mov    0x80113c54,%eax
801036f9:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801036fc:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103700:	75 e2                	jne    801036e4 <exit+0x88>
        wakeup1(initproc);
80103702:	e8 f2 f9 ff ff       	call   801030f9 <wakeup1>
80103707:	eb db                	jmp    801036e4 <exit+0x88>
  curproc->state = ZOMBIE;
80103709:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103710:	e8 a4 fe ff ff       	call   801035b9 <sched>
  panic("zombie exit");
80103715:	83 ec 0c             	sub    $0xc,%esp
80103718:	68 c0 6f 10 80       	push   $0x80106fc0
8010371d:	e8 26 cc ff ff       	call   80100348 <panic>

80103722 <yield>:
{
80103722:	55                   	push   %ebp
80103723:	89 e5                	mov    %esp,%ebp
80103725:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103728:	68 20 1d 11 80       	push   $0x80111d20
8010372d:	e8 dc 06 00 00       	call   80103e0e <acquire>
  myproc()->state = RUNNABLE;
80103732:	e8 7b fb ff ff       	call   801032b2 <myproc>
80103737:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010373e:	e8 76 fe ff ff       	call   801035b9 <sched>
  release(&ptable.lock);
80103743:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010374a:	e8 24 07 00 00       	call   80103e73 <release>
}
8010374f:	83 c4 10             	add    $0x10,%esp
80103752:	c9                   	leave  
80103753:	c3                   	ret    

80103754 <sleep>:
{
80103754:	55                   	push   %ebp
80103755:	89 e5                	mov    %esp,%ebp
80103757:	56                   	push   %esi
80103758:	53                   	push   %ebx
80103759:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
8010375c:	e8 51 fb ff ff       	call   801032b2 <myproc>
  if(p == 0)
80103761:	85 c0                	test   %eax,%eax
80103763:	74 66                	je     801037cb <sleep+0x77>
80103765:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
80103767:	85 f6                	test   %esi,%esi
80103769:	74 6d                	je     801037d8 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010376b:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
80103771:	74 18                	je     8010378b <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103773:	83 ec 0c             	sub    $0xc,%esp
80103776:	68 20 1d 11 80       	push   $0x80111d20
8010377b:	e8 8e 06 00 00       	call   80103e0e <acquire>
    release(lk);
80103780:	89 34 24             	mov    %esi,(%esp)
80103783:	e8 eb 06 00 00       	call   80103e73 <release>
80103788:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010378b:	8b 45 08             	mov    0x8(%ebp),%eax
8010378e:	89 43 20             	mov    %eax,0x20(%ebx)
  p->state = SLEEPING;
80103791:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80103798:	e8 1c fe ff ff       	call   801035b9 <sched>
  p->chan = 0;
8010379d:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801037a4:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
801037aa:	74 18                	je     801037c4 <sleep+0x70>
    release(&ptable.lock);
801037ac:	83 ec 0c             	sub    $0xc,%esp
801037af:	68 20 1d 11 80       	push   $0x80111d20
801037b4:	e8 ba 06 00 00       	call   80103e73 <release>
    acquire(lk);
801037b9:	89 34 24             	mov    %esi,(%esp)
801037bc:	e8 4d 06 00 00       	call   80103e0e <acquire>
801037c1:	83 c4 10             	add    $0x10,%esp
}
801037c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801037c7:	5b                   	pop    %ebx
801037c8:	5e                   	pop    %esi
801037c9:	5d                   	pop    %ebp
801037ca:	c3                   	ret    
    panic("sleep");
801037cb:	83 ec 0c             	sub    $0xc,%esp
801037ce:	68 cc 6f 10 80       	push   $0x80106fcc
801037d3:	e8 70 cb ff ff       	call   80100348 <panic>
    panic("sleep without lk");
801037d8:	83 ec 0c             	sub    $0xc,%esp
801037db:	68 d2 6f 10 80       	push   $0x80106fd2
801037e0:	e8 63 cb ff ff       	call   80100348 <panic>

801037e5 <wait>:
{
801037e5:	55                   	push   %ebp
801037e6:	89 e5                	mov    %esp,%ebp
801037e8:	56                   	push   %esi
801037e9:	53                   	push   %ebx
  struct proc *curproc = myproc();
801037ea:	e8 c3 fa ff ff       	call   801032b2 <myproc>
801037ef:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801037f1:	83 ec 0c             	sub    $0xc,%esp
801037f4:	68 20 1d 11 80       	push   $0x80111d20
801037f9:	e8 10 06 00 00       	call   80103e0e <acquire>
801037fe:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103801:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103806:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010380b:	eb 5b                	jmp    80103868 <wait+0x83>
        pid = p->pid;
8010380d:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103810:	83 ec 0c             	sub    $0xc,%esp
80103813:	ff 73 08             	push   0x8(%ebx)
80103816:	e8 71 e7 ff ff       	call   80101f8c <kfree>
        p->kstack = 0;
8010381b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103822:	83 c4 04             	add    $0x4,%esp
80103825:	ff 73 04             	push   0x4(%ebx)
80103828:	e8 f4 2d 00 00       	call   80106621 <freevm>
        p->pid = 0;
8010382d:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103834:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010383b:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
8010383f:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103846:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
8010384d:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103854:	e8 1a 06 00 00       	call   80103e73 <release>
        return pid;
80103859:	83 c4 10             	add    $0x10,%esp
}
8010385c:	89 f0                	mov    %esi,%eax
8010385e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103861:	5b                   	pop    %ebx
80103862:	5e                   	pop    %esi
80103863:	5d                   	pop    %ebp
80103864:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103865:	83 c3 7c             	add    $0x7c,%ebx
80103868:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
8010386e:	73 12                	jae    80103882 <wait+0x9d>
      if(p->parent != curproc)
80103870:	39 73 14             	cmp    %esi,0x14(%ebx)
80103873:	75 f0                	jne    80103865 <wait+0x80>
      if(p->state == ZOMBIE){
80103875:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103879:	74 92                	je     8010380d <wait+0x28>
      havekids = 1;
8010387b:	b8 01 00 00 00       	mov    $0x1,%eax
80103880:	eb e3                	jmp    80103865 <wait+0x80>
    if(!havekids || curproc->killed){
80103882:	85 c0                	test   %eax,%eax
80103884:	74 06                	je     8010388c <wait+0xa7>
80103886:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
8010388a:	74 17                	je     801038a3 <wait+0xbe>
      release(&ptable.lock);
8010388c:	83 ec 0c             	sub    $0xc,%esp
8010388f:	68 20 1d 11 80       	push   $0x80111d20
80103894:	e8 da 05 00 00       	call   80103e73 <release>
      return -1;
80103899:	83 c4 10             	add    $0x10,%esp
8010389c:	be ff ff ff ff       	mov    $0xffffffff,%esi
801038a1:	eb b9                	jmp    8010385c <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801038a3:	83 ec 08             	sub    $0x8,%esp
801038a6:	68 20 1d 11 80       	push   $0x80111d20
801038ab:	56                   	push   %esi
801038ac:	e8 a3 fe ff ff       	call   80103754 <sleep>
    havekids = 0;
801038b1:	83 c4 10             	add    $0x10,%esp
801038b4:	e9 48 ff ff ff       	jmp    80103801 <wait+0x1c>

801038b9 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801038b9:	55                   	push   %ebp
801038ba:	89 e5                	mov    %esp,%ebp
801038bc:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801038bf:	68 20 1d 11 80       	push   $0x80111d20
801038c4:	e8 45 05 00 00       	call   80103e0e <acquire>
  wakeup1(chan);
801038c9:	8b 45 08             	mov    0x8(%ebp),%eax
801038cc:	e8 28 f8 ff ff       	call   801030f9 <wakeup1>
  release(&ptable.lock);
801038d1:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801038d8:	e8 96 05 00 00       	call   80103e73 <release>
}
801038dd:	83 c4 10             	add    $0x10,%esp
801038e0:	c9                   	leave  
801038e1:	c3                   	ret    

801038e2 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801038e2:	55                   	push   %ebp
801038e3:	89 e5                	mov    %esp,%ebp
801038e5:	53                   	push   %ebx
801038e6:	83 ec 10             	sub    $0x10,%esp
801038e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801038ec:	68 20 1d 11 80       	push   $0x80111d20
801038f1:	e8 18 05 00 00       	call   80103e0e <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038f6:	83 c4 10             	add    $0x10,%esp
801038f9:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
801038fe:	eb 0c                	jmp    8010390c <kill+0x2a>
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
80103900:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103907:	eb 1c                	jmp    80103925 <kill+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103909:	83 c0 7c             	add    $0x7c,%eax
8010390c:	3d 54 3c 11 80       	cmp    $0x80113c54,%eax
80103911:	73 2c                	jae    8010393f <kill+0x5d>
    if(p->pid == pid){
80103913:	39 58 10             	cmp    %ebx,0x10(%eax)
80103916:	75 f1                	jne    80103909 <kill+0x27>
      p->killed = 1;
80103918:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
8010391f:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103923:	74 db                	je     80103900 <kill+0x1e>
      release(&ptable.lock);
80103925:	83 ec 0c             	sub    $0xc,%esp
80103928:	68 20 1d 11 80       	push   $0x80111d20
8010392d:	e8 41 05 00 00       	call   80103e73 <release>
      return 0;
80103932:	83 c4 10             	add    $0x10,%esp
80103935:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
8010393a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010393d:	c9                   	leave  
8010393e:	c3                   	ret    
  release(&ptable.lock);
8010393f:	83 ec 0c             	sub    $0xc,%esp
80103942:	68 20 1d 11 80       	push   $0x80111d20
80103947:	e8 27 05 00 00       	call   80103e73 <release>
  return -1;
8010394c:	83 c4 10             	add    $0x10,%esp
8010394f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103954:	eb e4                	jmp    8010393a <kill+0x58>

80103956 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103956:	55                   	push   %ebp
80103957:	89 e5                	mov    %esp,%ebp
80103959:	56                   	push   %esi
8010395a:	53                   	push   %ebx
8010395b:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010395e:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103963:	eb 33                	jmp    80103998 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103965:	b8 e3 6f 10 80       	mov    $0x80106fe3,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
8010396a:	8d 53 6c             	lea    0x6c(%ebx),%edx
8010396d:	52                   	push   %edx
8010396e:	50                   	push   %eax
8010396f:	ff 73 10             	push   0x10(%ebx)
80103972:	68 e7 6f 10 80       	push   $0x80106fe7
80103977:	e8 8b cc ff ff       	call   80100607 <cprintf>
    if(p->state == SLEEPING){
8010397c:	83 c4 10             	add    $0x10,%esp
8010397f:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103983:	74 39                	je     801039be <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103985:	83 ec 0c             	sub    $0xc,%esp
80103988:	68 ab 73 10 80       	push   $0x801073ab
8010398d:	e8 75 cc ff ff       	call   80100607 <cprintf>
80103992:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103995:	83 c3 7c             	add    $0x7c,%ebx
80103998:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
8010399e:	73 61                	jae    80103a01 <procdump+0xab>
    if(p->state == UNUSED)
801039a0:	8b 43 0c             	mov    0xc(%ebx),%eax
801039a3:	85 c0                	test   %eax,%eax
801039a5:	74 ee                	je     80103995 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801039a7:	83 f8 05             	cmp    $0x5,%eax
801039aa:	77 b9                	ja     80103965 <procdump+0xf>
801039ac:	8b 04 85 7c 70 10 80 	mov    -0x7fef8f84(,%eax,4),%eax
801039b3:	85 c0                	test   %eax,%eax
801039b5:	75 b3                	jne    8010396a <procdump+0x14>
      state = "???";
801039b7:	b8 e3 6f 10 80       	mov    $0x80106fe3,%eax
801039bc:	eb ac                	jmp    8010396a <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801039be:	8b 43 1c             	mov    0x1c(%ebx),%eax
801039c1:	8b 40 0c             	mov    0xc(%eax),%eax
801039c4:	83 c0 08             	add    $0x8,%eax
801039c7:	83 ec 08             	sub    $0x8,%esp
801039ca:	8d 55 d0             	lea    -0x30(%ebp),%edx
801039cd:	52                   	push   %edx
801039ce:	50                   	push   %eax
801039cf:	e8 19 03 00 00       	call   80103ced <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801039d4:	83 c4 10             	add    $0x10,%esp
801039d7:	be 00 00 00 00       	mov    $0x0,%esi
801039dc:	eb 14                	jmp    801039f2 <procdump+0x9c>
        cprintf(" %p", pc[i]);
801039de:	83 ec 08             	sub    $0x8,%esp
801039e1:	50                   	push   %eax
801039e2:	68 81 69 10 80       	push   $0x80106981
801039e7:	e8 1b cc ff ff       	call   80100607 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801039ec:	83 c6 01             	add    $0x1,%esi
801039ef:	83 c4 10             	add    $0x10,%esp
801039f2:	83 fe 09             	cmp    $0x9,%esi
801039f5:	7f 8e                	jg     80103985 <procdump+0x2f>
801039f7:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
801039fb:	85 c0                	test   %eax,%eax
801039fd:	75 df                	jne    801039de <procdump+0x88>
801039ff:	eb 84                	jmp    80103985 <procdump+0x2f>
  }
}
80103a01:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a04:	5b                   	pop    %ebx
80103a05:	5e                   	pop    %esi
80103a06:	5d                   	pop    %ebp
80103a07:	c3                   	ret    

80103a08 <sys_getpagetableentry>:


int sys_getpagetableentry(void) {
80103a08:	55                   	push   %ebp
80103a09:	89 e5                	mov    %esp,%ebp
80103a0b:	83 ec 20             	sub    $0x20,%esp
  struct proc *p;
  int t_pid;
  int address;

  //get both syscall arguments
  if (argint(0, &t_pid) < 0) {
80103a0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103a11:	50                   	push   %eax
80103a12:	6a 00                	push   $0x0
80103a14:	e8 f1 06 00 00       	call   8010410a <argint>
80103a19:	83 c4 10             	add    $0x10,%esp
80103a1c:	85 c0                	test   %eax,%eax
80103a1e:	78 57                	js     80103a77 <sys_getpagetableentry+0x6f>
    return -1;
  }
  if (argint(1, &address) < 0) {
80103a20:	83 ec 08             	sub    $0x8,%esp
80103a23:	8d 45 f0             	lea    -0x10(%ebp),%eax
80103a26:	50                   	push   %eax
80103a27:	6a 01                	push   $0x1
80103a29:	e8 dc 06 00 00       	call   8010410a <argint>
80103a2e:	83 c4 10             	add    $0x10,%esp
80103a31:	85 c0                	test   %eax,%eax
80103a33:	78 49                	js     80103a7e <sys_getpagetableentry+0x76>
    return -1;
  }

  // acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103a35:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
80103a3a:	eb 03                	jmp    80103a3f <sys_getpagetableentry+0x37>
80103a3c:	83 c0 7c             	add    $0x7c,%eax
80103a3f:	3d 54 3c 11 80       	cmp    $0x80113c54,%eax
80103a44:	73 2a                	jae    80103a70 <sys_getpagetableentry+0x68>
      if(p->pid == t_pid) {
80103a46:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80103a49:	39 48 10             	cmp    %ecx,0x10(%eax)
80103a4c:	75 ee                	jne    80103a3c <sys_getpagetableentry+0x34>
        pte_t* temp = walkpgdir(p->pgdir, (void*)address, 1);
80103a4e:	83 ec 04             	sub    $0x4,%esp
80103a51:	6a 01                	push   $0x1
80103a53:	ff 75 f0             	push   -0x10(%ebp)
80103a56:	ff 70 04             	push   0x4(%eax)
80103a59:	e8 32 26 00 00       	call   80106090 <walkpgdir>
        if (temp == 0) {
80103a5e:	83 c4 10             	add    $0x10,%esp
80103a61:	85 c0                	test   %eax,%eax
80103a63:	74 20                	je     80103a85 <sys_getpagetableentry+0x7d>
          return 0;
        }
        int a;
        a = temp[PDX(address)];
80103a65:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103a68:	c1 ea 16             	shr    $0x16,%edx
80103a6b:	8b 04 90             	mov    (%eax,%edx,4),%eax
        return a;
    }
  }
  // release(&ptable.lock);
  return 0;
}
80103a6e:	c9                   	leave  
80103a6f:	c3                   	ret    
  return 0;
80103a70:	b8 00 00 00 00       	mov    $0x0,%eax
80103a75:	eb f7                	jmp    80103a6e <sys_getpagetableentry+0x66>
    return -1;
80103a77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a7c:	eb f0                	jmp    80103a6e <sys_getpagetableentry+0x66>
    return -1;
80103a7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a83:	eb e9                	jmp    80103a6e <sys_getpagetableentry+0x66>
          return 0;
80103a85:	b8 00 00 00 00       	mov    $0x0,%eax
80103a8a:	eb e2                	jmp    80103a6e <sys_getpagetableentry+0x66>

80103a8c <sys_isphysicalpagefree>:


int sys_isphysicalpagefree(void) {
80103a8c:	55                   	push   %ebp
80103a8d:	89 e5                	mov    %esp,%ebp
80103a8f:	83 ec 20             	sub    $0x20,%esp
  int ppn;
  if (argint(0, &ppn) < 0) {
80103a92:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103a95:	50                   	push   %eax
80103a96:	6a 00                	push   $0x0
80103a98:	e8 6d 06 00 00       	call   8010410a <argint>
80103a9d:	83 c4 10             	add    $0x10,%esp
80103aa0:	85 c0                	test   %eax,%eax
80103aa2:	78 10                	js     80103ab4 <sys_isphysicalpagefree+0x28>
    return -1;
  }
  return kphysicalpagefree(ppn); //question on how to get PPN from physical add.
80103aa4:	83 ec 0c             	sub    $0xc,%esp
80103aa7:	ff 75 f4             	push   -0xc(%ebp)
80103aaa:	e8 6f e6 ff ff       	call   8010211e <kphysicalpagefree>
80103aaf:	83 c4 10             	add    $0x10,%esp
}
80103ab2:	c9                   	leave  
80103ab3:	c3                   	ret    
    return -1;
80103ab4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ab9:	eb f7                	jmp    80103ab2 <sys_isphysicalpagefree+0x26>

80103abb <sys_dumppagetable>:

int sys_dumppagetable(void) {
80103abb:	55                   	push   %ebp
80103abc:	89 e5                	mov    %esp,%ebp
80103abe:	56                   	push   %esi
80103abf:	53                   	push   %ebx
80103ac0:	83 ec 18             	sub    $0x18,%esp
  int t_pid;
  struct proc *p;
  //get both syscall arguments
  if (argint(0, &t_pid) < 0) {
80103ac3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103ac6:	50                   	push   %eax
80103ac7:	6a 00                	push   $0x0
80103ac9:	e8 3c 06 00 00       	call   8010410a <argint>
80103ace:	83 c4 10             	add    $0x10,%esp
80103ad1:	85 c0                	test   %eax,%eax
80103ad3:	0f 88 e7 00 00 00    	js     80103bc0 <sys_dumppagetable+0x105>
    return -1;
  }

  acquire(&ptable.lock);
80103ad9:	83 ec 0c             	sub    $0xc,%esp
80103adc:	68 20 1d 11 80       	push   $0x80111d20
80103ae1:	e8 28 03 00 00       	call   80103e0e <acquire>
  pte_t *pte;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103ae6:	83 c4 10             	add    $0x10,%esp
80103ae9:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103aee:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103af4:	0f 83 af 00 00 00    	jae    80103ba9 <sys_dumppagetable+0xee>
      if(p->pid == t_pid) {
80103afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afd:	39 43 10             	cmp    %eax,0x10(%ebx)
80103b00:	74 05                	je     80103b07 <sys_dumppagetable+0x4c>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103b02:	83 c3 7c             	add    $0x7c,%ebx
80103b05:	eb e7                	jmp    80103aee <sys_dumppagetable+0x33>
        
        cprintf("START PAGE TABLE\n");
80103b07:	83 ec 0c             	sub    $0xc,%esp
80103b0a:	68 f6 6f 10 80       	push   $0x80106ff6
80103b0f:	e8 f3 ca ff ff       	call   80100607 <cprintf>
        int v_pg = 0;
        for (int virtual_add = 0; virtual_add < p->sz; virtual_add += PGSIZE) {
80103b14:	83 c4 10             	add    $0x10,%esp
80103b17:	be 00 00 00 00       	mov    $0x0,%esi
80103b1c:	eb 2b                	jmp    80103b49 <sys_dumppagetable+0x8e>
          if((pte = walkpgdir(p->pgdir, (const void*)virtual_add, 0)) == 0) {
            // panic("loaduvm: address should exist");

          } else {
              if (*pte & PTE_P) {
                cprintf("%x P %s %s %x\n", 
80103b1e:	b9 f2 6f 10 80       	mov    $0x80106ff2,%ecx
80103b23:	eb 51                	jmp    80103b76 <sys_dumppagetable+0xbb>
80103b25:	b8 f2 6f 10 80       	mov    $0x80106ff2,%eax
80103b2a:	83 ec 0c             	sub    $0xc,%esp
80103b2d:	52                   	push   %edx
80103b2e:	51                   	push   %ecx
80103b2f:	50                   	push   %eax
80103b30:	89 f0                	mov    %esi,%eax
80103b32:	c1 f8 0c             	sar    $0xc,%eax
80103b35:	50                   	push   %eax
80103b36:	68 08 70 10 80       	push   $0x80107008
80103b3b:	e8 c7 ca ff ff       	call   80100607 <cprintf>
80103b40:	83 c4 20             	add    $0x20,%esp
        for (int virtual_add = 0; virtual_add < p->sz; virtual_add += PGSIZE) {
80103b43:	81 c6 00 10 00 00    	add    $0x1000,%esi
80103b49:	39 33                	cmp    %esi,(%ebx)
80103b4b:	76 34                	jbe    80103b81 <sys_dumppagetable+0xc6>
          if((pte = walkpgdir(p->pgdir, (const void*)virtual_add, 0)) == 0) {
80103b4d:	83 ec 04             	sub    $0x4,%esp
80103b50:	6a 00                	push   $0x0
80103b52:	56                   	push   %esi
80103b53:	ff 73 04             	push   0x4(%ebx)
80103b56:	e8 35 25 00 00       	call   80106090 <walkpgdir>
80103b5b:	83 c4 10             	add    $0x10,%esp
80103b5e:	85 c0                	test   %eax,%eax
80103b60:	74 e1                	je     80103b43 <sys_dumppagetable+0x88>
              if (*pte & PTE_P) {
80103b62:	8b 00                	mov    (%eax),%eax
80103b64:	a8 01                	test   $0x1,%al
80103b66:	74 db                	je     80103b43 <sys_dumppagetable+0x88>
                cprintf("%x P %s %s %x\n", 
80103b68:	89 c2                	mov    %eax,%edx
80103b6a:	c1 ea 0c             	shr    $0xc,%edx
80103b6d:	a8 02                	test   $0x2,%al
80103b6f:	74 ad                	je     80103b1e <sys_dumppagetable+0x63>
80103b71:	b9 f0 6f 10 80       	mov    $0x80106ff0,%ecx
80103b76:	a8 04                	test   $0x4,%al
80103b78:	74 ab                	je     80103b25 <sys_dumppagetable+0x6a>
80103b7a:	b8 f4 6f 10 80       	mov    $0x80106ff4,%eax
80103b7f:	eb a9                	jmp    80103b2a <sys_dumppagetable+0x6f>
                PTE_ADDR(*pte) >> PTXSHIFT);
              }
          v_pg += 1;
          }
        }
        cprintf("END PAGE TABLE\n");
80103b81:	83 ec 0c             	sub    $0xc,%esp
80103b84:	68 17 70 10 80       	push   $0x80107017
80103b89:	e8 79 ca ff ff       	call   80100607 <cprintf>
        release(&ptable.lock);
80103b8e:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103b95:	e8 d9 02 00 00       	call   80103e73 <release>
        return 0;
80103b9a:	83 c4 10             	add    $0x10,%esp
80103b9d:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return 0; 
80103ba2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ba5:	5b                   	pop    %ebx
80103ba6:	5e                   	pop    %esi
80103ba7:	5d                   	pop    %ebp
80103ba8:	c3                   	ret    
  release(&ptable.lock);
80103ba9:	83 ec 0c             	sub    $0xc,%esp
80103bac:	68 20 1d 11 80       	push   $0x80111d20
80103bb1:	e8 bd 02 00 00       	call   80103e73 <release>
  return 0; 
80103bb6:	83 c4 10             	add    $0x10,%esp
80103bb9:	b8 00 00 00 00       	mov    $0x0,%eax
80103bbe:	eb e2                	jmp    80103ba2 <sys_dumppagetable+0xe7>
    return -1;
80103bc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103bc5:	eb db                	jmp    80103ba2 <sys_dumppagetable+0xe7>

80103bc7 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103bc7:	55                   	push   %ebp
80103bc8:	89 e5                	mov    %esp,%ebp
80103bca:	53                   	push   %ebx
80103bcb:	83 ec 0c             	sub    $0xc,%esp
80103bce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103bd1:	68 94 70 10 80       	push   $0x80107094
80103bd6:	8d 43 04             	lea    0x4(%ebx),%eax
80103bd9:	50                   	push   %eax
80103bda:	e8 f3 00 00 00       	call   80103cd2 <initlock>
  lk->name = name;
80103bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103be2:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103be5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103beb:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103bf2:	83 c4 10             	add    $0x10,%esp
80103bf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103bf8:	c9                   	leave  
80103bf9:	c3                   	ret    

80103bfa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103bfa:	55                   	push   %ebp
80103bfb:	89 e5                	mov    %esp,%ebp
80103bfd:	56                   	push   %esi
80103bfe:	53                   	push   %ebx
80103bff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c02:	8d 73 04             	lea    0x4(%ebx),%esi
80103c05:	83 ec 0c             	sub    $0xc,%esp
80103c08:	56                   	push   %esi
80103c09:	e8 00 02 00 00       	call   80103e0e <acquire>
  while (lk->locked) {
80103c0e:	83 c4 10             	add    $0x10,%esp
80103c11:	eb 0d                	jmp    80103c20 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103c13:	83 ec 08             	sub    $0x8,%esp
80103c16:	56                   	push   %esi
80103c17:	53                   	push   %ebx
80103c18:	e8 37 fb ff ff       	call   80103754 <sleep>
80103c1d:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103c20:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c23:	75 ee                	jne    80103c13 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103c25:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103c2b:	e8 82 f6 ff ff       	call   801032b2 <myproc>
80103c30:	8b 40 10             	mov    0x10(%eax),%eax
80103c33:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103c36:	83 ec 0c             	sub    $0xc,%esp
80103c39:	56                   	push   %esi
80103c3a:	e8 34 02 00 00       	call   80103e73 <release>
}
80103c3f:	83 c4 10             	add    $0x10,%esp
80103c42:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c45:	5b                   	pop    %ebx
80103c46:	5e                   	pop    %esi
80103c47:	5d                   	pop    %ebp
80103c48:	c3                   	ret    

80103c49 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103c49:	55                   	push   %ebp
80103c4a:	89 e5                	mov    %esp,%ebp
80103c4c:	56                   	push   %esi
80103c4d:	53                   	push   %ebx
80103c4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c51:	8d 73 04             	lea    0x4(%ebx),%esi
80103c54:	83 ec 0c             	sub    $0xc,%esp
80103c57:	56                   	push   %esi
80103c58:	e8 b1 01 00 00       	call   80103e0e <acquire>
  lk->locked = 0;
80103c5d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103c63:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103c6a:	89 1c 24             	mov    %ebx,(%esp)
80103c6d:	e8 47 fc ff ff       	call   801038b9 <wakeup>
  release(&lk->lk);
80103c72:	89 34 24             	mov    %esi,(%esp)
80103c75:	e8 f9 01 00 00       	call   80103e73 <release>
}
80103c7a:	83 c4 10             	add    $0x10,%esp
80103c7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c80:	5b                   	pop    %ebx
80103c81:	5e                   	pop    %esi
80103c82:	5d                   	pop    %ebp
80103c83:	c3                   	ret    

80103c84 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103c84:	55                   	push   %ebp
80103c85:	89 e5                	mov    %esp,%ebp
80103c87:	56                   	push   %esi
80103c88:	53                   	push   %ebx
80103c89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103c8c:	8d 73 04             	lea    0x4(%ebx),%esi
80103c8f:	83 ec 0c             	sub    $0xc,%esp
80103c92:	56                   	push   %esi
80103c93:	e8 76 01 00 00       	call   80103e0e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103c98:	83 c4 10             	add    $0x10,%esp
80103c9b:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c9e:	75 17                	jne    80103cb7 <holdingsleep+0x33>
80103ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103ca5:	83 ec 0c             	sub    $0xc,%esp
80103ca8:	56                   	push   %esi
80103ca9:	e8 c5 01 00 00       	call   80103e73 <release>
  return r;
}
80103cae:	89 d8                	mov    %ebx,%eax
80103cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103cb3:	5b                   	pop    %ebx
80103cb4:	5e                   	pop    %esi
80103cb5:	5d                   	pop    %ebp
80103cb6:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103cb7:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103cba:	e8 f3 f5 ff ff       	call   801032b2 <myproc>
80103cbf:	3b 58 10             	cmp    0x10(%eax),%ebx
80103cc2:	74 07                	je     80103ccb <holdingsleep+0x47>
80103cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
80103cc9:	eb da                	jmp    80103ca5 <holdingsleep+0x21>
80103ccb:	bb 01 00 00 00       	mov    $0x1,%ebx
80103cd0:	eb d3                	jmp    80103ca5 <holdingsleep+0x21>

80103cd2 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103cd2:	55                   	push   %ebp
80103cd3:	89 e5                	mov    %esp,%ebp
80103cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103cd8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cdb:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103cde:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103ce4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103ceb:	5d                   	pop    %ebp
80103cec:	c3                   	ret    

80103ced <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103ced:	55                   	push   %ebp
80103cee:	89 e5                	mov    %esp,%ebp
80103cf0:	53                   	push   %ebx
80103cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf7:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103cfa:	b8 00 00 00 00       	mov    $0x0,%eax
80103cff:	83 f8 09             	cmp    $0x9,%eax
80103d02:	7f 25                	jg     80103d29 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103d04:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103d0a:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103d10:	77 17                	ja     80103d29 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103d12:	8b 5a 04             	mov    0x4(%edx),%ebx
80103d15:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103d18:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103d1a:	83 c0 01             	add    $0x1,%eax
80103d1d:	eb e0                	jmp    80103cff <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103d1f:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103d26:	83 c0 01             	add    $0x1,%eax
80103d29:	83 f8 09             	cmp    $0x9,%eax
80103d2c:	7e f1                	jle    80103d1f <getcallerpcs+0x32>
}
80103d2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d31:	c9                   	leave  
80103d32:	c3                   	ret    

80103d33 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103d33:	55                   	push   %ebp
80103d34:	89 e5                	mov    %esp,%ebp
80103d36:	53                   	push   %ebx
80103d37:	83 ec 04             	sub    $0x4,%esp
80103d3a:	9c                   	pushf  
80103d3b:	5b                   	pop    %ebx
  asm volatile("cli");
80103d3c:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103d3d:	e8 f9 f4 ff ff       	call   8010323b <mycpu>
80103d42:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103d49:	74 11                	je     80103d5c <pushcli+0x29>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103d4b:	e8 eb f4 ff ff       	call   8010323b <mycpu>
80103d50:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103d57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d5a:	c9                   	leave  
80103d5b:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103d5c:	e8 da f4 ff ff       	call   8010323b <mycpu>
80103d61:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103d67:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103d6d:	eb dc                	jmp    80103d4b <pushcli+0x18>

80103d6f <popcli>:

void
popcli(void)
{
80103d6f:	55                   	push   %ebp
80103d70:	89 e5                	mov    %esp,%ebp
80103d72:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103d75:	9c                   	pushf  
80103d76:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103d77:	f6 c4 02             	test   $0x2,%ah
80103d7a:	75 28                	jne    80103da4 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103d7c:	e8 ba f4 ff ff       	call   8010323b <mycpu>
80103d81:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103d87:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103d8a:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103d90:	85 d2                	test   %edx,%edx
80103d92:	78 1d                	js     80103db1 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103d94:	e8 a2 f4 ff ff       	call   8010323b <mycpu>
80103d99:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103da0:	74 1c                	je     80103dbe <popcli+0x4f>
    sti();
}
80103da2:	c9                   	leave  
80103da3:	c3                   	ret    
    panic("popcli - interruptible");
80103da4:	83 ec 0c             	sub    $0xc,%esp
80103da7:	68 9f 70 10 80       	push   $0x8010709f
80103dac:	e8 97 c5 ff ff       	call   80100348 <panic>
    panic("popcli");
80103db1:	83 ec 0c             	sub    $0xc,%esp
80103db4:	68 b6 70 10 80       	push   $0x801070b6
80103db9:	e8 8a c5 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103dbe:	e8 78 f4 ff ff       	call   8010323b <mycpu>
80103dc3:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103dca:	74 d6                	je     80103da2 <popcli+0x33>
  asm volatile("sti");
80103dcc:	fb                   	sti    
}
80103dcd:	eb d3                	jmp    80103da2 <popcli+0x33>

80103dcf <holding>:
{
80103dcf:	55                   	push   %ebp
80103dd0:	89 e5                	mov    %esp,%ebp
80103dd2:	53                   	push   %ebx
80103dd3:	83 ec 04             	sub    $0x4,%esp
80103dd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103dd9:	e8 55 ff ff ff       	call   80103d33 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103dde:	83 3b 00             	cmpl   $0x0,(%ebx)
80103de1:	75 11                	jne    80103df4 <holding+0x25>
80103de3:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103de8:	e8 82 ff ff ff       	call   80103d6f <popcli>
}
80103ded:	89 d8                	mov    %ebx,%eax
80103def:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103df2:	c9                   	leave  
80103df3:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103df4:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103df7:	e8 3f f4 ff ff       	call   8010323b <mycpu>
80103dfc:	39 c3                	cmp    %eax,%ebx
80103dfe:	74 07                	je     80103e07 <holding+0x38>
80103e00:	bb 00 00 00 00       	mov    $0x0,%ebx
80103e05:	eb e1                	jmp    80103de8 <holding+0x19>
80103e07:	bb 01 00 00 00       	mov    $0x1,%ebx
80103e0c:	eb da                	jmp    80103de8 <holding+0x19>

80103e0e <acquire>:
{
80103e0e:	55                   	push   %ebp
80103e0f:	89 e5                	mov    %esp,%ebp
80103e11:	53                   	push   %ebx
80103e12:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103e15:	e8 19 ff ff ff       	call   80103d33 <pushcli>
  if(holding(lk))
80103e1a:	83 ec 0c             	sub    $0xc,%esp
80103e1d:	ff 75 08             	push   0x8(%ebp)
80103e20:	e8 aa ff ff ff       	call   80103dcf <holding>
80103e25:	83 c4 10             	add    $0x10,%esp
80103e28:	85 c0                	test   %eax,%eax
80103e2a:	75 3a                	jne    80103e66 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103e2f:	b8 01 00 00 00       	mov    $0x1,%eax
80103e34:	f0 87 02             	lock xchg %eax,(%edx)
80103e37:	85 c0                	test   %eax,%eax
80103e39:	75 f1                	jne    80103e2c <acquire+0x1e>
  __sync_synchronize();
80103e3b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103e40:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103e43:	e8 f3 f3 ff ff       	call   8010323b <mycpu>
80103e48:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4e:	83 c0 0c             	add    $0xc,%eax
80103e51:	83 ec 08             	sub    $0x8,%esp
80103e54:	50                   	push   %eax
80103e55:	8d 45 08             	lea    0x8(%ebp),%eax
80103e58:	50                   	push   %eax
80103e59:	e8 8f fe ff ff       	call   80103ced <getcallerpcs>
}
80103e5e:	83 c4 10             	add    $0x10,%esp
80103e61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e64:	c9                   	leave  
80103e65:	c3                   	ret    
    panic("acquire");
80103e66:	83 ec 0c             	sub    $0xc,%esp
80103e69:	68 bd 70 10 80       	push   $0x801070bd
80103e6e:	e8 d5 c4 ff ff       	call   80100348 <panic>

80103e73 <release>:
{
80103e73:	55                   	push   %ebp
80103e74:	89 e5                	mov    %esp,%ebp
80103e76:	53                   	push   %ebx
80103e77:	83 ec 10             	sub    $0x10,%esp
80103e7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103e7d:	53                   	push   %ebx
80103e7e:	e8 4c ff ff ff       	call   80103dcf <holding>
80103e83:	83 c4 10             	add    $0x10,%esp
80103e86:	85 c0                	test   %eax,%eax
80103e88:	74 23                	je     80103ead <release+0x3a>
  lk->pcs[0] = 0;
80103e8a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103e91:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103e98:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103e9d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103ea3:	e8 c7 fe ff ff       	call   80103d6f <popcli>
}
80103ea8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103eab:	c9                   	leave  
80103eac:	c3                   	ret    
    panic("release");
80103ead:	83 ec 0c             	sub    $0xc,%esp
80103eb0:	68 c5 70 10 80       	push   $0x801070c5
80103eb5:	e8 8e c4 ff ff       	call   80100348 <panic>

80103eba <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103eba:	55                   	push   %ebp
80103ebb:	89 e5                	mov    %esp,%ebp
80103ebd:	57                   	push   %edi
80103ebe:	53                   	push   %ebx
80103ebf:	8b 55 08             	mov    0x8(%ebp),%edx
80103ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ec5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103ec8:	f6 c2 03             	test   $0x3,%dl
80103ecb:	75 25                	jne    80103ef2 <memset+0x38>
80103ecd:	f6 c1 03             	test   $0x3,%cl
80103ed0:	75 20                	jne    80103ef2 <memset+0x38>
    c &= 0xFF;
80103ed2:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103ed5:	c1 e9 02             	shr    $0x2,%ecx
80103ed8:	c1 e0 18             	shl    $0x18,%eax
80103edb:	89 fb                	mov    %edi,%ebx
80103edd:	c1 e3 10             	shl    $0x10,%ebx
80103ee0:	09 d8                	or     %ebx,%eax
80103ee2:	89 fb                	mov    %edi,%ebx
80103ee4:	c1 e3 08             	shl    $0x8,%ebx
80103ee7:	09 d8                	or     %ebx,%eax
80103ee9:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103eeb:	89 d7                	mov    %edx,%edi
80103eed:	fc                   	cld    
80103eee:	f3 ab                	rep stos %eax,%es:(%edi)
}
80103ef0:	eb 05                	jmp    80103ef7 <memset+0x3d>
  asm volatile("cld; rep stosb" :
80103ef2:	89 d7                	mov    %edx,%edi
80103ef4:	fc                   	cld    
80103ef5:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103ef7:	89 d0                	mov    %edx,%eax
80103ef9:	5b                   	pop    %ebx
80103efa:	5f                   	pop    %edi
80103efb:	5d                   	pop    %ebp
80103efc:	c3                   	ret    

80103efd <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103efd:	55                   	push   %ebp
80103efe:	89 e5                	mov    %esp,%ebp
80103f00:	56                   	push   %esi
80103f01:	53                   	push   %ebx
80103f02:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f05:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f08:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103f0b:	eb 08                	jmp    80103f15 <memcmp+0x18>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80103f0d:	83 c1 01             	add    $0x1,%ecx
80103f10:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103f13:	89 f0                	mov    %esi,%eax
80103f15:	8d 70 ff             	lea    -0x1(%eax),%esi
80103f18:	85 c0                	test   %eax,%eax
80103f1a:	74 12                	je     80103f2e <memcmp+0x31>
    if(*s1 != *s2)
80103f1c:	0f b6 01             	movzbl (%ecx),%eax
80103f1f:	0f b6 1a             	movzbl (%edx),%ebx
80103f22:	38 d8                	cmp    %bl,%al
80103f24:	74 e7                	je     80103f0d <memcmp+0x10>
      return *s1 - *s2;
80103f26:	0f b6 c0             	movzbl %al,%eax
80103f29:	0f b6 db             	movzbl %bl,%ebx
80103f2c:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103f2e:	5b                   	pop    %ebx
80103f2f:	5e                   	pop    %esi
80103f30:	5d                   	pop    %ebp
80103f31:	c3                   	ret    

80103f32 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103f32:	55                   	push   %ebp
80103f33:	89 e5                	mov    %esp,%ebp
80103f35:	56                   	push   %esi
80103f36:	53                   	push   %ebx
80103f37:	8b 75 08             	mov    0x8(%ebp),%esi
80103f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f3d:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103f40:	39 f2                	cmp    %esi,%edx
80103f42:	73 3c                	jae    80103f80 <memmove+0x4e>
80103f44:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103f47:	39 f1                	cmp    %esi,%ecx
80103f49:	76 39                	jbe    80103f84 <memmove+0x52>
    s += n;
    d += n;
80103f4b:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
80103f4e:	eb 0d                	jmp    80103f5d <memmove+0x2b>
      *--d = *--s;
80103f50:	83 e9 01             	sub    $0x1,%ecx
80103f53:	83 ea 01             	sub    $0x1,%edx
80103f56:	0f b6 01             	movzbl (%ecx),%eax
80103f59:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80103f5b:	89 d8                	mov    %ebx,%eax
80103f5d:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103f60:	85 c0                	test   %eax,%eax
80103f62:	75 ec                	jne    80103f50 <memmove+0x1e>
80103f64:	eb 14                	jmp    80103f7a <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103f66:	0f b6 02             	movzbl (%edx),%eax
80103f69:	88 01                	mov    %al,(%ecx)
80103f6b:	8d 49 01             	lea    0x1(%ecx),%ecx
80103f6e:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80103f71:	89 d8                	mov    %ebx,%eax
80103f73:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103f76:	85 c0                	test   %eax,%eax
80103f78:	75 ec                	jne    80103f66 <memmove+0x34>

  return dst;
}
80103f7a:	89 f0                	mov    %esi,%eax
80103f7c:	5b                   	pop    %ebx
80103f7d:	5e                   	pop    %esi
80103f7e:	5d                   	pop    %ebp
80103f7f:	c3                   	ret    
80103f80:	89 f1                	mov    %esi,%ecx
80103f82:	eb ef                	jmp    80103f73 <memmove+0x41>
80103f84:	89 f1                	mov    %esi,%ecx
80103f86:	eb eb                	jmp    80103f73 <memmove+0x41>

80103f88 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103f88:	55                   	push   %ebp
80103f89:	89 e5                	mov    %esp,%ebp
80103f8b:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80103f8e:	ff 75 10             	push   0x10(%ebp)
80103f91:	ff 75 0c             	push   0xc(%ebp)
80103f94:	ff 75 08             	push   0x8(%ebp)
80103f97:	e8 96 ff ff ff       	call   80103f32 <memmove>
}
80103f9c:	c9                   	leave  
80103f9d:	c3                   	ret    

80103f9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103f9e:	55                   	push   %ebp
80103f9f:	89 e5                	mov    %esp,%ebp
80103fa1:	53                   	push   %ebx
80103fa2:	8b 55 08             	mov    0x8(%ebp),%edx
80103fa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103fa8:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103fab:	eb 09                	jmp    80103fb6 <strncmp+0x18>
    n--, p++, q++;
80103fad:	83 e8 01             	sub    $0x1,%eax
80103fb0:	83 c2 01             	add    $0x1,%edx
80103fb3:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103fb6:	85 c0                	test   %eax,%eax
80103fb8:	74 0b                	je     80103fc5 <strncmp+0x27>
80103fba:	0f b6 1a             	movzbl (%edx),%ebx
80103fbd:	84 db                	test   %bl,%bl
80103fbf:	74 04                	je     80103fc5 <strncmp+0x27>
80103fc1:	3a 19                	cmp    (%ecx),%bl
80103fc3:	74 e8                	je     80103fad <strncmp+0xf>
  if(n == 0)
80103fc5:	85 c0                	test   %eax,%eax
80103fc7:	74 0d                	je     80103fd6 <strncmp+0x38>
    return 0;
  return (uchar)*p - (uchar)*q;
80103fc9:	0f b6 02             	movzbl (%edx),%eax
80103fcc:	0f b6 11             	movzbl (%ecx),%edx
80103fcf:	29 d0                	sub    %edx,%eax
}
80103fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103fd4:	c9                   	leave  
80103fd5:	c3                   	ret    
    return 0;
80103fd6:	b8 00 00 00 00       	mov    $0x0,%eax
80103fdb:	eb f4                	jmp    80103fd1 <strncmp+0x33>

80103fdd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103fdd:	55                   	push   %ebp
80103fde:	89 e5                	mov    %esp,%ebp
80103fe0:	57                   	push   %edi
80103fe1:	56                   	push   %esi
80103fe2:	53                   	push   %ebx
80103fe3:	8b 7d 08             	mov    0x8(%ebp),%edi
80103fe6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103fe9:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103fec:	89 fa                	mov    %edi,%edx
80103fee:	eb 04                	jmp    80103ff4 <strncpy+0x17>
80103ff0:	89 f1                	mov    %esi,%ecx
80103ff2:	89 da                	mov    %ebx,%edx
80103ff4:	89 c3                	mov    %eax,%ebx
80103ff6:	83 e8 01             	sub    $0x1,%eax
80103ff9:	85 db                	test   %ebx,%ebx
80103ffb:	7e 11                	jle    8010400e <strncpy+0x31>
80103ffd:	8d 71 01             	lea    0x1(%ecx),%esi
80104000:	8d 5a 01             	lea    0x1(%edx),%ebx
80104003:	0f b6 09             	movzbl (%ecx),%ecx
80104006:	88 0a                	mov    %cl,(%edx)
80104008:	84 c9                	test   %cl,%cl
8010400a:	75 e4                	jne    80103ff0 <strncpy+0x13>
8010400c:	89 da                	mov    %ebx,%edx
    ;
  while(n-- > 0)
8010400e:	8d 48 ff             	lea    -0x1(%eax),%ecx
80104011:	85 c0                	test   %eax,%eax
80104013:	7e 0a                	jle    8010401f <strncpy+0x42>
    *s++ = 0;
80104015:	c6 02 00             	movb   $0x0,(%edx)
  while(n-- > 0)
80104018:	89 c8                	mov    %ecx,%eax
    *s++ = 0;
8010401a:	8d 52 01             	lea    0x1(%edx),%edx
8010401d:	eb ef                	jmp    8010400e <strncpy+0x31>
  return os;
}
8010401f:	89 f8                	mov    %edi,%eax
80104021:	5b                   	pop    %ebx
80104022:	5e                   	pop    %esi
80104023:	5f                   	pop    %edi
80104024:	5d                   	pop    %ebp
80104025:	c3                   	ret    

80104026 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104026:	55                   	push   %ebp
80104027:	89 e5                	mov    %esp,%ebp
80104029:	57                   	push   %edi
8010402a:	56                   	push   %esi
8010402b:	53                   	push   %ebx
8010402c:	8b 7d 08             	mov    0x8(%ebp),%edi
8010402f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104032:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80104035:	85 c0                	test   %eax,%eax
80104037:	7e 23                	jle    8010405c <safestrcpy+0x36>
80104039:	89 fa                	mov    %edi,%edx
8010403b:	eb 04                	jmp    80104041 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
8010403d:	89 f1                	mov    %esi,%ecx
8010403f:	89 da                	mov    %ebx,%edx
80104041:	83 e8 01             	sub    $0x1,%eax
80104044:	85 c0                	test   %eax,%eax
80104046:	7e 11                	jle    80104059 <safestrcpy+0x33>
80104048:	8d 71 01             	lea    0x1(%ecx),%esi
8010404b:	8d 5a 01             	lea    0x1(%edx),%ebx
8010404e:	0f b6 09             	movzbl (%ecx),%ecx
80104051:	88 0a                	mov    %cl,(%edx)
80104053:	84 c9                	test   %cl,%cl
80104055:	75 e6                	jne    8010403d <safestrcpy+0x17>
80104057:	89 da                	mov    %ebx,%edx
    ;
  *s = 0;
80104059:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
8010405c:	89 f8                	mov    %edi,%eax
8010405e:	5b                   	pop    %ebx
8010405f:	5e                   	pop    %esi
80104060:	5f                   	pop    %edi
80104061:	5d                   	pop    %ebp
80104062:	c3                   	ret    

80104063 <strlen>:

int
strlen(const char *s)
{
80104063:	55                   	push   %ebp
80104064:	89 e5                	mov    %esp,%ebp
80104066:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80104069:	b8 00 00 00 00       	mov    $0x0,%eax
8010406e:	eb 03                	jmp    80104073 <strlen+0x10>
80104070:	83 c0 01             	add    $0x1,%eax
80104073:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104077:	75 f7                	jne    80104070 <strlen+0xd>
    ;
  return n;
}
80104079:	5d                   	pop    %ebp
8010407a:	c3                   	ret    

8010407b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010407b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010407f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104083:	55                   	push   %ebp
  pushl %ebx
80104084:	53                   	push   %ebx
  pushl %esi
80104085:	56                   	push   %esi
  pushl %edi
80104086:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104087:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104089:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010408b:	5f                   	pop    %edi
  popl %esi
8010408c:	5e                   	pop    %esi
  popl %ebx
8010408d:	5b                   	pop    %ebx
  popl %ebp
8010408e:	5d                   	pop    %ebp
  ret
8010408f:	c3                   	ret    

80104090 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104090:	55                   	push   %ebp
80104091:	89 e5                	mov    %esp,%ebp
80104093:	53                   	push   %ebx
80104094:	83 ec 04             	sub    $0x4,%esp
80104097:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
8010409a:	e8 13 f2 ff ff       	call   801032b2 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010409f:	8b 00                	mov    (%eax),%eax
801040a1:	39 d8                	cmp    %ebx,%eax
801040a3:	76 18                	jbe    801040bd <fetchint+0x2d>
801040a5:	8d 53 04             	lea    0x4(%ebx),%edx
801040a8:	39 d0                	cmp    %edx,%eax
801040aa:	72 18                	jb     801040c4 <fetchint+0x34>
    return -1;
  *ip = *(int*)(addr);
801040ac:	8b 13                	mov    (%ebx),%edx
801040ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b1:	89 10                	mov    %edx,(%eax)
  return 0;
801040b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040bb:	c9                   	leave  
801040bc:	c3                   	ret    
    return -1;
801040bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040c2:	eb f4                	jmp    801040b8 <fetchint+0x28>
801040c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040c9:	eb ed                	jmp    801040b8 <fetchint+0x28>

801040cb <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801040cb:	55                   	push   %ebp
801040cc:	89 e5                	mov    %esp,%ebp
801040ce:	53                   	push   %ebx
801040cf:	83 ec 04             	sub    $0x4,%esp
801040d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801040d5:	e8 d8 f1 ff ff       	call   801032b2 <myproc>

  if(addr >= curproc->sz)
801040da:	39 18                	cmp    %ebx,(%eax)
801040dc:	76 25                	jbe    80104103 <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
801040de:	8b 55 0c             	mov    0xc(%ebp),%edx
801040e1:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
801040e3:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
801040e5:	89 d8                	mov    %ebx,%eax
801040e7:	eb 03                	jmp    801040ec <fetchstr+0x21>
801040e9:	83 c0 01             	add    $0x1,%eax
801040ec:	39 d0                	cmp    %edx,%eax
801040ee:	73 09                	jae    801040f9 <fetchstr+0x2e>
    if(*s == 0)
801040f0:	80 38 00             	cmpb   $0x0,(%eax)
801040f3:	75 f4                	jne    801040e9 <fetchstr+0x1e>
      return s - *pp;
801040f5:	29 d8                	sub    %ebx,%eax
801040f7:	eb 05                	jmp    801040fe <fetchstr+0x33>
  }
  return -1;
801040f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104101:	c9                   	leave  
80104102:	c3                   	ret    
    return -1;
80104103:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104108:	eb f4                	jmp    801040fe <fetchstr+0x33>

8010410a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010410a:	55                   	push   %ebp
8010410b:	89 e5                	mov    %esp,%ebp
8010410d:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104110:	e8 9d f1 ff ff       	call   801032b2 <myproc>
80104115:	8b 50 18             	mov    0x18(%eax),%edx
80104118:	8b 45 08             	mov    0x8(%ebp),%eax
8010411b:	c1 e0 02             	shl    $0x2,%eax
8010411e:	03 42 44             	add    0x44(%edx),%eax
80104121:	83 ec 08             	sub    $0x8,%esp
80104124:	ff 75 0c             	push   0xc(%ebp)
80104127:	83 c0 04             	add    $0x4,%eax
8010412a:	50                   	push   %eax
8010412b:	e8 60 ff ff ff       	call   80104090 <fetchint>
}
80104130:	c9                   	leave  
80104131:	c3                   	ret    

80104132 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104132:	55                   	push   %ebp
80104133:	89 e5                	mov    %esp,%ebp
80104135:	56                   	push   %esi
80104136:	53                   	push   %ebx
80104137:	83 ec 10             	sub    $0x10,%esp
8010413a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010413d:	e8 70 f1 ff ff       	call   801032b2 <myproc>
80104142:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104144:	83 ec 08             	sub    $0x8,%esp
80104147:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010414a:	50                   	push   %eax
8010414b:	ff 75 08             	push   0x8(%ebp)
8010414e:	e8 b7 ff ff ff       	call   8010410a <argint>
80104153:	83 c4 10             	add    $0x10,%esp
80104156:	85 c0                	test   %eax,%eax
80104158:	78 24                	js     8010417e <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010415a:	85 db                	test   %ebx,%ebx
8010415c:	78 27                	js     80104185 <argptr+0x53>
8010415e:	8b 16                	mov    (%esi),%edx
80104160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104163:	39 c2                	cmp    %eax,%edx
80104165:	76 25                	jbe    8010418c <argptr+0x5a>
80104167:	01 c3                	add    %eax,%ebx
80104169:	39 da                	cmp    %ebx,%edx
8010416b:	72 26                	jb     80104193 <argptr+0x61>
    return -1;
  *pp = (char*)i;
8010416d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104170:	89 02                	mov    %eax,(%edx)
  return 0;
80104172:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104177:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010417a:	5b                   	pop    %ebx
8010417b:	5e                   	pop    %esi
8010417c:	5d                   	pop    %ebp
8010417d:	c3                   	ret    
    return -1;
8010417e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104183:	eb f2                	jmp    80104177 <argptr+0x45>
    return -1;
80104185:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010418a:	eb eb                	jmp    80104177 <argptr+0x45>
8010418c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104191:	eb e4                	jmp    80104177 <argptr+0x45>
80104193:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104198:	eb dd                	jmp    80104177 <argptr+0x45>

8010419a <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010419a:	55                   	push   %ebp
8010419b:	89 e5                	mov    %esp,%ebp
8010419d:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801041a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801041a3:	50                   	push   %eax
801041a4:	ff 75 08             	push   0x8(%ebp)
801041a7:	e8 5e ff ff ff       	call   8010410a <argint>
801041ac:	83 c4 10             	add    $0x10,%esp
801041af:	85 c0                	test   %eax,%eax
801041b1:	78 13                	js     801041c6 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801041b3:	83 ec 08             	sub    $0x8,%esp
801041b6:	ff 75 0c             	push   0xc(%ebp)
801041b9:	ff 75 f4             	push   -0xc(%ebp)
801041bc:	e8 0a ff ff ff       	call   801040cb <fetchstr>
801041c1:	83 c4 10             	add    $0x10,%esp
}
801041c4:	c9                   	leave  
801041c5:	c3                   	ret    
    return -1;
801041c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041cb:	eb f7                	jmp    801041c4 <argstr+0x2a>

801041cd <syscall>:
[SYS_dumppagetable] sys_dumppagetable,
};

void
syscall(void)
{
801041cd:	55                   	push   %ebp
801041ce:	89 e5                	mov    %esp,%ebp
801041d0:	53                   	push   %ebx
801041d1:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801041d4:	e8 d9 f0 ff ff       	call   801032b2 <myproc>
801041d9:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
801041db:	8b 40 18             	mov    0x18(%eax),%eax
801041de:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801041e1:	8d 50 ff             	lea    -0x1(%eax),%edx
801041e4:	83 fa 19             	cmp    $0x19,%edx
801041e7:	77 17                	ja     80104200 <syscall+0x33>
801041e9:	8b 14 85 00 71 10 80 	mov    -0x7fef8f00(,%eax,4),%edx
801041f0:	85 d2                	test   %edx,%edx
801041f2:	74 0c                	je     80104200 <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
801041f4:	ff d2                	call   *%edx
801041f6:	89 c2                	mov    %eax,%edx
801041f8:	8b 43 18             	mov    0x18(%ebx),%eax
801041fb:	89 50 1c             	mov    %edx,0x1c(%eax)
801041fe:	eb 1f                	jmp    8010421f <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104200:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104203:	50                   	push   %eax
80104204:	52                   	push   %edx
80104205:	ff 73 10             	push   0x10(%ebx)
80104208:	68 cd 70 10 80       	push   $0x801070cd
8010420d:	e8 f5 c3 ff ff       	call   80100607 <cprintf>
    curproc->tf->eax = -1;
80104212:	8b 43 18             	mov    0x18(%ebx),%eax
80104215:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010421c:	83 c4 10             	add    $0x10,%esp
  }
}
8010421f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104222:	c9                   	leave  
80104223:	c3                   	ret    

80104224 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104224:	55                   	push   %ebp
80104225:	89 e5                	mov    %esp,%ebp
80104227:	56                   	push   %esi
80104228:	53                   	push   %ebx
80104229:	83 ec 18             	sub    $0x18,%esp
8010422c:	89 d6                	mov    %edx,%esi
8010422e:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104230:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104233:	52                   	push   %edx
80104234:	50                   	push   %eax
80104235:	e8 d0 fe ff ff       	call   8010410a <argint>
8010423a:	83 c4 10             	add    $0x10,%esp
8010423d:	85 c0                	test   %eax,%eax
8010423f:	78 35                	js     80104276 <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104241:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104245:	77 28                	ja     8010426f <argfd+0x4b>
80104247:	e8 66 f0 ff ff       	call   801032b2 <myproc>
8010424c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424f:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104253:	85 c0                	test   %eax,%eax
80104255:	74 18                	je     8010426f <argfd+0x4b>
    return -1;
  if(pfd)
80104257:	85 f6                	test   %esi,%esi
80104259:	74 02                	je     8010425d <argfd+0x39>
    *pfd = fd;
8010425b:	89 16                	mov    %edx,(%esi)
  if(pf)
8010425d:	85 db                	test   %ebx,%ebx
8010425f:	74 1c                	je     8010427d <argfd+0x59>
    *pf = f;
80104261:	89 03                	mov    %eax,(%ebx)
  return 0;
80104263:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104268:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010426b:	5b                   	pop    %ebx
8010426c:	5e                   	pop    %esi
8010426d:	5d                   	pop    %ebp
8010426e:	c3                   	ret    
    return -1;
8010426f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104274:	eb f2                	jmp    80104268 <argfd+0x44>
    return -1;
80104276:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010427b:	eb eb                	jmp    80104268 <argfd+0x44>
  return 0;
8010427d:	b8 00 00 00 00       	mov    $0x0,%eax
80104282:	eb e4                	jmp    80104268 <argfd+0x44>

80104284 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104284:	55                   	push   %ebp
80104285:	89 e5                	mov    %esp,%ebp
80104287:	53                   	push   %ebx
80104288:	83 ec 04             	sub    $0x4,%esp
8010428b:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
8010428d:	e8 20 f0 ff ff       	call   801032b2 <myproc>
80104292:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
80104294:	b8 00 00 00 00       	mov    $0x0,%eax
80104299:	83 f8 0f             	cmp    $0xf,%eax
8010429c:	7f 12                	jg     801042b0 <fdalloc+0x2c>
    if(curproc->ofile[fd] == 0){
8010429e:	83 7c 82 28 00       	cmpl   $0x0,0x28(%edx,%eax,4)
801042a3:	74 05                	je     801042aa <fdalloc+0x26>
  for(fd = 0; fd < NOFILE; fd++){
801042a5:	83 c0 01             	add    $0x1,%eax
801042a8:	eb ef                	jmp    80104299 <fdalloc+0x15>
      curproc->ofile[fd] = f;
801042aa:	89 5c 82 28          	mov    %ebx,0x28(%edx,%eax,4)
      return fd;
801042ae:	eb 05                	jmp    801042b5 <fdalloc+0x31>
    }
  }
  return -1;
801042b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801042b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042b8:	c9                   	leave  
801042b9:	c3                   	ret    

801042ba <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801042ba:	55                   	push   %ebp
801042bb:	89 e5                	mov    %esp,%ebp
801042bd:	56                   	push   %esi
801042be:	53                   	push   %ebx
801042bf:	83 ec 10             	sub    $0x10,%esp
801042c2:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801042c4:	b8 20 00 00 00       	mov    $0x20,%eax
801042c9:	89 c6                	mov    %eax,%esi
801042cb:	39 43 58             	cmp    %eax,0x58(%ebx)
801042ce:	76 2e                	jbe    801042fe <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801042d0:	6a 10                	push   $0x10
801042d2:	50                   	push   %eax
801042d3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801042d6:	50                   	push   %eax
801042d7:	53                   	push   %ebx
801042d8:	e8 84 d4 ff ff       	call   80101761 <readi>
801042dd:	83 c4 10             	add    $0x10,%esp
801042e0:	83 f8 10             	cmp    $0x10,%eax
801042e3:	75 0c                	jne    801042f1 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
801042e5:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
801042ea:	75 1e                	jne    8010430a <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801042ec:	8d 46 10             	lea    0x10(%esi),%eax
801042ef:	eb d8                	jmp    801042c9 <isdirempty+0xf>
      panic("isdirempty: readi");
801042f1:	83 ec 0c             	sub    $0xc,%esp
801042f4:	68 6c 71 10 80       	push   $0x8010716c
801042f9:	e8 4a c0 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
801042fe:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104303:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104306:	5b                   	pop    %ebx
80104307:	5e                   	pop    %esi
80104308:	5d                   	pop    %ebp
80104309:	c3                   	ret    
      return 0;
8010430a:	b8 00 00 00 00       	mov    $0x0,%eax
8010430f:	eb f2                	jmp    80104303 <isdirempty+0x49>

80104311 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104311:	55                   	push   %ebp
80104312:	89 e5                	mov    %esp,%ebp
80104314:	57                   	push   %edi
80104315:	56                   	push   %esi
80104316:	53                   	push   %ebx
80104317:	83 ec 34             	sub    $0x34,%esp
8010431a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010431d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104320:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104323:	8d 55 da             	lea    -0x26(%ebp),%edx
80104326:	52                   	push   %edx
80104327:	50                   	push   %eax
80104328:	e8 b8 d8 ff ff       	call   80101be5 <nameiparent>
8010432d:	89 c6                	mov    %eax,%esi
8010432f:	83 c4 10             	add    $0x10,%esp
80104332:	85 c0                	test   %eax,%eax
80104334:	0f 84 33 01 00 00    	je     8010446d <create+0x15c>
    return 0;
  ilock(dp);
8010433a:	83 ec 0c             	sub    $0xc,%esp
8010433d:	50                   	push   %eax
8010433e:	e8 2c d2 ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104343:	83 c4 0c             	add    $0xc,%esp
80104346:	6a 00                	push   $0x0
80104348:	8d 45 da             	lea    -0x26(%ebp),%eax
8010434b:	50                   	push   %eax
8010434c:	56                   	push   %esi
8010434d:	e8 4d d6 ff ff       	call   8010199f <dirlookup>
80104352:	89 c3                	mov    %eax,%ebx
80104354:	83 c4 10             	add    $0x10,%esp
80104357:	85 c0                	test   %eax,%eax
80104359:	74 3d                	je     80104398 <create+0x87>
    iunlockput(dp);
8010435b:	83 ec 0c             	sub    $0xc,%esp
8010435e:	56                   	push   %esi
8010435f:	e8 b2 d3 ff ff       	call   80101716 <iunlockput>
    ilock(ip);
80104364:	89 1c 24             	mov    %ebx,(%esp)
80104367:	e8 03 d2 ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010436c:	83 c4 10             	add    $0x10,%esp
8010436f:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104374:	75 07                	jne    8010437d <create+0x6c>
80104376:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
8010437b:	74 11                	je     8010438e <create+0x7d>
      return ip;
    iunlockput(ip);
8010437d:	83 ec 0c             	sub    $0xc,%esp
80104380:	53                   	push   %ebx
80104381:	e8 90 d3 ff ff       	call   80101716 <iunlockput>
    return 0;
80104386:	83 c4 10             	add    $0x10,%esp
80104389:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010438e:	89 d8                	mov    %ebx,%eax
80104390:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104393:	5b                   	pop    %ebx
80104394:	5e                   	pop    %esi
80104395:	5f                   	pop    %edi
80104396:	5d                   	pop    %ebp
80104397:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104398:	83 ec 08             	sub    $0x8,%esp
8010439b:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
8010439f:	50                   	push   %eax
801043a0:	ff 36                	push   (%esi)
801043a2:	e8 c5 cf ff ff       	call   8010136c <ialloc>
801043a7:	89 c3                	mov    %eax,%ebx
801043a9:	83 c4 10             	add    $0x10,%esp
801043ac:	85 c0                	test   %eax,%eax
801043ae:	74 52                	je     80104402 <create+0xf1>
  ilock(ip);
801043b0:	83 ec 0c             	sub    $0xc,%esp
801043b3:	50                   	push   %eax
801043b4:	e8 b6 d1 ff ff       	call   8010156f <ilock>
  ip->major = major;
801043b9:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
801043bd:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801043c1:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801043c5:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801043cb:	89 1c 24             	mov    %ebx,(%esp)
801043ce:	e8 3b d0 ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801043d3:	83 c4 10             	add    $0x10,%esp
801043d6:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801043db:	74 32                	je     8010440f <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
801043dd:	83 ec 04             	sub    $0x4,%esp
801043e0:	ff 73 04             	push   0x4(%ebx)
801043e3:	8d 45 da             	lea    -0x26(%ebp),%eax
801043e6:	50                   	push   %eax
801043e7:	56                   	push   %esi
801043e8:	e8 2f d7 ff ff       	call   80101b1c <dirlink>
801043ed:	83 c4 10             	add    $0x10,%esp
801043f0:	85 c0                	test   %eax,%eax
801043f2:	78 6c                	js     80104460 <create+0x14f>
  iunlockput(dp);
801043f4:	83 ec 0c             	sub    $0xc,%esp
801043f7:	56                   	push   %esi
801043f8:	e8 19 d3 ff ff       	call   80101716 <iunlockput>
  return ip;
801043fd:	83 c4 10             	add    $0x10,%esp
80104400:	eb 8c                	jmp    8010438e <create+0x7d>
    panic("create: ialloc");
80104402:	83 ec 0c             	sub    $0xc,%esp
80104405:	68 7e 71 10 80       	push   $0x8010717e
8010440a:	e8 39 bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
8010440f:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104413:	83 c0 01             	add    $0x1,%eax
80104416:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010441a:	83 ec 0c             	sub    $0xc,%esp
8010441d:	56                   	push   %esi
8010441e:	e8 eb cf ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104423:	83 c4 0c             	add    $0xc,%esp
80104426:	ff 73 04             	push   0x4(%ebx)
80104429:	68 8e 71 10 80       	push   $0x8010718e
8010442e:	53                   	push   %ebx
8010442f:	e8 e8 d6 ff ff       	call   80101b1c <dirlink>
80104434:	83 c4 10             	add    $0x10,%esp
80104437:	85 c0                	test   %eax,%eax
80104439:	78 18                	js     80104453 <create+0x142>
8010443b:	83 ec 04             	sub    $0x4,%esp
8010443e:	ff 76 04             	push   0x4(%esi)
80104441:	68 8d 71 10 80       	push   $0x8010718d
80104446:	53                   	push   %ebx
80104447:	e8 d0 d6 ff ff       	call   80101b1c <dirlink>
8010444c:	83 c4 10             	add    $0x10,%esp
8010444f:	85 c0                	test   %eax,%eax
80104451:	79 8a                	jns    801043dd <create+0xcc>
      panic("create dots");
80104453:	83 ec 0c             	sub    $0xc,%esp
80104456:	68 90 71 10 80       	push   $0x80107190
8010445b:	e8 e8 be ff ff       	call   80100348 <panic>
    panic("create: dirlink");
80104460:	83 ec 0c             	sub    $0xc,%esp
80104463:	68 9c 71 10 80       	push   $0x8010719c
80104468:	e8 db be ff ff       	call   80100348 <panic>
    return 0;
8010446d:	89 c3                	mov    %eax,%ebx
8010446f:	e9 1a ff ff ff       	jmp    8010438e <create+0x7d>

80104474 <sys_dup>:
{
80104474:	55                   	push   %ebp
80104475:	89 e5                	mov    %esp,%ebp
80104477:	53                   	push   %ebx
80104478:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010447b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010447e:	ba 00 00 00 00       	mov    $0x0,%edx
80104483:	b8 00 00 00 00       	mov    $0x0,%eax
80104488:	e8 97 fd ff ff       	call   80104224 <argfd>
8010448d:	85 c0                	test   %eax,%eax
8010448f:	78 23                	js     801044b4 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
80104491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104494:	e8 eb fd ff ff       	call   80104284 <fdalloc>
80104499:	89 c3                	mov    %eax,%ebx
8010449b:	85 c0                	test   %eax,%eax
8010449d:	78 1c                	js     801044bb <sys_dup+0x47>
  filedup(f);
8010449f:	83 ec 0c             	sub    $0xc,%esp
801044a2:	ff 75 f4             	push   -0xc(%ebp)
801044a5:	e8 d4 c7 ff ff       	call   80100c7e <filedup>
  return fd;
801044aa:	83 c4 10             	add    $0x10,%esp
}
801044ad:	89 d8                	mov    %ebx,%eax
801044af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044b2:	c9                   	leave  
801044b3:	c3                   	ret    
    return -1;
801044b4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044b9:	eb f2                	jmp    801044ad <sys_dup+0x39>
    return -1;
801044bb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044c0:	eb eb                	jmp    801044ad <sys_dup+0x39>

801044c2 <sys_read>:
{
801044c2:	55                   	push   %ebp
801044c3:	89 e5                	mov    %esp,%ebp
801044c5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801044c8:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044cb:	ba 00 00 00 00       	mov    $0x0,%edx
801044d0:	b8 00 00 00 00       	mov    $0x0,%eax
801044d5:	e8 4a fd ff ff       	call   80104224 <argfd>
801044da:	85 c0                	test   %eax,%eax
801044dc:	78 43                	js     80104521 <sys_read+0x5f>
801044de:	83 ec 08             	sub    $0x8,%esp
801044e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044e4:	50                   	push   %eax
801044e5:	6a 02                	push   $0x2
801044e7:	e8 1e fc ff ff       	call   8010410a <argint>
801044ec:	83 c4 10             	add    $0x10,%esp
801044ef:	85 c0                	test   %eax,%eax
801044f1:	78 2e                	js     80104521 <sys_read+0x5f>
801044f3:	83 ec 04             	sub    $0x4,%esp
801044f6:	ff 75 f0             	push   -0x10(%ebp)
801044f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801044fc:	50                   	push   %eax
801044fd:	6a 01                	push   $0x1
801044ff:	e8 2e fc ff ff       	call   80104132 <argptr>
80104504:	83 c4 10             	add    $0x10,%esp
80104507:	85 c0                	test   %eax,%eax
80104509:	78 16                	js     80104521 <sys_read+0x5f>
  return fileread(f, p, n);
8010450b:	83 ec 04             	sub    $0x4,%esp
8010450e:	ff 75 f0             	push   -0x10(%ebp)
80104511:	ff 75 ec             	push   -0x14(%ebp)
80104514:	ff 75 f4             	push   -0xc(%ebp)
80104517:	e8 b4 c8 ff ff       	call   80100dd0 <fileread>
8010451c:	83 c4 10             	add    $0x10,%esp
}
8010451f:	c9                   	leave  
80104520:	c3                   	ret    
    return -1;
80104521:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104526:	eb f7                	jmp    8010451f <sys_read+0x5d>

80104528 <sys_write>:
{
80104528:	55                   	push   %ebp
80104529:	89 e5                	mov    %esp,%ebp
8010452b:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010452e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104531:	ba 00 00 00 00       	mov    $0x0,%edx
80104536:	b8 00 00 00 00       	mov    $0x0,%eax
8010453b:	e8 e4 fc ff ff       	call   80104224 <argfd>
80104540:	85 c0                	test   %eax,%eax
80104542:	78 43                	js     80104587 <sys_write+0x5f>
80104544:	83 ec 08             	sub    $0x8,%esp
80104547:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010454a:	50                   	push   %eax
8010454b:	6a 02                	push   $0x2
8010454d:	e8 b8 fb ff ff       	call   8010410a <argint>
80104552:	83 c4 10             	add    $0x10,%esp
80104555:	85 c0                	test   %eax,%eax
80104557:	78 2e                	js     80104587 <sys_write+0x5f>
80104559:	83 ec 04             	sub    $0x4,%esp
8010455c:	ff 75 f0             	push   -0x10(%ebp)
8010455f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104562:	50                   	push   %eax
80104563:	6a 01                	push   $0x1
80104565:	e8 c8 fb ff ff       	call   80104132 <argptr>
8010456a:	83 c4 10             	add    $0x10,%esp
8010456d:	85 c0                	test   %eax,%eax
8010456f:	78 16                	js     80104587 <sys_write+0x5f>
  return filewrite(f, p, n);
80104571:	83 ec 04             	sub    $0x4,%esp
80104574:	ff 75 f0             	push   -0x10(%ebp)
80104577:	ff 75 ec             	push   -0x14(%ebp)
8010457a:	ff 75 f4             	push   -0xc(%ebp)
8010457d:	e8 d3 c8 ff ff       	call   80100e55 <filewrite>
80104582:	83 c4 10             	add    $0x10,%esp
}
80104585:	c9                   	leave  
80104586:	c3                   	ret    
    return -1;
80104587:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010458c:	eb f7                	jmp    80104585 <sys_write+0x5d>

8010458e <sys_close>:
{
8010458e:	55                   	push   %ebp
8010458f:	89 e5                	mov    %esp,%ebp
80104591:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104594:	8d 4d f0             	lea    -0x10(%ebp),%ecx
80104597:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010459a:	b8 00 00 00 00       	mov    $0x0,%eax
8010459f:	e8 80 fc ff ff       	call   80104224 <argfd>
801045a4:	85 c0                	test   %eax,%eax
801045a6:	78 25                	js     801045cd <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801045a8:	e8 05 ed ff ff       	call   801032b2 <myproc>
801045ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b0:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801045b7:	00 
  fileclose(f);
801045b8:	83 ec 0c             	sub    $0xc,%esp
801045bb:	ff 75 f0             	push   -0x10(%ebp)
801045be:	e8 00 c7 ff ff       	call   80100cc3 <fileclose>
  return 0;
801045c3:	83 c4 10             	add    $0x10,%esp
801045c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045cb:	c9                   	leave  
801045cc:	c3                   	ret    
    return -1;
801045cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d2:	eb f7                	jmp    801045cb <sys_close+0x3d>

801045d4 <sys_fstat>:
{
801045d4:	55                   	push   %ebp
801045d5:	89 e5                	mov    %esp,%ebp
801045d7:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801045da:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801045dd:	ba 00 00 00 00       	mov    $0x0,%edx
801045e2:	b8 00 00 00 00       	mov    $0x0,%eax
801045e7:	e8 38 fc ff ff       	call   80104224 <argfd>
801045ec:	85 c0                	test   %eax,%eax
801045ee:	78 2a                	js     8010461a <sys_fstat+0x46>
801045f0:	83 ec 04             	sub    $0x4,%esp
801045f3:	6a 14                	push   $0x14
801045f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801045f8:	50                   	push   %eax
801045f9:	6a 01                	push   $0x1
801045fb:	e8 32 fb ff ff       	call   80104132 <argptr>
80104600:	83 c4 10             	add    $0x10,%esp
80104603:	85 c0                	test   %eax,%eax
80104605:	78 13                	js     8010461a <sys_fstat+0x46>
  return filestat(f, st);
80104607:	83 ec 08             	sub    $0x8,%esp
8010460a:	ff 75 f0             	push   -0x10(%ebp)
8010460d:	ff 75 f4             	push   -0xc(%ebp)
80104610:	e8 74 c7 ff ff       	call   80100d89 <filestat>
80104615:	83 c4 10             	add    $0x10,%esp
}
80104618:	c9                   	leave  
80104619:	c3                   	ret    
    return -1;
8010461a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010461f:	eb f7                	jmp    80104618 <sys_fstat+0x44>

80104621 <sys_link>:
{
80104621:	55                   	push   %ebp
80104622:	89 e5                	mov    %esp,%ebp
80104624:	56                   	push   %esi
80104625:	53                   	push   %ebx
80104626:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104629:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010462c:	50                   	push   %eax
8010462d:	6a 00                	push   $0x0
8010462f:	e8 66 fb ff ff       	call   8010419a <argstr>
80104634:	83 c4 10             	add    $0x10,%esp
80104637:	85 c0                	test   %eax,%eax
80104639:	0f 88 d3 00 00 00    	js     80104712 <sys_link+0xf1>
8010463f:	83 ec 08             	sub    $0x8,%esp
80104642:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104645:	50                   	push   %eax
80104646:	6a 01                	push   $0x1
80104648:	e8 4d fb ff ff       	call   8010419a <argstr>
8010464d:	83 c4 10             	add    $0x10,%esp
80104650:	85 c0                	test   %eax,%eax
80104652:	0f 88 ba 00 00 00    	js     80104712 <sys_link+0xf1>
  begin_op();
80104658:	e8 eb e1 ff ff       	call   80102848 <begin_op>
  if((ip = namei(old)) == 0){
8010465d:	83 ec 0c             	sub    $0xc,%esp
80104660:	ff 75 e0             	push   -0x20(%ebp)
80104663:	e8 65 d5 ff ff       	call   80101bcd <namei>
80104668:	89 c3                	mov    %eax,%ebx
8010466a:	83 c4 10             	add    $0x10,%esp
8010466d:	85 c0                	test   %eax,%eax
8010466f:	0f 84 a4 00 00 00    	je     80104719 <sys_link+0xf8>
  ilock(ip);
80104675:	83 ec 0c             	sub    $0xc,%esp
80104678:	50                   	push   %eax
80104679:	e8 f1 ce ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
8010467e:	83 c4 10             	add    $0x10,%esp
80104681:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104686:	0f 84 99 00 00 00    	je     80104725 <sys_link+0x104>
  ip->nlink++;
8010468c:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104690:	83 c0 01             	add    $0x1,%eax
80104693:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104697:	83 ec 0c             	sub    $0xc,%esp
8010469a:	53                   	push   %ebx
8010469b:	e8 6e cd ff ff       	call   8010140e <iupdate>
  iunlock(ip);
801046a0:	89 1c 24             	mov    %ebx,(%esp)
801046a3:	e8 89 cf ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801046a8:	83 c4 08             	add    $0x8,%esp
801046ab:	8d 45 ea             	lea    -0x16(%ebp),%eax
801046ae:	50                   	push   %eax
801046af:	ff 75 e4             	push   -0x1c(%ebp)
801046b2:	e8 2e d5 ff ff       	call   80101be5 <nameiparent>
801046b7:	89 c6                	mov    %eax,%esi
801046b9:	83 c4 10             	add    $0x10,%esp
801046bc:	85 c0                	test   %eax,%eax
801046be:	0f 84 85 00 00 00    	je     80104749 <sys_link+0x128>
  ilock(dp);
801046c4:	83 ec 0c             	sub    $0xc,%esp
801046c7:	50                   	push   %eax
801046c8:	e8 a2 ce ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801046cd:	83 c4 10             	add    $0x10,%esp
801046d0:	8b 03                	mov    (%ebx),%eax
801046d2:	39 06                	cmp    %eax,(%esi)
801046d4:	75 67                	jne    8010473d <sys_link+0x11c>
801046d6:	83 ec 04             	sub    $0x4,%esp
801046d9:	ff 73 04             	push   0x4(%ebx)
801046dc:	8d 45 ea             	lea    -0x16(%ebp),%eax
801046df:	50                   	push   %eax
801046e0:	56                   	push   %esi
801046e1:	e8 36 d4 ff ff       	call   80101b1c <dirlink>
801046e6:	83 c4 10             	add    $0x10,%esp
801046e9:	85 c0                	test   %eax,%eax
801046eb:	78 50                	js     8010473d <sys_link+0x11c>
  iunlockput(dp);
801046ed:	83 ec 0c             	sub    $0xc,%esp
801046f0:	56                   	push   %esi
801046f1:	e8 20 d0 ff ff       	call   80101716 <iunlockput>
  iput(ip);
801046f6:	89 1c 24             	mov    %ebx,(%esp)
801046f9:	e8 78 cf ff ff       	call   80101676 <iput>
  end_op();
801046fe:	e8 bf e1 ff ff       	call   801028c2 <end_op>
  return 0;
80104703:	83 c4 10             	add    $0x10,%esp
80104706:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010470b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010470e:	5b                   	pop    %ebx
8010470f:	5e                   	pop    %esi
80104710:	5d                   	pop    %ebp
80104711:	c3                   	ret    
    return -1;
80104712:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104717:	eb f2                	jmp    8010470b <sys_link+0xea>
    end_op();
80104719:	e8 a4 e1 ff ff       	call   801028c2 <end_op>
    return -1;
8010471e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104723:	eb e6                	jmp    8010470b <sys_link+0xea>
    iunlockput(ip);
80104725:	83 ec 0c             	sub    $0xc,%esp
80104728:	53                   	push   %ebx
80104729:	e8 e8 cf ff ff       	call   80101716 <iunlockput>
    end_op();
8010472e:	e8 8f e1 ff ff       	call   801028c2 <end_op>
    return -1;
80104733:	83 c4 10             	add    $0x10,%esp
80104736:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010473b:	eb ce                	jmp    8010470b <sys_link+0xea>
    iunlockput(dp);
8010473d:	83 ec 0c             	sub    $0xc,%esp
80104740:	56                   	push   %esi
80104741:	e8 d0 cf ff ff       	call   80101716 <iunlockput>
    goto bad;
80104746:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104749:	83 ec 0c             	sub    $0xc,%esp
8010474c:	53                   	push   %ebx
8010474d:	e8 1d ce ff ff       	call   8010156f <ilock>
  ip->nlink--;
80104752:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104756:	83 e8 01             	sub    $0x1,%eax
80104759:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010475d:	89 1c 24             	mov    %ebx,(%esp)
80104760:	e8 a9 cc ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
80104765:	89 1c 24             	mov    %ebx,(%esp)
80104768:	e8 a9 cf ff ff       	call   80101716 <iunlockput>
  end_op();
8010476d:	e8 50 e1 ff ff       	call   801028c2 <end_op>
  return -1;
80104772:	83 c4 10             	add    $0x10,%esp
80104775:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010477a:	eb 8f                	jmp    8010470b <sys_link+0xea>

8010477c <sys_unlink>:
{
8010477c:	55                   	push   %ebp
8010477d:	89 e5                	mov    %esp,%ebp
8010477f:	57                   	push   %edi
80104780:	56                   	push   %esi
80104781:	53                   	push   %ebx
80104782:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104785:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104788:	50                   	push   %eax
80104789:	6a 00                	push   $0x0
8010478b:	e8 0a fa ff ff       	call   8010419a <argstr>
80104790:	83 c4 10             	add    $0x10,%esp
80104793:	85 c0                	test   %eax,%eax
80104795:	0f 88 83 01 00 00    	js     8010491e <sys_unlink+0x1a2>
  begin_op();
8010479b:	e8 a8 e0 ff ff       	call   80102848 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801047a0:	83 ec 08             	sub    $0x8,%esp
801047a3:	8d 45 ca             	lea    -0x36(%ebp),%eax
801047a6:	50                   	push   %eax
801047a7:	ff 75 c4             	push   -0x3c(%ebp)
801047aa:	e8 36 d4 ff ff       	call   80101be5 <nameiparent>
801047af:	89 c6                	mov    %eax,%esi
801047b1:	83 c4 10             	add    $0x10,%esp
801047b4:	85 c0                	test   %eax,%eax
801047b6:	0f 84 ed 00 00 00    	je     801048a9 <sys_unlink+0x12d>
  ilock(dp);
801047bc:	83 ec 0c             	sub    $0xc,%esp
801047bf:	50                   	push   %eax
801047c0:	e8 aa cd ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801047c5:	83 c4 08             	add    $0x8,%esp
801047c8:	68 8e 71 10 80       	push   $0x8010718e
801047cd:	8d 45 ca             	lea    -0x36(%ebp),%eax
801047d0:	50                   	push   %eax
801047d1:	e8 b4 d1 ff ff       	call   8010198a <namecmp>
801047d6:	83 c4 10             	add    $0x10,%esp
801047d9:	85 c0                	test   %eax,%eax
801047db:	0f 84 fc 00 00 00    	je     801048dd <sys_unlink+0x161>
801047e1:	83 ec 08             	sub    $0x8,%esp
801047e4:	68 8d 71 10 80       	push   $0x8010718d
801047e9:	8d 45 ca             	lea    -0x36(%ebp),%eax
801047ec:	50                   	push   %eax
801047ed:	e8 98 d1 ff ff       	call   8010198a <namecmp>
801047f2:	83 c4 10             	add    $0x10,%esp
801047f5:	85 c0                	test   %eax,%eax
801047f7:	0f 84 e0 00 00 00    	je     801048dd <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
801047fd:	83 ec 04             	sub    $0x4,%esp
80104800:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104803:	50                   	push   %eax
80104804:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104807:	50                   	push   %eax
80104808:	56                   	push   %esi
80104809:	e8 91 d1 ff ff       	call   8010199f <dirlookup>
8010480e:	89 c3                	mov    %eax,%ebx
80104810:	83 c4 10             	add    $0x10,%esp
80104813:	85 c0                	test   %eax,%eax
80104815:	0f 84 c2 00 00 00    	je     801048dd <sys_unlink+0x161>
  ilock(ip);
8010481b:	83 ec 0c             	sub    $0xc,%esp
8010481e:	50                   	push   %eax
8010481f:	e8 4b cd ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
80104824:	83 c4 10             	add    $0x10,%esp
80104827:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010482c:	0f 8e 83 00 00 00    	jle    801048b5 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104832:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104837:	0f 84 85 00 00 00    	je     801048c2 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
8010483d:	83 ec 04             	sub    $0x4,%esp
80104840:	6a 10                	push   $0x10
80104842:	6a 00                	push   $0x0
80104844:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104847:	57                   	push   %edi
80104848:	e8 6d f6 ff ff       	call   80103eba <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010484d:	6a 10                	push   $0x10
8010484f:	ff 75 c0             	push   -0x40(%ebp)
80104852:	57                   	push   %edi
80104853:	56                   	push   %esi
80104854:	e8 05 d0 ff ff       	call   8010185e <writei>
80104859:	83 c4 20             	add    $0x20,%esp
8010485c:	83 f8 10             	cmp    $0x10,%eax
8010485f:	0f 85 90 00 00 00    	jne    801048f5 <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104865:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010486a:	0f 84 92 00 00 00    	je     80104902 <sys_unlink+0x186>
  iunlockput(dp);
80104870:	83 ec 0c             	sub    $0xc,%esp
80104873:	56                   	push   %esi
80104874:	e8 9d ce ff ff       	call   80101716 <iunlockput>
  ip->nlink--;
80104879:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010487d:	83 e8 01             	sub    $0x1,%eax
80104880:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104884:	89 1c 24             	mov    %ebx,(%esp)
80104887:	e8 82 cb ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
8010488c:	89 1c 24             	mov    %ebx,(%esp)
8010488f:	e8 82 ce ff ff       	call   80101716 <iunlockput>
  end_op();
80104894:	e8 29 e0 ff ff       	call   801028c2 <end_op>
  return 0;
80104899:	83 c4 10             	add    $0x10,%esp
8010489c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048a4:	5b                   	pop    %ebx
801048a5:	5e                   	pop    %esi
801048a6:	5f                   	pop    %edi
801048a7:	5d                   	pop    %ebp
801048a8:	c3                   	ret    
    end_op();
801048a9:	e8 14 e0 ff ff       	call   801028c2 <end_op>
    return -1;
801048ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048b3:	eb ec                	jmp    801048a1 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
801048b5:	83 ec 0c             	sub    $0xc,%esp
801048b8:	68 ac 71 10 80       	push   $0x801071ac
801048bd:	e8 86 ba ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801048c2:	89 d8                	mov    %ebx,%eax
801048c4:	e8 f1 f9 ff ff       	call   801042ba <isdirempty>
801048c9:	85 c0                	test   %eax,%eax
801048cb:	0f 85 6c ff ff ff    	jne    8010483d <sys_unlink+0xc1>
    iunlockput(ip);
801048d1:	83 ec 0c             	sub    $0xc,%esp
801048d4:	53                   	push   %ebx
801048d5:	e8 3c ce ff ff       	call   80101716 <iunlockput>
    goto bad;
801048da:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
801048dd:	83 ec 0c             	sub    $0xc,%esp
801048e0:	56                   	push   %esi
801048e1:	e8 30 ce ff ff       	call   80101716 <iunlockput>
  end_op();
801048e6:	e8 d7 df ff ff       	call   801028c2 <end_op>
  return -1;
801048eb:	83 c4 10             	add    $0x10,%esp
801048ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048f3:	eb ac                	jmp    801048a1 <sys_unlink+0x125>
    panic("unlink: writei");
801048f5:	83 ec 0c             	sub    $0xc,%esp
801048f8:	68 be 71 10 80       	push   $0x801071be
801048fd:	e8 46 ba ff ff       	call   80100348 <panic>
    dp->nlink--;
80104902:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104906:	83 e8 01             	sub    $0x1,%eax
80104909:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010490d:	83 ec 0c             	sub    $0xc,%esp
80104910:	56                   	push   %esi
80104911:	e8 f8 ca ff ff       	call   8010140e <iupdate>
80104916:	83 c4 10             	add    $0x10,%esp
80104919:	e9 52 ff ff ff       	jmp    80104870 <sys_unlink+0xf4>
    return -1;
8010491e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104923:	e9 79 ff ff ff       	jmp    801048a1 <sys_unlink+0x125>

80104928 <sys_open>:

int
sys_open(void)
{
80104928:	55                   	push   %ebp
80104929:	89 e5                	mov    %esp,%ebp
8010492b:	57                   	push   %edi
8010492c:	56                   	push   %esi
8010492d:	53                   	push   %ebx
8010492e:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104931:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104934:	50                   	push   %eax
80104935:	6a 00                	push   $0x0
80104937:	e8 5e f8 ff ff       	call   8010419a <argstr>
8010493c:	83 c4 10             	add    $0x10,%esp
8010493f:	85 c0                	test   %eax,%eax
80104941:	0f 88 a0 00 00 00    	js     801049e7 <sys_open+0xbf>
80104947:	83 ec 08             	sub    $0x8,%esp
8010494a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010494d:	50                   	push   %eax
8010494e:	6a 01                	push   $0x1
80104950:	e8 b5 f7 ff ff       	call   8010410a <argint>
80104955:	83 c4 10             	add    $0x10,%esp
80104958:	85 c0                	test   %eax,%eax
8010495a:	0f 88 87 00 00 00    	js     801049e7 <sys_open+0xbf>
    return -1;

  begin_op();
80104960:	e8 e3 de ff ff       	call   80102848 <begin_op>

  if(omode & O_CREATE){
80104965:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104969:	0f 84 8b 00 00 00    	je     801049fa <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
8010496f:	83 ec 0c             	sub    $0xc,%esp
80104972:	6a 00                	push   $0x0
80104974:	b9 00 00 00 00       	mov    $0x0,%ecx
80104979:	ba 02 00 00 00       	mov    $0x2,%edx
8010497e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104981:	e8 8b f9 ff ff       	call   80104311 <create>
80104986:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104988:	83 c4 10             	add    $0x10,%esp
8010498b:	85 c0                	test   %eax,%eax
8010498d:	74 5f                	je     801049ee <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010498f:	e8 89 c2 ff ff       	call   80100c1d <filealloc>
80104994:	89 c3                	mov    %eax,%ebx
80104996:	85 c0                	test   %eax,%eax
80104998:	0f 84 b5 00 00 00    	je     80104a53 <sys_open+0x12b>
8010499e:	e8 e1 f8 ff ff       	call   80104284 <fdalloc>
801049a3:	89 c7                	mov    %eax,%edi
801049a5:	85 c0                	test   %eax,%eax
801049a7:	0f 88 a6 00 00 00    	js     80104a53 <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801049ad:	83 ec 0c             	sub    $0xc,%esp
801049b0:	56                   	push   %esi
801049b1:	e8 7b cc ff ff       	call   80101631 <iunlock>
  end_op();
801049b6:	e8 07 df ff ff       	call   801028c2 <end_op>

  f->type = FD_INODE;
801049bb:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801049c1:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801049c4:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
801049cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ce:	83 c4 10             	add    $0x10,%esp
801049d1:	a8 01                	test   $0x1,%al
801049d3:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801049d7:	a8 03                	test   $0x3,%al
801049d9:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
801049dd:	89 f8                	mov    %edi,%eax
801049df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801049e2:	5b                   	pop    %ebx
801049e3:	5e                   	pop    %esi
801049e4:	5f                   	pop    %edi
801049e5:	5d                   	pop    %ebp
801049e6:	c3                   	ret    
    return -1;
801049e7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049ec:	eb ef                	jmp    801049dd <sys_open+0xb5>
      end_op();
801049ee:	e8 cf de ff ff       	call   801028c2 <end_op>
      return -1;
801049f3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049f8:	eb e3                	jmp    801049dd <sys_open+0xb5>
    if((ip = namei(path)) == 0){
801049fa:	83 ec 0c             	sub    $0xc,%esp
801049fd:	ff 75 e4             	push   -0x1c(%ebp)
80104a00:	e8 c8 d1 ff ff       	call   80101bcd <namei>
80104a05:	89 c6                	mov    %eax,%esi
80104a07:	83 c4 10             	add    $0x10,%esp
80104a0a:	85 c0                	test   %eax,%eax
80104a0c:	74 39                	je     80104a47 <sys_open+0x11f>
    ilock(ip);
80104a0e:	83 ec 0c             	sub    $0xc,%esp
80104a11:	50                   	push   %eax
80104a12:	e8 58 cb ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104a17:	83 c4 10             	add    $0x10,%esp
80104a1a:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104a1f:	0f 85 6a ff ff ff    	jne    8010498f <sys_open+0x67>
80104a25:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104a29:	0f 84 60 ff ff ff    	je     8010498f <sys_open+0x67>
      iunlockput(ip);
80104a2f:	83 ec 0c             	sub    $0xc,%esp
80104a32:	56                   	push   %esi
80104a33:	e8 de cc ff ff       	call   80101716 <iunlockput>
      end_op();
80104a38:	e8 85 de ff ff       	call   801028c2 <end_op>
      return -1;
80104a3d:	83 c4 10             	add    $0x10,%esp
80104a40:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a45:	eb 96                	jmp    801049dd <sys_open+0xb5>
      end_op();
80104a47:	e8 76 de ff ff       	call   801028c2 <end_op>
      return -1;
80104a4c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a51:	eb 8a                	jmp    801049dd <sys_open+0xb5>
    if(f)
80104a53:	85 db                	test   %ebx,%ebx
80104a55:	74 0c                	je     80104a63 <sys_open+0x13b>
      fileclose(f);
80104a57:	83 ec 0c             	sub    $0xc,%esp
80104a5a:	53                   	push   %ebx
80104a5b:	e8 63 c2 ff ff       	call   80100cc3 <fileclose>
80104a60:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104a63:	83 ec 0c             	sub    $0xc,%esp
80104a66:	56                   	push   %esi
80104a67:	e8 aa cc ff ff       	call   80101716 <iunlockput>
    end_op();
80104a6c:	e8 51 de ff ff       	call   801028c2 <end_op>
    return -1;
80104a71:	83 c4 10             	add    $0x10,%esp
80104a74:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a79:	e9 5f ff ff ff       	jmp    801049dd <sys_open+0xb5>

80104a7e <sys_mkdir>:

int
sys_mkdir(void)
{
80104a7e:	55                   	push   %ebp
80104a7f:	89 e5                	mov    %esp,%ebp
80104a81:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104a84:	e8 bf dd ff ff       	call   80102848 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104a89:	83 ec 08             	sub    $0x8,%esp
80104a8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a8f:	50                   	push   %eax
80104a90:	6a 00                	push   $0x0
80104a92:	e8 03 f7 ff ff       	call   8010419a <argstr>
80104a97:	83 c4 10             	add    $0x10,%esp
80104a9a:	85 c0                	test   %eax,%eax
80104a9c:	78 36                	js     80104ad4 <sys_mkdir+0x56>
80104a9e:	83 ec 0c             	sub    $0xc,%esp
80104aa1:	6a 00                	push   $0x0
80104aa3:	b9 00 00 00 00       	mov    $0x0,%ecx
80104aa8:	ba 01 00 00 00       	mov    $0x1,%edx
80104aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab0:	e8 5c f8 ff ff       	call   80104311 <create>
80104ab5:	83 c4 10             	add    $0x10,%esp
80104ab8:	85 c0                	test   %eax,%eax
80104aba:	74 18                	je     80104ad4 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104abc:	83 ec 0c             	sub    $0xc,%esp
80104abf:	50                   	push   %eax
80104ac0:	e8 51 cc ff ff       	call   80101716 <iunlockput>
  end_op();
80104ac5:	e8 f8 dd ff ff       	call   801028c2 <end_op>
  return 0;
80104aca:	83 c4 10             	add    $0x10,%esp
80104acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ad2:	c9                   	leave  
80104ad3:	c3                   	ret    
    end_op();
80104ad4:	e8 e9 dd ff ff       	call   801028c2 <end_op>
    return -1;
80104ad9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ade:	eb f2                	jmp    80104ad2 <sys_mkdir+0x54>

80104ae0 <sys_mknod>:

int
sys_mknod(void)
{
80104ae0:	55                   	push   %ebp
80104ae1:	89 e5                	mov    %esp,%ebp
80104ae3:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104ae6:	e8 5d dd ff ff       	call   80102848 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104aeb:	83 ec 08             	sub    $0x8,%esp
80104aee:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104af1:	50                   	push   %eax
80104af2:	6a 00                	push   $0x0
80104af4:	e8 a1 f6 ff ff       	call   8010419a <argstr>
80104af9:	83 c4 10             	add    $0x10,%esp
80104afc:	85 c0                	test   %eax,%eax
80104afe:	78 62                	js     80104b62 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104b00:	83 ec 08             	sub    $0x8,%esp
80104b03:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b06:	50                   	push   %eax
80104b07:	6a 01                	push   $0x1
80104b09:	e8 fc f5 ff ff       	call   8010410a <argint>
  if((argstr(0, &path)) < 0 ||
80104b0e:	83 c4 10             	add    $0x10,%esp
80104b11:	85 c0                	test   %eax,%eax
80104b13:	78 4d                	js     80104b62 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104b15:	83 ec 08             	sub    $0x8,%esp
80104b18:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b1b:	50                   	push   %eax
80104b1c:	6a 02                	push   $0x2
80104b1e:	e8 e7 f5 ff ff       	call   8010410a <argint>
     argint(1, &major) < 0 ||
80104b23:	83 c4 10             	add    $0x10,%esp
80104b26:	85 c0                	test   %eax,%eax
80104b28:	78 38                	js     80104b62 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104b2a:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104b2e:	83 ec 0c             	sub    $0xc,%esp
80104b31:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104b35:	50                   	push   %eax
80104b36:	ba 03 00 00 00       	mov    $0x3,%edx
80104b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3e:	e8 ce f7 ff ff       	call   80104311 <create>
     argint(2, &minor) < 0 ||
80104b43:	83 c4 10             	add    $0x10,%esp
80104b46:	85 c0                	test   %eax,%eax
80104b48:	74 18                	je     80104b62 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104b4a:	83 ec 0c             	sub    $0xc,%esp
80104b4d:	50                   	push   %eax
80104b4e:	e8 c3 cb ff ff       	call   80101716 <iunlockput>
  end_op();
80104b53:	e8 6a dd ff ff       	call   801028c2 <end_op>
  return 0;
80104b58:	83 c4 10             	add    $0x10,%esp
80104b5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b60:	c9                   	leave  
80104b61:	c3                   	ret    
    end_op();
80104b62:	e8 5b dd ff ff       	call   801028c2 <end_op>
    return -1;
80104b67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6c:	eb f2                	jmp    80104b60 <sys_mknod+0x80>

80104b6e <sys_chdir>:

int
sys_chdir(void)
{
80104b6e:	55                   	push   %ebp
80104b6f:	89 e5                	mov    %esp,%ebp
80104b71:	56                   	push   %esi
80104b72:	53                   	push   %ebx
80104b73:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104b76:	e8 37 e7 ff ff       	call   801032b2 <myproc>
80104b7b:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104b7d:	e8 c6 dc ff ff       	call   80102848 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104b82:	83 ec 08             	sub    $0x8,%esp
80104b85:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b88:	50                   	push   %eax
80104b89:	6a 00                	push   $0x0
80104b8b:	e8 0a f6 ff ff       	call   8010419a <argstr>
80104b90:	83 c4 10             	add    $0x10,%esp
80104b93:	85 c0                	test   %eax,%eax
80104b95:	78 52                	js     80104be9 <sys_chdir+0x7b>
80104b97:	83 ec 0c             	sub    $0xc,%esp
80104b9a:	ff 75 f4             	push   -0xc(%ebp)
80104b9d:	e8 2b d0 ff ff       	call   80101bcd <namei>
80104ba2:	89 c3                	mov    %eax,%ebx
80104ba4:	83 c4 10             	add    $0x10,%esp
80104ba7:	85 c0                	test   %eax,%eax
80104ba9:	74 3e                	je     80104be9 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104bab:	83 ec 0c             	sub    $0xc,%esp
80104bae:	50                   	push   %eax
80104baf:	e8 bb c9 ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
80104bb4:	83 c4 10             	add    $0x10,%esp
80104bb7:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104bbc:	75 37                	jne    80104bf5 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104bbe:	83 ec 0c             	sub    $0xc,%esp
80104bc1:	53                   	push   %ebx
80104bc2:	e8 6a ca ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
80104bc7:	83 c4 04             	add    $0x4,%esp
80104bca:	ff 76 68             	push   0x68(%esi)
80104bcd:	e8 a4 ca ff ff       	call   80101676 <iput>
  end_op();
80104bd2:	e8 eb dc ff ff       	call   801028c2 <end_op>
  curproc->cwd = ip;
80104bd7:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104bda:	83 c4 10             	add    $0x10,%esp
80104bdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104be2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104be5:	5b                   	pop    %ebx
80104be6:	5e                   	pop    %esi
80104be7:	5d                   	pop    %ebp
80104be8:	c3                   	ret    
    end_op();
80104be9:	e8 d4 dc ff ff       	call   801028c2 <end_op>
    return -1;
80104bee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bf3:	eb ed                	jmp    80104be2 <sys_chdir+0x74>
    iunlockput(ip);
80104bf5:	83 ec 0c             	sub    $0xc,%esp
80104bf8:	53                   	push   %ebx
80104bf9:	e8 18 cb ff ff       	call   80101716 <iunlockput>
    end_op();
80104bfe:	e8 bf dc ff ff       	call   801028c2 <end_op>
    return -1;
80104c03:	83 c4 10             	add    $0x10,%esp
80104c06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c0b:	eb d5                	jmp    80104be2 <sys_chdir+0x74>

80104c0d <sys_exec>:

int
sys_exec(void)
{
80104c0d:	55                   	push   %ebp
80104c0e:	89 e5                	mov    %esp,%ebp
80104c10:	53                   	push   %ebx
80104c11:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104c17:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c1a:	50                   	push   %eax
80104c1b:	6a 00                	push   $0x0
80104c1d:	e8 78 f5 ff ff       	call   8010419a <argstr>
80104c22:	83 c4 10             	add    $0x10,%esp
80104c25:	85 c0                	test   %eax,%eax
80104c27:	78 38                	js     80104c61 <sys_exec+0x54>
80104c29:	83 ec 08             	sub    $0x8,%esp
80104c2c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104c32:	50                   	push   %eax
80104c33:	6a 01                	push   $0x1
80104c35:	e8 d0 f4 ff ff       	call   8010410a <argint>
80104c3a:	83 c4 10             	add    $0x10,%esp
80104c3d:	85 c0                	test   %eax,%eax
80104c3f:	78 20                	js     80104c61 <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104c41:	83 ec 04             	sub    $0x4,%esp
80104c44:	68 80 00 00 00       	push   $0x80
80104c49:	6a 00                	push   $0x0
80104c4b:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c51:	50                   	push   %eax
80104c52:	e8 63 f2 ff ff       	call   80103eba <memset>
80104c57:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
80104c5f:	eb 2c                	jmp    80104c8d <sys_exec+0x80>
    return -1;
80104c61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c66:	eb 78                	jmp    80104ce0 <sys_exec+0xd3>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104c68:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104c6f:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104c73:	83 ec 08             	sub    $0x8,%esp
80104c76:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c7c:	50                   	push   %eax
80104c7d:	ff 75 f4             	push   -0xc(%ebp)
80104c80:	e8 49 bc ff ff       	call   801008ce <exec>
80104c85:	83 c4 10             	add    $0x10,%esp
80104c88:	eb 56                	jmp    80104ce0 <sys_exec+0xd3>
  for(i=0;; i++){
80104c8a:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104c8d:	83 fb 1f             	cmp    $0x1f,%ebx
80104c90:	77 49                	ja     80104cdb <sys_exec+0xce>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104c92:	83 ec 08             	sub    $0x8,%esp
80104c95:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104c9b:	50                   	push   %eax
80104c9c:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104ca2:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104ca5:	50                   	push   %eax
80104ca6:	e8 e5 f3 ff ff       	call   80104090 <fetchint>
80104cab:	83 c4 10             	add    $0x10,%esp
80104cae:	85 c0                	test   %eax,%eax
80104cb0:	78 33                	js     80104ce5 <sys_exec+0xd8>
    if(uarg == 0){
80104cb2:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104cb8:	85 c0                	test   %eax,%eax
80104cba:	74 ac                	je     80104c68 <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
80104cbc:	83 ec 08             	sub    $0x8,%esp
80104cbf:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104cc6:	52                   	push   %edx
80104cc7:	50                   	push   %eax
80104cc8:	e8 fe f3 ff ff       	call   801040cb <fetchstr>
80104ccd:	83 c4 10             	add    $0x10,%esp
80104cd0:	85 c0                	test   %eax,%eax
80104cd2:	79 b6                	jns    80104c8a <sys_exec+0x7d>
      return -1;
80104cd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cd9:	eb 05                	jmp    80104ce0 <sys_exec+0xd3>
      return -1;
80104cdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ce0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ce3:	c9                   	leave  
80104ce4:	c3                   	ret    
      return -1;
80104ce5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cea:	eb f4                	jmp    80104ce0 <sys_exec+0xd3>

80104cec <sys_pipe>:

int
sys_pipe(void)
{
80104cec:	55                   	push   %ebp
80104ced:	89 e5                	mov    %esp,%ebp
80104cef:	53                   	push   %ebx
80104cf0:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104cf3:	6a 08                	push   $0x8
80104cf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cf8:	50                   	push   %eax
80104cf9:	6a 00                	push   $0x0
80104cfb:	e8 32 f4 ff ff       	call   80104132 <argptr>
80104d00:	83 c4 10             	add    $0x10,%esp
80104d03:	85 c0                	test   %eax,%eax
80104d05:	78 79                	js     80104d80 <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104d07:	83 ec 08             	sub    $0x8,%esp
80104d0a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104d0d:	50                   	push   %eax
80104d0e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d11:	50                   	push   %eax
80104d12:	e8 ed e0 ff ff       	call   80102e04 <pipealloc>
80104d17:	83 c4 10             	add    $0x10,%esp
80104d1a:	85 c0                	test   %eax,%eax
80104d1c:	78 69                	js     80104d87 <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d21:	e8 5e f5 ff ff       	call   80104284 <fdalloc>
80104d26:	89 c3                	mov    %eax,%ebx
80104d28:	85 c0                	test   %eax,%eax
80104d2a:	78 21                	js     80104d4d <sys_pipe+0x61>
80104d2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d2f:	e8 50 f5 ff ff       	call   80104284 <fdalloc>
80104d34:	85 c0                	test   %eax,%eax
80104d36:	78 15                	js     80104d4d <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104d38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d3b:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104d3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d40:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d4b:	c9                   	leave  
80104d4c:	c3                   	ret    
    if(fd0 >= 0)
80104d4d:	85 db                	test   %ebx,%ebx
80104d4f:	79 20                	jns    80104d71 <sys_pipe+0x85>
    fileclose(rf);
80104d51:	83 ec 0c             	sub    $0xc,%esp
80104d54:	ff 75 f0             	push   -0x10(%ebp)
80104d57:	e8 67 bf ff ff       	call   80100cc3 <fileclose>
    fileclose(wf);
80104d5c:	83 c4 04             	add    $0x4,%esp
80104d5f:	ff 75 ec             	push   -0x14(%ebp)
80104d62:	e8 5c bf ff ff       	call   80100cc3 <fileclose>
    return -1;
80104d67:	83 c4 10             	add    $0x10,%esp
80104d6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d6f:	eb d7                	jmp    80104d48 <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
80104d71:	e8 3c e5 ff ff       	call   801032b2 <myproc>
80104d76:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104d7d:	00 
80104d7e:	eb d1                	jmp    80104d51 <sys_pipe+0x65>
    return -1;
80104d80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d85:	eb c1                	jmp    80104d48 <sys_pipe+0x5c>
    return -1;
80104d87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d8c:	eb ba                	jmp    80104d48 <sys_pipe+0x5c>

80104d8e <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104d8e:	55                   	push   %ebp
80104d8f:	89 e5                	mov    %esp,%ebp
80104d91:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104d94:	e8 8f e6 ff ff       	call   80103428 <fork>
}
80104d99:	c9                   	leave  
80104d9a:	c3                   	ret    

80104d9b <sys_exit>:

int
sys_exit(void)
{
80104d9b:	55                   	push   %ebp
80104d9c:	89 e5                	mov    %esp,%ebp
80104d9e:	83 ec 08             	sub    $0x8,%esp
  exit();
80104da1:	e8 b6 e8 ff ff       	call   8010365c <exit>
  return 0;  // not reached
}
80104da6:	b8 00 00 00 00       	mov    $0x0,%eax
80104dab:	c9                   	leave  
80104dac:	c3                   	ret    

80104dad <sys_wait>:

int
sys_wait(void)
{
80104dad:	55                   	push   %ebp
80104dae:	89 e5                	mov    %esp,%ebp
80104db0:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104db3:	e8 2d ea ff ff       	call   801037e5 <wait>
}
80104db8:	c9                   	leave  
80104db9:	c3                   	ret    

80104dba <sys_kill>:

int
sys_kill(void)
{
80104dba:	55                   	push   %ebp
80104dbb:	89 e5                	mov    %esp,%ebp
80104dbd:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104dc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dc3:	50                   	push   %eax
80104dc4:	6a 00                	push   $0x0
80104dc6:	e8 3f f3 ff ff       	call   8010410a <argint>
80104dcb:	83 c4 10             	add    $0x10,%esp
80104dce:	85 c0                	test   %eax,%eax
80104dd0:	78 10                	js     80104de2 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104dd2:	83 ec 0c             	sub    $0xc,%esp
80104dd5:	ff 75 f4             	push   -0xc(%ebp)
80104dd8:	e8 05 eb ff ff       	call   801038e2 <kill>
80104ddd:	83 c4 10             	add    $0x10,%esp
}
80104de0:	c9                   	leave  
80104de1:	c3                   	ret    
    return -1;
80104de2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104de7:	eb f7                	jmp    80104de0 <sys_kill+0x26>

80104de9 <sys_getpid>:

int
sys_getpid(void)
{
80104de9:	55                   	push   %ebp
80104dea:	89 e5                	mov    %esp,%ebp
80104dec:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104def:	e8 be e4 ff ff       	call   801032b2 <myproc>
80104df4:	8b 40 10             	mov    0x10(%eax),%eax
}
80104df7:	c9                   	leave  
80104df8:	c3                   	ret    

80104df9 <sys_sbrk>:

int
sys_sbrk(void)
{
80104df9:	55                   	push   %ebp
80104dfa:	89 e5                	mov    %esp,%ebp
80104dfc:	53                   	push   %ebx
80104dfd:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104e00:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e03:	50                   	push   %eax
80104e04:	6a 00                	push   $0x0
80104e06:	e8 ff f2 ff ff       	call   8010410a <argint>
80104e0b:	83 c4 10             	add    $0x10,%esp
80104e0e:	85 c0                	test   %eax,%eax
80104e10:	78 20                	js     80104e32 <sys_sbrk+0x39>
    return -1;
  addr = myproc()->sz;
80104e12:	e8 9b e4 ff ff       	call   801032b2 <myproc>
80104e17:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104e19:	83 ec 0c             	sub    $0xc,%esp
80104e1c:	ff 75 f4             	push   -0xc(%ebp)
80104e1f:	e8 99 e5 ff ff       	call   801033bd <growproc>
80104e24:	83 c4 10             	add    $0x10,%esp
80104e27:	85 c0                	test   %eax,%eax
80104e29:	78 0e                	js     80104e39 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80104e2b:	89 d8                	mov    %ebx,%eax
80104e2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e30:	c9                   	leave  
80104e31:	c3                   	ret    
    return -1;
80104e32:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e37:	eb f2                	jmp    80104e2b <sys_sbrk+0x32>
    return -1;
80104e39:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e3e:	eb eb                	jmp    80104e2b <sys_sbrk+0x32>

80104e40 <sys_sleep>:

int
sys_sleep(void)
{
80104e40:	55                   	push   %ebp
80104e41:	89 e5                	mov    %esp,%ebp
80104e43:	53                   	push   %ebx
80104e44:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104e47:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e4a:	50                   	push   %eax
80104e4b:	6a 00                	push   $0x0
80104e4d:	e8 b8 f2 ff ff       	call   8010410a <argint>
80104e52:	83 c4 10             	add    $0x10,%esp
80104e55:	85 c0                	test   %eax,%eax
80104e57:	78 75                	js     80104ece <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104e59:	83 ec 0c             	sub    $0xc,%esp
80104e5c:	68 80 3c 11 80       	push   $0x80113c80
80104e61:	e8 a8 ef ff ff       	call   80103e0e <acquire>
  ticks0 = ticks;
80104e66:	8b 1d 60 3c 11 80    	mov    0x80113c60,%ebx
  while(ticks - ticks0 < n){
80104e6c:	83 c4 10             	add    $0x10,%esp
80104e6f:	a1 60 3c 11 80       	mov    0x80113c60,%eax
80104e74:	29 d8                	sub    %ebx,%eax
80104e76:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104e79:	73 39                	jae    80104eb4 <sys_sleep+0x74>
    if(myproc()->killed){
80104e7b:	e8 32 e4 ff ff       	call   801032b2 <myproc>
80104e80:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104e84:	75 17                	jne    80104e9d <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104e86:	83 ec 08             	sub    $0x8,%esp
80104e89:	68 80 3c 11 80       	push   $0x80113c80
80104e8e:	68 60 3c 11 80       	push   $0x80113c60
80104e93:	e8 bc e8 ff ff       	call   80103754 <sleep>
80104e98:	83 c4 10             	add    $0x10,%esp
80104e9b:	eb d2                	jmp    80104e6f <sys_sleep+0x2f>
      release(&tickslock);
80104e9d:	83 ec 0c             	sub    $0xc,%esp
80104ea0:	68 80 3c 11 80       	push   $0x80113c80
80104ea5:	e8 c9 ef ff ff       	call   80103e73 <release>
      return -1;
80104eaa:	83 c4 10             	add    $0x10,%esp
80104ead:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eb2:	eb 15                	jmp    80104ec9 <sys_sleep+0x89>
  }
  release(&tickslock);
80104eb4:	83 ec 0c             	sub    $0xc,%esp
80104eb7:	68 80 3c 11 80       	push   $0x80113c80
80104ebc:	e8 b2 ef ff ff       	call   80103e73 <release>
  return 0;
80104ec1:	83 c4 10             	add    $0x10,%esp
80104ec4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ec9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ecc:	c9                   	leave  
80104ecd:	c3                   	ret    
    return -1;
80104ece:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ed3:	eb f4                	jmp    80104ec9 <sys_sleep+0x89>

80104ed5 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104ed5:	55                   	push   %ebp
80104ed6:	89 e5                	mov    %esp,%ebp
80104ed8:	53                   	push   %ebx
80104ed9:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104edc:	68 80 3c 11 80       	push   $0x80113c80
80104ee1:	e8 28 ef ff ff       	call   80103e0e <acquire>
  xticks = ticks;
80104ee6:	8b 1d 60 3c 11 80    	mov    0x80113c60,%ebx
  release(&tickslock);
80104eec:	c7 04 24 80 3c 11 80 	movl   $0x80113c80,(%esp)
80104ef3:	e8 7b ef ff ff       	call   80103e73 <release>
  return xticks;
}
80104ef8:	89 d8                	mov    %ebx,%eax
80104efa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104efd:	c9                   	leave  
80104efe:	c3                   	ret    

80104eff <sys_yield>:

int
sys_yield(void)
{
80104eff:	55                   	push   %ebp
80104f00:	89 e5                	mov    %esp,%ebp
80104f02:	83 ec 08             	sub    $0x8,%esp
  yield();
80104f05:	e8 18 e8 ff ff       	call   80103722 <yield>
  return 0;
}
80104f0a:	b8 00 00 00 00       	mov    $0x0,%eax
80104f0f:	c9                   	leave  
80104f10:	c3                   	ret    

80104f11 <sys_shutdown>:

int sys_shutdown(void)
{
80104f11:	55                   	push   %ebp
80104f12:	89 e5                	mov    %esp,%ebp
80104f14:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80104f17:	e8 77 d3 ff ff       	call   80102293 <shutdown>
  return 0;
}
80104f1c:	b8 00 00 00 00       	mov    $0x0,%eax
80104f21:	c9                   	leave  
80104f22:	c3                   	ret    

80104f23 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104f23:	1e                   	push   %ds
  pushl %es
80104f24:	06                   	push   %es
  pushl %fs
80104f25:	0f a0                	push   %fs
  pushl %gs
80104f27:	0f a8                	push   %gs
  pushal
80104f29:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104f2a:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104f2e:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104f30:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104f32:	54                   	push   %esp
  call trap
80104f33:	e8 37 01 00 00       	call   8010506f <trap>
  addl $4, %esp
80104f38:	83 c4 04             	add    $0x4,%esp

80104f3b <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104f3b:	61                   	popa   
  popl %gs
80104f3c:	0f a9                	pop    %gs
  popl %fs
80104f3e:	0f a1                	pop    %fs
  popl %es
80104f40:	07                   	pop    %es
  popl %ds
80104f41:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104f42:	83 c4 08             	add    $0x8,%esp
  iret
80104f45:	cf                   	iret   

80104f46 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104f46:	55                   	push   %ebp
80104f47:	89 e5                	mov    %esp,%ebp
80104f49:	53                   	push   %ebx
80104f4a:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80104f4d:	b8 00 00 00 00       	mov    $0x0,%eax
80104f52:	eb 76                	jmp    80104fca <tvinit+0x84>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104f54:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104f5b:	66 89 0c c5 c0 3c 11 	mov    %cx,-0x7feec340(,%eax,8)
80104f62:	80 
80104f63:	66 c7 04 c5 c2 3c 11 	movw   $0x8,-0x7feec33e(,%eax,8)
80104f6a:	80 08 00 
80104f6d:	0f b6 14 c5 c4 3c 11 	movzbl -0x7feec33c(,%eax,8),%edx
80104f74:	80 
80104f75:	83 e2 e0             	and    $0xffffffe0,%edx
80104f78:	88 14 c5 c4 3c 11 80 	mov    %dl,-0x7feec33c(,%eax,8)
80104f7f:	c6 04 c5 c4 3c 11 80 	movb   $0x0,-0x7feec33c(,%eax,8)
80104f86:	00 
80104f87:	0f b6 14 c5 c5 3c 11 	movzbl -0x7feec33b(,%eax,8),%edx
80104f8e:	80 
80104f8f:	83 e2 f0             	and    $0xfffffff0,%edx
80104f92:	83 ca 0e             	or     $0xe,%edx
80104f95:	88 14 c5 c5 3c 11 80 	mov    %dl,-0x7feec33b(,%eax,8)
80104f9c:	89 d3                	mov    %edx,%ebx
80104f9e:	83 e3 ef             	and    $0xffffffef,%ebx
80104fa1:	88 1c c5 c5 3c 11 80 	mov    %bl,-0x7feec33b(,%eax,8)
80104fa8:	83 e2 8f             	and    $0xffffff8f,%edx
80104fab:	88 14 c5 c5 3c 11 80 	mov    %dl,-0x7feec33b(,%eax,8)
80104fb2:	83 ca 80             	or     $0xffffff80,%edx
80104fb5:	88 14 c5 c5 3c 11 80 	mov    %dl,-0x7feec33b(,%eax,8)
80104fbc:	c1 e9 10             	shr    $0x10,%ecx
80104fbf:	66 89 0c c5 c6 3c 11 	mov    %cx,-0x7feec33a(,%eax,8)
80104fc6:	80 
  for(i = 0; i < 256; i++)
80104fc7:	83 c0 01             	add    $0x1,%eax
80104fca:	3d ff 00 00 00       	cmp    $0xff,%eax
80104fcf:	7e 83                	jle    80104f54 <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104fd1:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104fd7:	66 89 15 c0 3e 11 80 	mov    %dx,0x80113ec0
80104fde:	66 c7 05 c2 3e 11 80 	movw   $0x8,0x80113ec2
80104fe5:	08 00 
80104fe7:	0f b6 05 c4 3e 11 80 	movzbl 0x80113ec4,%eax
80104fee:	83 e0 e0             	and    $0xffffffe0,%eax
80104ff1:	a2 c4 3e 11 80       	mov    %al,0x80113ec4
80104ff6:	c6 05 c4 3e 11 80 00 	movb   $0x0,0x80113ec4
80104ffd:	0f b6 05 c5 3e 11 80 	movzbl 0x80113ec5,%eax
80105004:	83 c8 0f             	or     $0xf,%eax
80105007:	a2 c5 3e 11 80       	mov    %al,0x80113ec5
8010500c:	83 e0 ef             	and    $0xffffffef,%eax
8010500f:	a2 c5 3e 11 80       	mov    %al,0x80113ec5
80105014:	89 c1                	mov    %eax,%ecx
80105016:	83 c9 60             	or     $0x60,%ecx
80105019:	88 0d c5 3e 11 80    	mov    %cl,0x80113ec5
8010501f:	83 c8 e0             	or     $0xffffffe0,%eax
80105022:	a2 c5 3e 11 80       	mov    %al,0x80113ec5
80105027:	c1 ea 10             	shr    $0x10,%edx
8010502a:	66 89 15 c6 3e 11 80 	mov    %dx,0x80113ec6

  initlock(&tickslock, "time");
80105031:	83 ec 08             	sub    $0x8,%esp
80105034:	68 cd 71 10 80       	push   $0x801071cd
80105039:	68 80 3c 11 80       	push   $0x80113c80
8010503e:	e8 8f ec ff ff       	call   80103cd2 <initlock>
}
80105043:	83 c4 10             	add    $0x10,%esp
80105046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105049:	c9                   	leave  
8010504a:	c3                   	ret    

8010504b <idtinit>:

void
idtinit(void)
{
8010504b:	55                   	push   %ebp
8010504c:	89 e5                	mov    %esp,%ebp
8010504e:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105051:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105057:	b8 c0 3c 11 80       	mov    $0x80113cc0,%eax
8010505c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105060:	c1 e8 10             	shr    $0x10,%eax
80105063:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105067:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010506a:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
8010506d:	c9                   	leave  
8010506e:	c3                   	ret    

8010506f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010506f:	55                   	push   %ebp
80105070:	89 e5                	mov    %esp,%ebp
80105072:	57                   	push   %edi
80105073:	56                   	push   %esi
80105074:	53                   	push   %ebx
80105075:	83 ec 1c             	sub    $0x1c,%esp
80105078:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010507b:	8b 43 30             	mov    0x30(%ebx),%eax
8010507e:	83 f8 40             	cmp    $0x40,%eax
80105081:	74 13                	je     80105096 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105083:	83 e8 20             	sub    $0x20,%eax
80105086:	83 f8 1f             	cmp    $0x1f,%eax
80105089:	0f 87 3a 01 00 00    	ja     801051c9 <trap+0x15a>
8010508f:	ff 24 85 74 72 10 80 	jmp    *-0x7fef8d8c(,%eax,4)
    if(myproc()->killed)
80105096:	e8 17 e2 ff ff       	call   801032b2 <myproc>
8010509b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010509f:	75 1f                	jne    801050c0 <trap+0x51>
    myproc()->tf = tf;
801050a1:	e8 0c e2 ff ff       	call   801032b2 <myproc>
801050a6:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
801050a9:	e8 1f f1 ff ff       	call   801041cd <syscall>
    if(myproc()->killed)
801050ae:	e8 ff e1 ff ff       	call   801032b2 <myproc>
801050b3:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050b7:	74 7e                	je     80105137 <trap+0xc8>
      exit();
801050b9:	e8 9e e5 ff ff       	call   8010365c <exit>
    return;
801050be:	eb 77                	jmp    80105137 <trap+0xc8>
      exit();
801050c0:	e8 97 e5 ff ff       	call   8010365c <exit>
801050c5:	eb da                	jmp    801050a1 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801050c7:	e8 cb e1 ff ff       	call   80103297 <cpuid>
801050cc:	85 c0                	test   %eax,%eax
801050ce:	74 6f                	je     8010513f <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
801050d0:	e8 6b d3 ff ff       	call   80102440 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801050d5:	e8 d8 e1 ff ff       	call   801032b2 <myproc>
801050da:	85 c0                	test   %eax,%eax
801050dc:	74 1c                	je     801050fa <trap+0x8b>
801050de:	e8 cf e1 ff ff       	call   801032b2 <myproc>
801050e3:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050e7:	74 11                	je     801050fa <trap+0x8b>
801050e9:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801050ed:	83 e0 03             	and    $0x3,%eax
801050f0:	66 83 f8 03          	cmp    $0x3,%ax
801050f4:	0f 84 62 01 00 00    	je     8010525c <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801050fa:	e8 b3 e1 ff ff       	call   801032b2 <myproc>
801050ff:	85 c0                	test   %eax,%eax
80105101:	74 0f                	je     80105112 <trap+0xa3>
80105103:	e8 aa e1 ff ff       	call   801032b2 <myproc>
80105108:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010510c:	0f 84 54 01 00 00    	je     80105266 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105112:	e8 9b e1 ff ff       	call   801032b2 <myproc>
80105117:	85 c0                	test   %eax,%eax
80105119:	74 1c                	je     80105137 <trap+0xc8>
8010511b:	e8 92 e1 ff ff       	call   801032b2 <myproc>
80105120:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105124:	74 11                	je     80105137 <trap+0xc8>
80105126:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010512a:	83 e0 03             	and    $0x3,%eax
8010512d:	66 83 f8 03          	cmp    $0x3,%ax
80105131:	0f 84 43 01 00 00    	je     8010527a <trap+0x20b>
    exit();
}
80105137:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010513a:	5b                   	pop    %ebx
8010513b:	5e                   	pop    %esi
8010513c:	5f                   	pop    %edi
8010513d:	5d                   	pop    %ebp
8010513e:	c3                   	ret    
      acquire(&tickslock);
8010513f:	83 ec 0c             	sub    $0xc,%esp
80105142:	68 80 3c 11 80       	push   $0x80113c80
80105147:	e8 c2 ec ff ff       	call   80103e0e <acquire>
      ticks++;
8010514c:	83 05 60 3c 11 80 01 	addl   $0x1,0x80113c60
      wakeup(&ticks);
80105153:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
8010515a:	e8 5a e7 ff ff       	call   801038b9 <wakeup>
      release(&tickslock);
8010515f:	c7 04 24 80 3c 11 80 	movl   $0x80113c80,(%esp)
80105166:	e8 08 ed ff ff       	call   80103e73 <release>
8010516b:	83 c4 10             	add    $0x10,%esp
8010516e:	e9 5d ff ff ff       	jmp    801050d0 <trap+0x61>
    ideintr();
80105173:	e8 e4 cb ff ff       	call   80101d5c <ideintr>
    lapiceoi();
80105178:	e8 c3 d2 ff ff       	call   80102440 <lapiceoi>
    break;
8010517d:	e9 53 ff ff ff       	jmp    801050d5 <trap+0x66>
    kbdintr();
80105182:	e8 f7 d0 ff ff       	call   8010227e <kbdintr>
    lapiceoi();
80105187:	e8 b4 d2 ff ff       	call   80102440 <lapiceoi>
    break;
8010518c:	e9 44 ff ff ff       	jmp    801050d5 <trap+0x66>
    uartintr();
80105191:	e8 fe 01 00 00       	call   80105394 <uartintr>
    lapiceoi();
80105196:	e8 a5 d2 ff ff       	call   80102440 <lapiceoi>
    break;
8010519b:	e9 35 ff ff ff       	jmp    801050d5 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051a0:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801051a3:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051a7:	e8 eb e0 ff ff       	call   80103297 <cpuid>
801051ac:	57                   	push   %edi
801051ad:	0f b7 f6             	movzwl %si,%esi
801051b0:	56                   	push   %esi
801051b1:	50                   	push   %eax
801051b2:	68 d8 71 10 80       	push   $0x801071d8
801051b7:	e8 4b b4 ff ff       	call   80100607 <cprintf>
    lapiceoi();
801051bc:	e8 7f d2 ff ff       	call   80102440 <lapiceoi>
    break;
801051c1:	83 c4 10             	add    $0x10,%esp
801051c4:	e9 0c ff ff ff       	jmp    801050d5 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
801051c9:	e8 e4 e0 ff ff       	call   801032b2 <myproc>
801051ce:	85 c0                	test   %eax,%eax
801051d0:	74 5f                	je     80105231 <trap+0x1c2>
801051d2:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801051d6:	74 59                	je     80105231 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801051d8:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801051db:	8b 43 38             	mov    0x38(%ebx),%eax
801051de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801051e1:	e8 b1 e0 ff ff       	call   80103297 <cpuid>
801051e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801051e9:	8b 53 34             	mov    0x34(%ebx),%edx
801051ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
801051ef:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801051f2:	e8 bb e0 ff ff       	call   801032b2 <myproc>
801051f7:	8d 48 6c             	lea    0x6c(%eax),%ecx
801051fa:	89 4d d8             	mov    %ecx,-0x28(%ebp)
801051fd:	e8 b0 e0 ff ff       	call   801032b2 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105202:	57                   	push   %edi
80105203:	ff 75 e4             	push   -0x1c(%ebp)
80105206:	ff 75 e0             	push   -0x20(%ebp)
80105209:	ff 75 dc             	push   -0x24(%ebp)
8010520c:	56                   	push   %esi
8010520d:	ff 75 d8             	push   -0x28(%ebp)
80105210:	ff 70 10             	push   0x10(%eax)
80105213:	68 30 72 10 80       	push   $0x80107230
80105218:	e8 ea b3 ff ff       	call   80100607 <cprintf>
    myproc()->killed = 1;
8010521d:	83 c4 20             	add    $0x20,%esp
80105220:	e8 8d e0 ff ff       	call   801032b2 <myproc>
80105225:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010522c:	e9 a4 fe ff ff       	jmp    801050d5 <trap+0x66>
80105231:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105234:	8b 73 38             	mov    0x38(%ebx),%esi
80105237:	e8 5b e0 ff ff       	call   80103297 <cpuid>
8010523c:	83 ec 0c             	sub    $0xc,%esp
8010523f:	57                   	push   %edi
80105240:	56                   	push   %esi
80105241:	50                   	push   %eax
80105242:	ff 73 30             	push   0x30(%ebx)
80105245:	68 fc 71 10 80       	push   $0x801071fc
8010524a:	e8 b8 b3 ff ff       	call   80100607 <cprintf>
      panic("trap");
8010524f:	83 c4 14             	add    $0x14,%esp
80105252:	68 d2 71 10 80       	push   $0x801071d2
80105257:	e8 ec b0 ff ff       	call   80100348 <panic>
    exit();
8010525c:	e8 fb e3 ff ff       	call   8010365c <exit>
80105261:	e9 94 fe ff ff       	jmp    801050fa <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105266:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010526a:	0f 85 a2 fe ff ff    	jne    80105112 <trap+0xa3>
    yield();
80105270:	e8 ad e4 ff ff       	call   80103722 <yield>
80105275:	e9 98 fe ff ff       	jmp    80105112 <trap+0xa3>
    exit();
8010527a:	e8 dd e3 ff ff       	call   8010365c <exit>
8010527f:	e9 b3 fe ff ff       	jmp    80105137 <trap+0xc8>

80105284 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105284:	83 3d c0 44 11 80 00 	cmpl   $0x0,0x801144c0
8010528b:	74 14                	je     801052a1 <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010528d:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105292:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105293:	a8 01                	test   $0x1,%al
80105295:	74 10                	je     801052a7 <uartgetc+0x23>
80105297:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010529c:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010529d:	0f b6 c0             	movzbl %al,%eax
801052a0:	c3                   	ret    
    return -1;
801052a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a6:	c3                   	ret    
    return -1;
801052a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052ac:	c3                   	ret    

801052ad <uartputc>:
  if(!uart)
801052ad:	83 3d c0 44 11 80 00 	cmpl   $0x0,0x801144c0
801052b4:	74 3b                	je     801052f1 <uartputc+0x44>
{
801052b6:	55                   	push   %ebp
801052b7:	89 e5                	mov    %esp,%ebp
801052b9:	53                   	push   %ebx
801052ba:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801052bd:	bb 00 00 00 00       	mov    $0x0,%ebx
801052c2:	eb 10                	jmp    801052d4 <uartputc+0x27>
    microdelay(10);
801052c4:	83 ec 0c             	sub    $0xc,%esp
801052c7:	6a 0a                	push   $0xa
801052c9:	e8 93 d1 ff ff       	call   80102461 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801052ce:	83 c3 01             	add    $0x1,%ebx
801052d1:	83 c4 10             	add    $0x10,%esp
801052d4:	83 fb 7f             	cmp    $0x7f,%ebx
801052d7:	7f 0a                	jg     801052e3 <uartputc+0x36>
801052d9:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052de:	ec                   	in     (%dx),%al
801052df:	a8 20                	test   $0x20,%al
801052e1:	74 e1                	je     801052c4 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801052e3:	8b 45 08             	mov    0x8(%ebp),%eax
801052e6:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052eb:	ee                   	out    %al,(%dx)
}
801052ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052ef:	c9                   	leave  
801052f0:	c3                   	ret    
801052f1:	c3                   	ret    

801052f2 <uartinit>:
{
801052f2:	55                   	push   %ebp
801052f3:	89 e5                	mov    %esp,%ebp
801052f5:	56                   	push   %esi
801052f6:	53                   	push   %ebx
801052f7:	b9 00 00 00 00       	mov    $0x0,%ecx
801052fc:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105301:	89 c8                	mov    %ecx,%eax
80105303:	ee                   	out    %al,(%dx)
80105304:	be fb 03 00 00       	mov    $0x3fb,%esi
80105309:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010530e:	89 f2                	mov    %esi,%edx
80105310:	ee                   	out    %al,(%dx)
80105311:	b8 0c 00 00 00       	mov    $0xc,%eax
80105316:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010531b:	ee                   	out    %al,(%dx)
8010531c:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105321:	89 c8                	mov    %ecx,%eax
80105323:	89 da                	mov    %ebx,%edx
80105325:	ee                   	out    %al,(%dx)
80105326:	b8 03 00 00 00       	mov    $0x3,%eax
8010532b:	89 f2                	mov    %esi,%edx
8010532d:	ee                   	out    %al,(%dx)
8010532e:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105333:	89 c8                	mov    %ecx,%eax
80105335:	ee                   	out    %al,(%dx)
80105336:	b8 01 00 00 00       	mov    $0x1,%eax
8010533b:	89 da                	mov    %ebx,%edx
8010533d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010533e:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105343:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105344:	3c ff                	cmp    $0xff,%al
80105346:	74 45                	je     8010538d <uartinit+0x9b>
  uart = 1;
80105348:	c7 05 c0 44 11 80 01 	movl   $0x1,0x801144c0
8010534f:	00 00 00 
80105352:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105357:	ec                   	in     (%dx),%al
80105358:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010535d:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010535e:	83 ec 08             	sub    $0x8,%esp
80105361:	6a 00                	push   $0x0
80105363:	6a 04                	push   $0x4
80105365:	e8 f7 cb ff ff       	call   80101f61 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
8010536a:	83 c4 10             	add    $0x10,%esp
8010536d:	bb f4 72 10 80       	mov    $0x801072f4,%ebx
80105372:	eb 12                	jmp    80105386 <uartinit+0x94>
    uartputc(*p);
80105374:	83 ec 0c             	sub    $0xc,%esp
80105377:	0f be c0             	movsbl %al,%eax
8010537a:	50                   	push   %eax
8010537b:	e8 2d ff ff ff       	call   801052ad <uartputc>
  for(p="xv6...\n"; *p; p++)
80105380:	83 c3 01             	add    $0x1,%ebx
80105383:	83 c4 10             	add    $0x10,%esp
80105386:	0f b6 03             	movzbl (%ebx),%eax
80105389:	84 c0                	test   %al,%al
8010538b:	75 e7                	jne    80105374 <uartinit+0x82>
}
8010538d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105390:	5b                   	pop    %ebx
80105391:	5e                   	pop    %esi
80105392:	5d                   	pop    %ebp
80105393:	c3                   	ret    

80105394 <uartintr>:

void
uartintr(void)
{
80105394:	55                   	push   %ebp
80105395:	89 e5                	mov    %esp,%ebp
80105397:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
8010539a:	68 84 52 10 80       	push   $0x80105284
8010539f:	e8 8f b3 ff ff       	call   80100733 <consoleintr>
}
801053a4:	83 c4 10             	add    $0x10,%esp
801053a7:	c9                   	leave  
801053a8:	c3                   	ret    

801053a9 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801053a9:	6a 00                	push   $0x0
  pushl $0
801053ab:	6a 00                	push   $0x0
  jmp alltraps
801053ad:	e9 71 fb ff ff       	jmp    80104f23 <alltraps>

801053b2 <vector1>:
.globl vector1
vector1:
  pushl $0
801053b2:	6a 00                	push   $0x0
  pushl $1
801053b4:	6a 01                	push   $0x1
  jmp alltraps
801053b6:	e9 68 fb ff ff       	jmp    80104f23 <alltraps>

801053bb <vector2>:
.globl vector2
vector2:
  pushl $0
801053bb:	6a 00                	push   $0x0
  pushl $2
801053bd:	6a 02                	push   $0x2
  jmp alltraps
801053bf:	e9 5f fb ff ff       	jmp    80104f23 <alltraps>

801053c4 <vector3>:
.globl vector3
vector3:
  pushl $0
801053c4:	6a 00                	push   $0x0
  pushl $3
801053c6:	6a 03                	push   $0x3
  jmp alltraps
801053c8:	e9 56 fb ff ff       	jmp    80104f23 <alltraps>

801053cd <vector4>:
.globl vector4
vector4:
  pushl $0
801053cd:	6a 00                	push   $0x0
  pushl $4
801053cf:	6a 04                	push   $0x4
  jmp alltraps
801053d1:	e9 4d fb ff ff       	jmp    80104f23 <alltraps>

801053d6 <vector5>:
.globl vector5
vector5:
  pushl $0
801053d6:	6a 00                	push   $0x0
  pushl $5
801053d8:	6a 05                	push   $0x5
  jmp alltraps
801053da:	e9 44 fb ff ff       	jmp    80104f23 <alltraps>

801053df <vector6>:
.globl vector6
vector6:
  pushl $0
801053df:	6a 00                	push   $0x0
  pushl $6
801053e1:	6a 06                	push   $0x6
  jmp alltraps
801053e3:	e9 3b fb ff ff       	jmp    80104f23 <alltraps>

801053e8 <vector7>:
.globl vector7
vector7:
  pushl $0
801053e8:	6a 00                	push   $0x0
  pushl $7
801053ea:	6a 07                	push   $0x7
  jmp alltraps
801053ec:	e9 32 fb ff ff       	jmp    80104f23 <alltraps>

801053f1 <vector8>:
.globl vector8
vector8:
  pushl $8
801053f1:	6a 08                	push   $0x8
  jmp alltraps
801053f3:	e9 2b fb ff ff       	jmp    80104f23 <alltraps>

801053f8 <vector9>:
.globl vector9
vector9:
  pushl $0
801053f8:	6a 00                	push   $0x0
  pushl $9
801053fa:	6a 09                	push   $0x9
  jmp alltraps
801053fc:	e9 22 fb ff ff       	jmp    80104f23 <alltraps>

80105401 <vector10>:
.globl vector10
vector10:
  pushl $10
80105401:	6a 0a                	push   $0xa
  jmp alltraps
80105403:	e9 1b fb ff ff       	jmp    80104f23 <alltraps>

80105408 <vector11>:
.globl vector11
vector11:
  pushl $11
80105408:	6a 0b                	push   $0xb
  jmp alltraps
8010540a:	e9 14 fb ff ff       	jmp    80104f23 <alltraps>

8010540f <vector12>:
.globl vector12
vector12:
  pushl $12
8010540f:	6a 0c                	push   $0xc
  jmp alltraps
80105411:	e9 0d fb ff ff       	jmp    80104f23 <alltraps>

80105416 <vector13>:
.globl vector13
vector13:
  pushl $13
80105416:	6a 0d                	push   $0xd
  jmp alltraps
80105418:	e9 06 fb ff ff       	jmp    80104f23 <alltraps>

8010541d <vector14>:
.globl vector14
vector14:
  pushl $14
8010541d:	6a 0e                	push   $0xe
  jmp alltraps
8010541f:	e9 ff fa ff ff       	jmp    80104f23 <alltraps>

80105424 <vector15>:
.globl vector15
vector15:
  pushl $0
80105424:	6a 00                	push   $0x0
  pushl $15
80105426:	6a 0f                	push   $0xf
  jmp alltraps
80105428:	e9 f6 fa ff ff       	jmp    80104f23 <alltraps>

8010542d <vector16>:
.globl vector16
vector16:
  pushl $0
8010542d:	6a 00                	push   $0x0
  pushl $16
8010542f:	6a 10                	push   $0x10
  jmp alltraps
80105431:	e9 ed fa ff ff       	jmp    80104f23 <alltraps>

80105436 <vector17>:
.globl vector17
vector17:
  pushl $17
80105436:	6a 11                	push   $0x11
  jmp alltraps
80105438:	e9 e6 fa ff ff       	jmp    80104f23 <alltraps>

8010543d <vector18>:
.globl vector18
vector18:
  pushl $0
8010543d:	6a 00                	push   $0x0
  pushl $18
8010543f:	6a 12                	push   $0x12
  jmp alltraps
80105441:	e9 dd fa ff ff       	jmp    80104f23 <alltraps>

80105446 <vector19>:
.globl vector19
vector19:
  pushl $0
80105446:	6a 00                	push   $0x0
  pushl $19
80105448:	6a 13                	push   $0x13
  jmp alltraps
8010544a:	e9 d4 fa ff ff       	jmp    80104f23 <alltraps>

8010544f <vector20>:
.globl vector20
vector20:
  pushl $0
8010544f:	6a 00                	push   $0x0
  pushl $20
80105451:	6a 14                	push   $0x14
  jmp alltraps
80105453:	e9 cb fa ff ff       	jmp    80104f23 <alltraps>

80105458 <vector21>:
.globl vector21
vector21:
  pushl $0
80105458:	6a 00                	push   $0x0
  pushl $21
8010545a:	6a 15                	push   $0x15
  jmp alltraps
8010545c:	e9 c2 fa ff ff       	jmp    80104f23 <alltraps>

80105461 <vector22>:
.globl vector22
vector22:
  pushl $0
80105461:	6a 00                	push   $0x0
  pushl $22
80105463:	6a 16                	push   $0x16
  jmp alltraps
80105465:	e9 b9 fa ff ff       	jmp    80104f23 <alltraps>

8010546a <vector23>:
.globl vector23
vector23:
  pushl $0
8010546a:	6a 00                	push   $0x0
  pushl $23
8010546c:	6a 17                	push   $0x17
  jmp alltraps
8010546e:	e9 b0 fa ff ff       	jmp    80104f23 <alltraps>

80105473 <vector24>:
.globl vector24
vector24:
  pushl $0
80105473:	6a 00                	push   $0x0
  pushl $24
80105475:	6a 18                	push   $0x18
  jmp alltraps
80105477:	e9 a7 fa ff ff       	jmp    80104f23 <alltraps>

8010547c <vector25>:
.globl vector25
vector25:
  pushl $0
8010547c:	6a 00                	push   $0x0
  pushl $25
8010547e:	6a 19                	push   $0x19
  jmp alltraps
80105480:	e9 9e fa ff ff       	jmp    80104f23 <alltraps>

80105485 <vector26>:
.globl vector26
vector26:
  pushl $0
80105485:	6a 00                	push   $0x0
  pushl $26
80105487:	6a 1a                	push   $0x1a
  jmp alltraps
80105489:	e9 95 fa ff ff       	jmp    80104f23 <alltraps>

8010548e <vector27>:
.globl vector27
vector27:
  pushl $0
8010548e:	6a 00                	push   $0x0
  pushl $27
80105490:	6a 1b                	push   $0x1b
  jmp alltraps
80105492:	e9 8c fa ff ff       	jmp    80104f23 <alltraps>

80105497 <vector28>:
.globl vector28
vector28:
  pushl $0
80105497:	6a 00                	push   $0x0
  pushl $28
80105499:	6a 1c                	push   $0x1c
  jmp alltraps
8010549b:	e9 83 fa ff ff       	jmp    80104f23 <alltraps>

801054a0 <vector29>:
.globl vector29
vector29:
  pushl $0
801054a0:	6a 00                	push   $0x0
  pushl $29
801054a2:	6a 1d                	push   $0x1d
  jmp alltraps
801054a4:	e9 7a fa ff ff       	jmp    80104f23 <alltraps>

801054a9 <vector30>:
.globl vector30
vector30:
  pushl $0
801054a9:	6a 00                	push   $0x0
  pushl $30
801054ab:	6a 1e                	push   $0x1e
  jmp alltraps
801054ad:	e9 71 fa ff ff       	jmp    80104f23 <alltraps>

801054b2 <vector31>:
.globl vector31
vector31:
  pushl $0
801054b2:	6a 00                	push   $0x0
  pushl $31
801054b4:	6a 1f                	push   $0x1f
  jmp alltraps
801054b6:	e9 68 fa ff ff       	jmp    80104f23 <alltraps>

801054bb <vector32>:
.globl vector32
vector32:
  pushl $0
801054bb:	6a 00                	push   $0x0
  pushl $32
801054bd:	6a 20                	push   $0x20
  jmp alltraps
801054bf:	e9 5f fa ff ff       	jmp    80104f23 <alltraps>

801054c4 <vector33>:
.globl vector33
vector33:
  pushl $0
801054c4:	6a 00                	push   $0x0
  pushl $33
801054c6:	6a 21                	push   $0x21
  jmp alltraps
801054c8:	e9 56 fa ff ff       	jmp    80104f23 <alltraps>

801054cd <vector34>:
.globl vector34
vector34:
  pushl $0
801054cd:	6a 00                	push   $0x0
  pushl $34
801054cf:	6a 22                	push   $0x22
  jmp alltraps
801054d1:	e9 4d fa ff ff       	jmp    80104f23 <alltraps>

801054d6 <vector35>:
.globl vector35
vector35:
  pushl $0
801054d6:	6a 00                	push   $0x0
  pushl $35
801054d8:	6a 23                	push   $0x23
  jmp alltraps
801054da:	e9 44 fa ff ff       	jmp    80104f23 <alltraps>

801054df <vector36>:
.globl vector36
vector36:
  pushl $0
801054df:	6a 00                	push   $0x0
  pushl $36
801054e1:	6a 24                	push   $0x24
  jmp alltraps
801054e3:	e9 3b fa ff ff       	jmp    80104f23 <alltraps>

801054e8 <vector37>:
.globl vector37
vector37:
  pushl $0
801054e8:	6a 00                	push   $0x0
  pushl $37
801054ea:	6a 25                	push   $0x25
  jmp alltraps
801054ec:	e9 32 fa ff ff       	jmp    80104f23 <alltraps>

801054f1 <vector38>:
.globl vector38
vector38:
  pushl $0
801054f1:	6a 00                	push   $0x0
  pushl $38
801054f3:	6a 26                	push   $0x26
  jmp alltraps
801054f5:	e9 29 fa ff ff       	jmp    80104f23 <alltraps>

801054fa <vector39>:
.globl vector39
vector39:
  pushl $0
801054fa:	6a 00                	push   $0x0
  pushl $39
801054fc:	6a 27                	push   $0x27
  jmp alltraps
801054fe:	e9 20 fa ff ff       	jmp    80104f23 <alltraps>

80105503 <vector40>:
.globl vector40
vector40:
  pushl $0
80105503:	6a 00                	push   $0x0
  pushl $40
80105505:	6a 28                	push   $0x28
  jmp alltraps
80105507:	e9 17 fa ff ff       	jmp    80104f23 <alltraps>

8010550c <vector41>:
.globl vector41
vector41:
  pushl $0
8010550c:	6a 00                	push   $0x0
  pushl $41
8010550e:	6a 29                	push   $0x29
  jmp alltraps
80105510:	e9 0e fa ff ff       	jmp    80104f23 <alltraps>

80105515 <vector42>:
.globl vector42
vector42:
  pushl $0
80105515:	6a 00                	push   $0x0
  pushl $42
80105517:	6a 2a                	push   $0x2a
  jmp alltraps
80105519:	e9 05 fa ff ff       	jmp    80104f23 <alltraps>

8010551e <vector43>:
.globl vector43
vector43:
  pushl $0
8010551e:	6a 00                	push   $0x0
  pushl $43
80105520:	6a 2b                	push   $0x2b
  jmp alltraps
80105522:	e9 fc f9 ff ff       	jmp    80104f23 <alltraps>

80105527 <vector44>:
.globl vector44
vector44:
  pushl $0
80105527:	6a 00                	push   $0x0
  pushl $44
80105529:	6a 2c                	push   $0x2c
  jmp alltraps
8010552b:	e9 f3 f9 ff ff       	jmp    80104f23 <alltraps>

80105530 <vector45>:
.globl vector45
vector45:
  pushl $0
80105530:	6a 00                	push   $0x0
  pushl $45
80105532:	6a 2d                	push   $0x2d
  jmp alltraps
80105534:	e9 ea f9 ff ff       	jmp    80104f23 <alltraps>

80105539 <vector46>:
.globl vector46
vector46:
  pushl $0
80105539:	6a 00                	push   $0x0
  pushl $46
8010553b:	6a 2e                	push   $0x2e
  jmp alltraps
8010553d:	e9 e1 f9 ff ff       	jmp    80104f23 <alltraps>

80105542 <vector47>:
.globl vector47
vector47:
  pushl $0
80105542:	6a 00                	push   $0x0
  pushl $47
80105544:	6a 2f                	push   $0x2f
  jmp alltraps
80105546:	e9 d8 f9 ff ff       	jmp    80104f23 <alltraps>

8010554b <vector48>:
.globl vector48
vector48:
  pushl $0
8010554b:	6a 00                	push   $0x0
  pushl $48
8010554d:	6a 30                	push   $0x30
  jmp alltraps
8010554f:	e9 cf f9 ff ff       	jmp    80104f23 <alltraps>

80105554 <vector49>:
.globl vector49
vector49:
  pushl $0
80105554:	6a 00                	push   $0x0
  pushl $49
80105556:	6a 31                	push   $0x31
  jmp alltraps
80105558:	e9 c6 f9 ff ff       	jmp    80104f23 <alltraps>

8010555d <vector50>:
.globl vector50
vector50:
  pushl $0
8010555d:	6a 00                	push   $0x0
  pushl $50
8010555f:	6a 32                	push   $0x32
  jmp alltraps
80105561:	e9 bd f9 ff ff       	jmp    80104f23 <alltraps>

80105566 <vector51>:
.globl vector51
vector51:
  pushl $0
80105566:	6a 00                	push   $0x0
  pushl $51
80105568:	6a 33                	push   $0x33
  jmp alltraps
8010556a:	e9 b4 f9 ff ff       	jmp    80104f23 <alltraps>

8010556f <vector52>:
.globl vector52
vector52:
  pushl $0
8010556f:	6a 00                	push   $0x0
  pushl $52
80105571:	6a 34                	push   $0x34
  jmp alltraps
80105573:	e9 ab f9 ff ff       	jmp    80104f23 <alltraps>

80105578 <vector53>:
.globl vector53
vector53:
  pushl $0
80105578:	6a 00                	push   $0x0
  pushl $53
8010557a:	6a 35                	push   $0x35
  jmp alltraps
8010557c:	e9 a2 f9 ff ff       	jmp    80104f23 <alltraps>

80105581 <vector54>:
.globl vector54
vector54:
  pushl $0
80105581:	6a 00                	push   $0x0
  pushl $54
80105583:	6a 36                	push   $0x36
  jmp alltraps
80105585:	e9 99 f9 ff ff       	jmp    80104f23 <alltraps>

8010558a <vector55>:
.globl vector55
vector55:
  pushl $0
8010558a:	6a 00                	push   $0x0
  pushl $55
8010558c:	6a 37                	push   $0x37
  jmp alltraps
8010558e:	e9 90 f9 ff ff       	jmp    80104f23 <alltraps>

80105593 <vector56>:
.globl vector56
vector56:
  pushl $0
80105593:	6a 00                	push   $0x0
  pushl $56
80105595:	6a 38                	push   $0x38
  jmp alltraps
80105597:	e9 87 f9 ff ff       	jmp    80104f23 <alltraps>

8010559c <vector57>:
.globl vector57
vector57:
  pushl $0
8010559c:	6a 00                	push   $0x0
  pushl $57
8010559e:	6a 39                	push   $0x39
  jmp alltraps
801055a0:	e9 7e f9 ff ff       	jmp    80104f23 <alltraps>

801055a5 <vector58>:
.globl vector58
vector58:
  pushl $0
801055a5:	6a 00                	push   $0x0
  pushl $58
801055a7:	6a 3a                	push   $0x3a
  jmp alltraps
801055a9:	e9 75 f9 ff ff       	jmp    80104f23 <alltraps>

801055ae <vector59>:
.globl vector59
vector59:
  pushl $0
801055ae:	6a 00                	push   $0x0
  pushl $59
801055b0:	6a 3b                	push   $0x3b
  jmp alltraps
801055b2:	e9 6c f9 ff ff       	jmp    80104f23 <alltraps>

801055b7 <vector60>:
.globl vector60
vector60:
  pushl $0
801055b7:	6a 00                	push   $0x0
  pushl $60
801055b9:	6a 3c                	push   $0x3c
  jmp alltraps
801055bb:	e9 63 f9 ff ff       	jmp    80104f23 <alltraps>

801055c0 <vector61>:
.globl vector61
vector61:
  pushl $0
801055c0:	6a 00                	push   $0x0
  pushl $61
801055c2:	6a 3d                	push   $0x3d
  jmp alltraps
801055c4:	e9 5a f9 ff ff       	jmp    80104f23 <alltraps>

801055c9 <vector62>:
.globl vector62
vector62:
  pushl $0
801055c9:	6a 00                	push   $0x0
  pushl $62
801055cb:	6a 3e                	push   $0x3e
  jmp alltraps
801055cd:	e9 51 f9 ff ff       	jmp    80104f23 <alltraps>

801055d2 <vector63>:
.globl vector63
vector63:
  pushl $0
801055d2:	6a 00                	push   $0x0
  pushl $63
801055d4:	6a 3f                	push   $0x3f
  jmp alltraps
801055d6:	e9 48 f9 ff ff       	jmp    80104f23 <alltraps>

801055db <vector64>:
.globl vector64
vector64:
  pushl $0
801055db:	6a 00                	push   $0x0
  pushl $64
801055dd:	6a 40                	push   $0x40
  jmp alltraps
801055df:	e9 3f f9 ff ff       	jmp    80104f23 <alltraps>

801055e4 <vector65>:
.globl vector65
vector65:
  pushl $0
801055e4:	6a 00                	push   $0x0
  pushl $65
801055e6:	6a 41                	push   $0x41
  jmp alltraps
801055e8:	e9 36 f9 ff ff       	jmp    80104f23 <alltraps>

801055ed <vector66>:
.globl vector66
vector66:
  pushl $0
801055ed:	6a 00                	push   $0x0
  pushl $66
801055ef:	6a 42                	push   $0x42
  jmp alltraps
801055f1:	e9 2d f9 ff ff       	jmp    80104f23 <alltraps>

801055f6 <vector67>:
.globl vector67
vector67:
  pushl $0
801055f6:	6a 00                	push   $0x0
  pushl $67
801055f8:	6a 43                	push   $0x43
  jmp alltraps
801055fa:	e9 24 f9 ff ff       	jmp    80104f23 <alltraps>

801055ff <vector68>:
.globl vector68
vector68:
  pushl $0
801055ff:	6a 00                	push   $0x0
  pushl $68
80105601:	6a 44                	push   $0x44
  jmp alltraps
80105603:	e9 1b f9 ff ff       	jmp    80104f23 <alltraps>

80105608 <vector69>:
.globl vector69
vector69:
  pushl $0
80105608:	6a 00                	push   $0x0
  pushl $69
8010560a:	6a 45                	push   $0x45
  jmp alltraps
8010560c:	e9 12 f9 ff ff       	jmp    80104f23 <alltraps>

80105611 <vector70>:
.globl vector70
vector70:
  pushl $0
80105611:	6a 00                	push   $0x0
  pushl $70
80105613:	6a 46                	push   $0x46
  jmp alltraps
80105615:	e9 09 f9 ff ff       	jmp    80104f23 <alltraps>

8010561a <vector71>:
.globl vector71
vector71:
  pushl $0
8010561a:	6a 00                	push   $0x0
  pushl $71
8010561c:	6a 47                	push   $0x47
  jmp alltraps
8010561e:	e9 00 f9 ff ff       	jmp    80104f23 <alltraps>

80105623 <vector72>:
.globl vector72
vector72:
  pushl $0
80105623:	6a 00                	push   $0x0
  pushl $72
80105625:	6a 48                	push   $0x48
  jmp alltraps
80105627:	e9 f7 f8 ff ff       	jmp    80104f23 <alltraps>

8010562c <vector73>:
.globl vector73
vector73:
  pushl $0
8010562c:	6a 00                	push   $0x0
  pushl $73
8010562e:	6a 49                	push   $0x49
  jmp alltraps
80105630:	e9 ee f8 ff ff       	jmp    80104f23 <alltraps>

80105635 <vector74>:
.globl vector74
vector74:
  pushl $0
80105635:	6a 00                	push   $0x0
  pushl $74
80105637:	6a 4a                	push   $0x4a
  jmp alltraps
80105639:	e9 e5 f8 ff ff       	jmp    80104f23 <alltraps>

8010563e <vector75>:
.globl vector75
vector75:
  pushl $0
8010563e:	6a 00                	push   $0x0
  pushl $75
80105640:	6a 4b                	push   $0x4b
  jmp alltraps
80105642:	e9 dc f8 ff ff       	jmp    80104f23 <alltraps>

80105647 <vector76>:
.globl vector76
vector76:
  pushl $0
80105647:	6a 00                	push   $0x0
  pushl $76
80105649:	6a 4c                	push   $0x4c
  jmp alltraps
8010564b:	e9 d3 f8 ff ff       	jmp    80104f23 <alltraps>

80105650 <vector77>:
.globl vector77
vector77:
  pushl $0
80105650:	6a 00                	push   $0x0
  pushl $77
80105652:	6a 4d                	push   $0x4d
  jmp alltraps
80105654:	e9 ca f8 ff ff       	jmp    80104f23 <alltraps>

80105659 <vector78>:
.globl vector78
vector78:
  pushl $0
80105659:	6a 00                	push   $0x0
  pushl $78
8010565b:	6a 4e                	push   $0x4e
  jmp alltraps
8010565d:	e9 c1 f8 ff ff       	jmp    80104f23 <alltraps>

80105662 <vector79>:
.globl vector79
vector79:
  pushl $0
80105662:	6a 00                	push   $0x0
  pushl $79
80105664:	6a 4f                	push   $0x4f
  jmp alltraps
80105666:	e9 b8 f8 ff ff       	jmp    80104f23 <alltraps>

8010566b <vector80>:
.globl vector80
vector80:
  pushl $0
8010566b:	6a 00                	push   $0x0
  pushl $80
8010566d:	6a 50                	push   $0x50
  jmp alltraps
8010566f:	e9 af f8 ff ff       	jmp    80104f23 <alltraps>

80105674 <vector81>:
.globl vector81
vector81:
  pushl $0
80105674:	6a 00                	push   $0x0
  pushl $81
80105676:	6a 51                	push   $0x51
  jmp alltraps
80105678:	e9 a6 f8 ff ff       	jmp    80104f23 <alltraps>

8010567d <vector82>:
.globl vector82
vector82:
  pushl $0
8010567d:	6a 00                	push   $0x0
  pushl $82
8010567f:	6a 52                	push   $0x52
  jmp alltraps
80105681:	e9 9d f8 ff ff       	jmp    80104f23 <alltraps>

80105686 <vector83>:
.globl vector83
vector83:
  pushl $0
80105686:	6a 00                	push   $0x0
  pushl $83
80105688:	6a 53                	push   $0x53
  jmp alltraps
8010568a:	e9 94 f8 ff ff       	jmp    80104f23 <alltraps>

8010568f <vector84>:
.globl vector84
vector84:
  pushl $0
8010568f:	6a 00                	push   $0x0
  pushl $84
80105691:	6a 54                	push   $0x54
  jmp alltraps
80105693:	e9 8b f8 ff ff       	jmp    80104f23 <alltraps>

80105698 <vector85>:
.globl vector85
vector85:
  pushl $0
80105698:	6a 00                	push   $0x0
  pushl $85
8010569a:	6a 55                	push   $0x55
  jmp alltraps
8010569c:	e9 82 f8 ff ff       	jmp    80104f23 <alltraps>

801056a1 <vector86>:
.globl vector86
vector86:
  pushl $0
801056a1:	6a 00                	push   $0x0
  pushl $86
801056a3:	6a 56                	push   $0x56
  jmp alltraps
801056a5:	e9 79 f8 ff ff       	jmp    80104f23 <alltraps>

801056aa <vector87>:
.globl vector87
vector87:
  pushl $0
801056aa:	6a 00                	push   $0x0
  pushl $87
801056ac:	6a 57                	push   $0x57
  jmp alltraps
801056ae:	e9 70 f8 ff ff       	jmp    80104f23 <alltraps>

801056b3 <vector88>:
.globl vector88
vector88:
  pushl $0
801056b3:	6a 00                	push   $0x0
  pushl $88
801056b5:	6a 58                	push   $0x58
  jmp alltraps
801056b7:	e9 67 f8 ff ff       	jmp    80104f23 <alltraps>

801056bc <vector89>:
.globl vector89
vector89:
  pushl $0
801056bc:	6a 00                	push   $0x0
  pushl $89
801056be:	6a 59                	push   $0x59
  jmp alltraps
801056c0:	e9 5e f8 ff ff       	jmp    80104f23 <alltraps>

801056c5 <vector90>:
.globl vector90
vector90:
  pushl $0
801056c5:	6a 00                	push   $0x0
  pushl $90
801056c7:	6a 5a                	push   $0x5a
  jmp alltraps
801056c9:	e9 55 f8 ff ff       	jmp    80104f23 <alltraps>

801056ce <vector91>:
.globl vector91
vector91:
  pushl $0
801056ce:	6a 00                	push   $0x0
  pushl $91
801056d0:	6a 5b                	push   $0x5b
  jmp alltraps
801056d2:	e9 4c f8 ff ff       	jmp    80104f23 <alltraps>

801056d7 <vector92>:
.globl vector92
vector92:
  pushl $0
801056d7:	6a 00                	push   $0x0
  pushl $92
801056d9:	6a 5c                	push   $0x5c
  jmp alltraps
801056db:	e9 43 f8 ff ff       	jmp    80104f23 <alltraps>

801056e0 <vector93>:
.globl vector93
vector93:
  pushl $0
801056e0:	6a 00                	push   $0x0
  pushl $93
801056e2:	6a 5d                	push   $0x5d
  jmp alltraps
801056e4:	e9 3a f8 ff ff       	jmp    80104f23 <alltraps>

801056e9 <vector94>:
.globl vector94
vector94:
  pushl $0
801056e9:	6a 00                	push   $0x0
  pushl $94
801056eb:	6a 5e                	push   $0x5e
  jmp alltraps
801056ed:	e9 31 f8 ff ff       	jmp    80104f23 <alltraps>

801056f2 <vector95>:
.globl vector95
vector95:
  pushl $0
801056f2:	6a 00                	push   $0x0
  pushl $95
801056f4:	6a 5f                	push   $0x5f
  jmp alltraps
801056f6:	e9 28 f8 ff ff       	jmp    80104f23 <alltraps>

801056fb <vector96>:
.globl vector96
vector96:
  pushl $0
801056fb:	6a 00                	push   $0x0
  pushl $96
801056fd:	6a 60                	push   $0x60
  jmp alltraps
801056ff:	e9 1f f8 ff ff       	jmp    80104f23 <alltraps>

80105704 <vector97>:
.globl vector97
vector97:
  pushl $0
80105704:	6a 00                	push   $0x0
  pushl $97
80105706:	6a 61                	push   $0x61
  jmp alltraps
80105708:	e9 16 f8 ff ff       	jmp    80104f23 <alltraps>

8010570d <vector98>:
.globl vector98
vector98:
  pushl $0
8010570d:	6a 00                	push   $0x0
  pushl $98
8010570f:	6a 62                	push   $0x62
  jmp alltraps
80105711:	e9 0d f8 ff ff       	jmp    80104f23 <alltraps>

80105716 <vector99>:
.globl vector99
vector99:
  pushl $0
80105716:	6a 00                	push   $0x0
  pushl $99
80105718:	6a 63                	push   $0x63
  jmp alltraps
8010571a:	e9 04 f8 ff ff       	jmp    80104f23 <alltraps>

8010571f <vector100>:
.globl vector100
vector100:
  pushl $0
8010571f:	6a 00                	push   $0x0
  pushl $100
80105721:	6a 64                	push   $0x64
  jmp alltraps
80105723:	e9 fb f7 ff ff       	jmp    80104f23 <alltraps>

80105728 <vector101>:
.globl vector101
vector101:
  pushl $0
80105728:	6a 00                	push   $0x0
  pushl $101
8010572a:	6a 65                	push   $0x65
  jmp alltraps
8010572c:	e9 f2 f7 ff ff       	jmp    80104f23 <alltraps>

80105731 <vector102>:
.globl vector102
vector102:
  pushl $0
80105731:	6a 00                	push   $0x0
  pushl $102
80105733:	6a 66                	push   $0x66
  jmp alltraps
80105735:	e9 e9 f7 ff ff       	jmp    80104f23 <alltraps>

8010573a <vector103>:
.globl vector103
vector103:
  pushl $0
8010573a:	6a 00                	push   $0x0
  pushl $103
8010573c:	6a 67                	push   $0x67
  jmp alltraps
8010573e:	e9 e0 f7 ff ff       	jmp    80104f23 <alltraps>

80105743 <vector104>:
.globl vector104
vector104:
  pushl $0
80105743:	6a 00                	push   $0x0
  pushl $104
80105745:	6a 68                	push   $0x68
  jmp alltraps
80105747:	e9 d7 f7 ff ff       	jmp    80104f23 <alltraps>

8010574c <vector105>:
.globl vector105
vector105:
  pushl $0
8010574c:	6a 00                	push   $0x0
  pushl $105
8010574e:	6a 69                	push   $0x69
  jmp alltraps
80105750:	e9 ce f7 ff ff       	jmp    80104f23 <alltraps>

80105755 <vector106>:
.globl vector106
vector106:
  pushl $0
80105755:	6a 00                	push   $0x0
  pushl $106
80105757:	6a 6a                	push   $0x6a
  jmp alltraps
80105759:	e9 c5 f7 ff ff       	jmp    80104f23 <alltraps>

8010575e <vector107>:
.globl vector107
vector107:
  pushl $0
8010575e:	6a 00                	push   $0x0
  pushl $107
80105760:	6a 6b                	push   $0x6b
  jmp alltraps
80105762:	e9 bc f7 ff ff       	jmp    80104f23 <alltraps>

80105767 <vector108>:
.globl vector108
vector108:
  pushl $0
80105767:	6a 00                	push   $0x0
  pushl $108
80105769:	6a 6c                	push   $0x6c
  jmp alltraps
8010576b:	e9 b3 f7 ff ff       	jmp    80104f23 <alltraps>

80105770 <vector109>:
.globl vector109
vector109:
  pushl $0
80105770:	6a 00                	push   $0x0
  pushl $109
80105772:	6a 6d                	push   $0x6d
  jmp alltraps
80105774:	e9 aa f7 ff ff       	jmp    80104f23 <alltraps>

80105779 <vector110>:
.globl vector110
vector110:
  pushl $0
80105779:	6a 00                	push   $0x0
  pushl $110
8010577b:	6a 6e                	push   $0x6e
  jmp alltraps
8010577d:	e9 a1 f7 ff ff       	jmp    80104f23 <alltraps>

80105782 <vector111>:
.globl vector111
vector111:
  pushl $0
80105782:	6a 00                	push   $0x0
  pushl $111
80105784:	6a 6f                	push   $0x6f
  jmp alltraps
80105786:	e9 98 f7 ff ff       	jmp    80104f23 <alltraps>

8010578b <vector112>:
.globl vector112
vector112:
  pushl $0
8010578b:	6a 00                	push   $0x0
  pushl $112
8010578d:	6a 70                	push   $0x70
  jmp alltraps
8010578f:	e9 8f f7 ff ff       	jmp    80104f23 <alltraps>

80105794 <vector113>:
.globl vector113
vector113:
  pushl $0
80105794:	6a 00                	push   $0x0
  pushl $113
80105796:	6a 71                	push   $0x71
  jmp alltraps
80105798:	e9 86 f7 ff ff       	jmp    80104f23 <alltraps>

8010579d <vector114>:
.globl vector114
vector114:
  pushl $0
8010579d:	6a 00                	push   $0x0
  pushl $114
8010579f:	6a 72                	push   $0x72
  jmp alltraps
801057a1:	e9 7d f7 ff ff       	jmp    80104f23 <alltraps>

801057a6 <vector115>:
.globl vector115
vector115:
  pushl $0
801057a6:	6a 00                	push   $0x0
  pushl $115
801057a8:	6a 73                	push   $0x73
  jmp alltraps
801057aa:	e9 74 f7 ff ff       	jmp    80104f23 <alltraps>

801057af <vector116>:
.globl vector116
vector116:
  pushl $0
801057af:	6a 00                	push   $0x0
  pushl $116
801057b1:	6a 74                	push   $0x74
  jmp alltraps
801057b3:	e9 6b f7 ff ff       	jmp    80104f23 <alltraps>

801057b8 <vector117>:
.globl vector117
vector117:
  pushl $0
801057b8:	6a 00                	push   $0x0
  pushl $117
801057ba:	6a 75                	push   $0x75
  jmp alltraps
801057bc:	e9 62 f7 ff ff       	jmp    80104f23 <alltraps>

801057c1 <vector118>:
.globl vector118
vector118:
  pushl $0
801057c1:	6a 00                	push   $0x0
  pushl $118
801057c3:	6a 76                	push   $0x76
  jmp alltraps
801057c5:	e9 59 f7 ff ff       	jmp    80104f23 <alltraps>

801057ca <vector119>:
.globl vector119
vector119:
  pushl $0
801057ca:	6a 00                	push   $0x0
  pushl $119
801057cc:	6a 77                	push   $0x77
  jmp alltraps
801057ce:	e9 50 f7 ff ff       	jmp    80104f23 <alltraps>

801057d3 <vector120>:
.globl vector120
vector120:
  pushl $0
801057d3:	6a 00                	push   $0x0
  pushl $120
801057d5:	6a 78                	push   $0x78
  jmp alltraps
801057d7:	e9 47 f7 ff ff       	jmp    80104f23 <alltraps>

801057dc <vector121>:
.globl vector121
vector121:
  pushl $0
801057dc:	6a 00                	push   $0x0
  pushl $121
801057de:	6a 79                	push   $0x79
  jmp alltraps
801057e0:	e9 3e f7 ff ff       	jmp    80104f23 <alltraps>

801057e5 <vector122>:
.globl vector122
vector122:
  pushl $0
801057e5:	6a 00                	push   $0x0
  pushl $122
801057e7:	6a 7a                	push   $0x7a
  jmp alltraps
801057e9:	e9 35 f7 ff ff       	jmp    80104f23 <alltraps>

801057ee <vector123>:
.globl vector123
vector123:
  pushl $0
801057ee:	6a 00                	push   $0x0
  pushl $123
801057f0:	6a 7b                	push   $0x7b
  jmp alltraps
801057f2:	e9 2c f7 ff ff       	jmp    80104f23 <alltraps>

801057f7 <vector124>:
.globl vector124
vector124:
  pushl $0
801057f7:	6a 00                	push   $0x0
  pushl $124
801057f9:	6a 7c                	push   $0x7c
  jmp alltraps
801057fb:	e9 23 f7 ff ff       	jmp    80104f23 <alltraps>

80105800 <vector125>:
.globl vector125
vector125:
  pushl $0
80105800:	6a 00                	push   $0x0
  pushl $125
80105802:	6a 7d                	push   $0x7d
  jmp alltraps
80105804:	e9 1a f7 ff ff       	jmp    80104f23 <alltraps>

80105809 <vector126>:
.globl vector126
vector126:
  pushl $0
80105809:	6a 00                	push   $0x0
  pushl $126
8010580b:	6a 7e                	push   $0x7e
  jmp alltraps
8010580d:	e9 11 f7 ff ff       	jmp    80104f23 <alltraps>

80105812 <vector127>:
.globl vector127
vector127:
  pushl $0
80105812:	6a 00                	push   $0x0
  pushl $127
80105814:	6a 7f                	push   $0x7f
  jmp alltraps
80105816:	e9 08 f7 ff ff       	jmp    80104f23 <alltraps>

8010581b <vector128>:
.globl vector128
vector128:
  pushl $0
8010581b:	6a 00                	push   $0x0
  pushl $128
8010581d:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105822:	e9 fc f6 ff ff       	jmp    80104f23 <alltraps>

80105827 <vector129>:
.globl vector129
vector129:
  pushl $0
80105827:	6a 00                	push   $0x0
  pushl $129
80105829:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010582e:	e9 f0 f6 ff ff       	jmp    80104f23 <alltraps>

80105833 <vector130>:
.globl vector130
vector130:
  pushl $0
80105833:	6a 00                	push   $0x0
  pushl $130
80105835:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010583a:	e9 e4 f6 ff ff       	jmp    80104f23 <alltraps>

8010583f <vector131>:
.globl vector131
vector131:
  pushl $0
8010583f:	6a 00                	push   $0x0
  pushl $131
80105841:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105846:	e9 d8 f6 ff ff       	jmp    80104f23 <alltraps>

8010584b <vector132>:
.globl vector132
vector132:
  pushl $0
8010584b:	6a 00                	push   $0x0
  pushl $132
8010584d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105852:	e9 cc f6 ff ff       	jmp    80104f23 <alltraps>

80105857 <vector133>:
.globl vector133
vector133:
  pushl $0
80105857:	6a 00                	push   $0x0
  pushl $133
80105859:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010585e:	e9 c0 f6 ff ff       	jmp    80104f23 <alltraps>

80105863 <vector134>:
.globl vector134
vector134:
  pushl $0
80105863:	6a 00                	push   $0x0
  pushl $134
80105865:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010586a:	e9 b4 f6 ff ff       	jmp    80104f23 <alltraps>

8010586f <vector135>:
.globl vector135
vector135:
  pushl $0
8010586f:	6a 00                	push   $0x0
  pushl $135
80105871:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105876:	e9 a8 f6 ff ff       	jmp    80104f23 <alltraps>

8010587b <vector136>:
.globl vector136
vector136:
  pushl $0
8010587b:	6a 00                	push   $0x0
  pushl $136
8010587d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105882:	e9 9c f6 ff ff       	jmp    80104f23 <alltraps>

80105887 <vector137>:
.globl vector137
vector137:
  pushl $0
80105887:	6a 00                	push   $0x0
  pushl $137
80105889:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010588e:	e9 90 f6 ff ff       	jmp    80104f23 <alltraps>

80105893 <vector138>:
.globl vector138
vector138:
  pushl $0
80105893:	6a 00                	push   $0x0
  pushl $138
80105895:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010589a:	e9 84 f6 ff ff       	jmp    80104f23 <alltraps>

8010589f <vector139>:
.globl vector139
vector139:
  pushl $0
8010589f:	6a 00                	push   $0x0
  pushl $139
801058a1:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801058a6:	e9 78 f6 ff ff       	jmp    80104f23 <alltraps>

801058ab <vector140>:
.globl vector140
vector140:
  pushl $0
801058ab:	6a 00                	push   $0x0
  pushl $140
801058ad:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801058b2:	e9 6c f6 ff ff       	jmp    80104f23 <alltraps>

801058b7 <vector141>:
.globl vector141
vector141:
  pushl $0
801058b7:	6a 00                	push   $0x0
  pushl $141
801058b9:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801058be:	e9 60 f6 ff ff       	jmp    80104f23 <alltraps>

801058c3 <vector142>:
.globl vector142
vector142:
  pushl $0
801058c3:	6a 00                	push   $0x0
  pushl $142
801058c5:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801058ca:	e9 54 f6 ff ff       	jmp    80104f23 <alltraps>

801058cf <vector143>:
.globl vector143
vector143:
  pushl $0
801058cf:	6a 00                	push   $0x0
  pushl $143
801058d1:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801058d6:	e9 48 f6 ff ff       	jmp    80104f23 <alltraps>

801058db <vector144>:
.globl vector144
vector144:
  pushl $0
801058db:	6a 00                	push   $0x0
  pushl $144
801058dd:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801058e2:	e9 3c f6 ff ff       	jmp    80104f23 <alltraps>

801058e7 <vector145>:
.globl vector145
vector145:
  pushl $0
801058e7:	6a 00                	push   $0x0
  pushl $145
801058e9:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801058ee:	e9 30 f6 ff ff       	jmp    80104f23 <alltraps>

801058f3 <vector146>:
.globl vector146
vector146:
  pushl $0
801058f3:	6a 00                	push   $0x0
  pushl $146
801058f5:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801058fa:	e9 24 f6 ff ff       	jmp    80104f23 <alltraps>

801058ff <vector147>:
.globl vector147
vector147:
  pushl $0
801058ff:	6a 00                	push   $0x0
  pushl $147
80105901:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105906:	e9 18 f6 ff ff       	jmp    80104f23 <alltraps>

8010590b <vector148>:
.globl vector148
vector148:
  pushl $0
8010590b:	6a 00                	push   $0x0
  pushl $148
8010590d:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105912:	e9 0c f6 ff ff       	jmp    80104f23 <alltraps>

80105917 <vector149>:
.globl vector149
vector149:
  pushl $0
80105917:	6a 00                	push   $0x0
  pushl $149
80105919:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010591e:	e9 00 f6 ff ff       	jmp    80104f23 <alltraps>

80105923 <vector150>:
.globl vector150
vector150:
  pushl $0
80105923:	6a 00                	push   $0x0
  pushl $150
80105925:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010592a:	e9 f4 f5 ff ff       	jmp    80104f23 <alltraps>

8010592f <vector151>:
.globl vector151
vector151:
  pushl $0
8010592f:	6a 00                	push   $0x0
  pushl $151
80105931:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105936:	e9 e8 f5 ff ff       	jmp    80104f23 <alltraps>

8010593b <vector152>:
.globl vector152
vector152:
  pushl $0
8010593b:	6a 00                	push   $0x0
  pushl $152
8010593d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105942:	e9 dc f5 ff ff       	jmp    80104f23 <alltraps>

80105947 <vector153>:
.globl vector153
vector153:
  pushl $0
80105947:	6a 00                	push   $0x0
  pushl $153
80105949:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010594e:	e9 d0 f5 ff ff       	jmp    80104f23 <alltraps>

80105953 <vector154>:
.globl vector154
vector154:
  pushl $0
80105953:	6a 00                	push   $0x0
  pushl $154
80105955:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010595a:	e9 c4 f5 ff ff       	jmp    80104f23 <alltraps>

8010595f <vector155>:
.globl vector155
vector155:
  pushl $0
8010595f:	6a 00                	push   $0x0
  pushl $155
80105961:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105966:	e9 b8 f5 ff ff       	jmp    80104f23 <alltraps>

8010596b <vector156>:
.globl vector156
vector156:
  pushl $0
8010596b:	6a 00                	push   $0x0
  pushl $156
8010596d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105972:	e9 ac f5 ff ff       	jmp    80104f23 <alltraps>

80105977 <vector157>:
.globl vector157
vector157:
  pushl $0
80105977:	6a 00                	push   $0x0
  pushl $157
80105979:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010597e:	e9 a0 f5 ff ff       	jmp    80104f23 <alltraps>

80105983 <vector158>:
.globl vector158
vector158:
  pushl $0
80105983:	6a 00                	push   $0x0
  pushl $158
80105985:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010598a:	e9 94 f5 ff ff       	jmp    80104f23 <alltraps>

8010598f <vector159>:
.globl vector159
vector159:
  pushl $0
8010598f:	6a 00                	push   $0x0
  pushl $159
80105991:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105996:	e9 88 f5 ff ff       	jmp    80104f23 <alltraps>

8010599b <vector160>:
.globl vector160
vector160:
  pushl $0
8010599b:	6a 00                	push   $0x0
  pushl $160
8010599d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801059a2:	e9 7c f5 ff ff       	jmp    80104f23 <alltraps>

801059a7 <vector161>:
.globl vector161
vector161:
  pushl $0
801059a7:	6a 00                	push   $0x0
  pushl $161
801059a9:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801059ae:	e9 70 f5 ff ff       	jmp    80104f23 <alltraps>

801059b3 <vector162>:
.globl vector162
vector162:
  pushl $0
801059b3:	6a 00                	push   $0x0
  pushl $162
801059b5:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801059ba:	e9 64 f5 ff ff       	jmp    80104f23 <alltraps>

801059bf <vector163>:
.globl vector163
vector163:
  pushl $0
801059bf:	6a 00                	push   $0x0
  pushl $163
801059c1:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801059c6:	e9 58 f5 ff ff       	jmp    80104f23 <alltraps>

801059cb <vector164>:
.globl vector164
vector164:
  pushl $0
801059cb:	6a 00                	push   $0x0
  pushl $164
801059cd:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801059d2:	e9 4c f5 ff ff       	jmp    80104f23 <alltraps>

801059d7 <vector165>:
.globl vector165
vector165:
  pushl $0
801059d7:	6a 00                	push   $0x0
  pushl $165
801059d9:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801059de:	e9 40 f5 ff ff       	jmp    80104f23 <alltraps>

801059e3 <vector166>:
.globl vector166
vector166:
  pushl $0
801059e3:	6a 00                	push   $0x0
  pushl $166
801059e5:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801059ea:	e9 34 f5 ff ff       	jmp    80104f23 <alltraps>

801059ef <vector167>:
.globl vector167
vector167:
  pushl $0
801059ef:	6a 00                	push   $0x0
  pushl $167
801059f1:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801059f6:	e9 28 f5 ff ff       	jmp    80104f23 <alltraps>

801059fb <vector168>:
.globl vector168
vector168:
  pushl $0
801059fb:	6a 00                	push   $0x0
  pushl $168
801059fd:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105a02:	e9 1c f5 ff ff       	jmp    80104f23 <alltraps>

80105a07 <vector169>:
.globl vector169
vector169:
  pushl $0
80105a07:	6a 00                	push   $0x0
  pushl $169
80105a09:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105a0e:	e9 10 f5 ff ff       	jmp    80104f23 <alltraps>

80105a13 <vector170>:
.globl vector170
vector170:
  pushl $0
80105a13:	6a 00                	push   $0x0
  pushl $170
80105a15:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105a1a:	e9 04 f5 ff ff       	jmp    80104f23 <alltraps>

80105a1f <vector171>:
.globl vector171
vector171:
  pushl $0
80105a1f:	6a 00                	push   $0x0
  pushl $171
80105a21:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105a26:	e9 f8 f4 ff ff       	jmp    80104f23 <alltraps>

80105a2b <vector172>:
.globl vector172
vector172:
  pushl $0
80105a2b:	6a 00                	push   $0x0
  pushl $172
80105a2d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105a32:	e9 ec f4 ff ff       	jmp    80104f23 <alltraps>

80105a37 <vector173>:
.globl vector173
vector173:
  pushl $0
80105a37:	6a 00                	push   $0x0
  pushl $173
80105a39:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105a3e:	e9 e0 f4 ff ff       	jmp    80104f23 <alltraps>

80105a43 <vector174>:
.globl vector174
vector174:
  pushl $0
80105a43:	6a 00                	push   $0x0
  pushl $174
80105a45:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105a4a:	e9 d4 f4 ff ff       	jmp    80104f23 <alltraps>

80105a4f <vector175>:
.globl vector175
vector175:
  pushl $0
80105a4f:	6a 00                	push   $0x0
  pushl $175
80105a51:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105a56:	e9 c8 f4 ff ff       	jmp    80104f23 <alltraps>

80105a5b <vector176>:
.globl vector176
vector176:
  pushl $0
80105a5b:	6a 00                	push   $0x0
  pushl $176
80105a5d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105a62:	e9 bc f4 ff ff       	jmp    80104f23 <alltraps>

80105a67 <vector177>:
.globl vector177
vector177:
  pushl $0
80105a67:	6a 00                	push   $0x0
  pushl $177
80105a69:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105a6e:	e9 b0 f4 ff ff       	jmp    80104f23 <alltraps>

80105a73 <vector178>:
.globl vector178
vector178:
  pushl $0
80105a73:	6a 00                	push   $0x0
  pushl $178
80105a75:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105a7a:	e9 a4 f4 ff ff       	jmp    80104f23 <alltraps>

80105a7f <vector179>:
.globl vector179
vector179:
  pushl $0
80105a7f:	6a 00                	push   $0x0
  pushl $179
80105a81:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105a86:	e9 98 f4 ff ff       	jmp    80104f23 <alltraps>

80105a8b <vector180>:
.globl vector180
vector180:
  pushl $0
80105a8b:	6a 00                	push   $0x0
  pushl $180
80105a8d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105a92:	e9 8c f4 ff ff       	jmp    80104f23 <alltraps>

80105a97 <vector181>:
.globl vector181
vector181:
  pushl $0
80105a97:	6a 00                	push   $0x0
  pushl $181
80105a99:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105a9e:	e9 80 f4 ff ff       	jmp    80104f23 <alltraps>

80105aa3 <vector182>:
.globl vector182
vector182:
  pushl $0
80105aa3:	6a 00                	push   $0x0
  pushl $182
80105aa5:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105aaa:	e9 74 f4 ff ff       	jmp    80104f23 <alltraps>

80105aaf <vector183>:
.globl vector183
vector183:
  pushl $0
80105aaf:	6a 00                	push   $0x0
  pushl $183
80105ab1:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105ab6:	e9 68 f4 ff ff       	jmp    80104f23 <alltraps>

80105abb <vector184>:
.globl vector184
vector184:
  pushl $0
80105abb:	6a 00                	push   $0x0
  pushl $184
80105abd:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105ac2:	e9 5c f4 ff ff       	jmp    80104f23 <alltraps>

80105ac7 <vector185>:
.globl vector185
vector185:
  pushl $0
80105ac7:	6a 00                	push   $0x0
  pushl $185
80105ac9:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105ace:	e9 50 f4 ff ff       	jmp    80104f23 <alltraps>

80105ad3 <vector186>:
.globl vector186
vector186:
  pushl $0
80105ad3:	6a 00                	push   $0x0
  pushl $186
80105ad5:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105ada:	e9 44 f4 ff ff       	jmp    80104f23 <alltraps>

80105adf <vector187>:
.globl vector187
vector187:
  pushl $0
80105adf:	6a 00                	push   $0x0
  pushl $187
80105ae1:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105ae6:	e9 38 f4 ff ff       	jmp    80104f23 <alltraps>

80105aeb <vector188>:
.globl vector188
vector188:
  pushl $0
80105aeb:	6a 00                	push   $0x0
  pushl $188
80105aed:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105af2:	e9 2c f4 ff ff       	jmp    80104f23 <alltraps>

80105af7 <vector189>:
.globl vector189
vector189:
  pushl $0
80105af7:	6a 00                	push   $0x0
  pushl $189
80105af9:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105afe:	e9 20 f4 ff ff       	jmp    80104f23 <alltraps>

80105b03 <vector190>:
.globl vector190
vector190:
  pushl $0
80105b03:	6a 00                	push   $0x0
  pushl $190
80105b05:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105b0a:	e9 14 f4 ff ff       	jmp    80104f23 <alltraps>

80105b0f <vector191>:
.globl vector191
vector191:
  pushl $0
80105b0f:	6a 00                	push   $0x0
  pushl $191
80105b11:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105b16:	e9 08 f4 ff ff       	jmp    80104f23 <alltraps>

80105b1b <vector192>:
.globl vector192
vector192:
  pushl $0
80105b1b:	6a 00                	push   $0x0
  pushl $192
80105b1d:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105b22:	e9 fc f3 ff ff       	jmp    80104f23 <alltraps>

80105b27 <vector193>:
.globl vector193
vector193:
  pushl $0
80105b27:	6a 00                	push   $0x0
  pushl $193
80105b29:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105b2e:	e9 f0 f3 ff ff       	jmp    80104f23 <alltraps>

80105b33 <vector194>:
.globl vector194
vector194:
  pushl $0
80105b33:	6a 00                	push   $0x0
  pushl $194
80105b35:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105b3a:	e9 e4 f3 ff ff       	jmp    80104f23 <alltraps>

80105b3f <vector195>:
.globl vector195
vector195:
  pushl $0
80105b3f:	6a 00                	push   $0x0
  pushl $195
80105b41:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105b46:	e9 d8 f3 ff ff       	jmp    80104f23 <alltraps>

80105b4b <vector196>:
.globl vector196
vector196:
  pushl $0
80105b4b:	6a 00                	push   $0x0
  pushl $196
80105b4d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105b52:	e9 cc f3 ff ff       	jmp    80104f23 <alltraps>

80105b57 <vector197>:
.globl vector197
vector197:
  pushl $0
80105b57:	6a 00                	push   $0x0
  pushl $197
80105b59:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105b5e:	e9 c0 f3 ff ff       	jmp    80104f23 <alltraps>

80105b63 <vector198>:
.globl vector198
vector198:
  pushl $0
80105b63:	6a 00                	push   $0x0
  pushl $198
80105b65:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105b6a:	e9 b4 f3 ff ff       	jmp    80104f23 <alltraps>

80105b6f <vector199>:
.globl vector199
vector199:
  pushl $0
80105b6f:	6a 00                	push   $0x0
  pushl $199
80105b71:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105b76:	e9 a8 f3 ff ff       	jmp    80104f23 <alltraps>

80105b7b <vector200>:
.globl vector200
vector200:
  pushl $0
80105b7b:	6a 00                	push   $0x0
  pushl $200
80105b7d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105b82:	e9 9c f3 ff ff       	jmp    80104f23 <alltraps>

80105b87 <vector201>:
.globl vector201
vector201:
  pushl $0
80105b87:	6a 00                	push   $0x0
  pushl $201
80105b89:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105b8e:	e9 90 f3 ff ff       	jmp    80104f23 <alltraps>

80105b93 <vector202>:
.globl vector202
vector202:
  pushl $0
80105b93:	6a 00                	push   $0x0
  pushl $202
80105b95:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105b9a:	e9 84 f3 ff ff       	jmp    80104f23 <alltraps>

80105b9f <vector203>:
.globl vector203
vector203:
  pushl $0
80105b9f:	6a 00                	push   $0x0
  pushl $203
80105ba1:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105ba6:	e9 78 f3 ff ff       	jmp    80104f23 <alltraps>

80105bab <vector204>:
.globl vector204
vector204:
  pushl $0
80105bab:	6a 00                	push   $0x0
  pushl $204
80105bad:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105bb2:	e9 6c f3 ff ff       	jmp    80104f23 <alltraps>

80105bb7 <vector205>:
.globl vector205
vector205:
  pushl $0
80105bb7:	6a 00                	push   $0x0
  pushl $205
80105bb9:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105bbe:	e9 60 f3 ff ff       	jmp    80104f23 <alltraps>

80105bc3 <vector206>:
.globl vector206
vector206:
  pushl $0
80105bc3:	6a 00                	push   $0x0
  pushl $206
80105bc5:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105bca:	e9 54 f3 ff ff       	jmp    80104f23 <alltraps>

80105bcf <vector207>:
.globl vector207
vector207:
  pushl $0
80105bcf:	6a 00                	push   $0x0
  pushl $207
80105bd1:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105bd6:	e9 48 f3 ff ff       	jmp    80104f23 <alltraps>

80105bdb <vector208>:
.globl vector208
vector208:
  pushl $0
80105bdb:	6a 00                	push   $0x0
  pushl $208
80105bdd:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105be2:	e9 3c f3 ff ff       	jmp    80104f23 <alltraps>

80105be7 <vector209>:
.globl vector209
vector209:
  pushl $0
80105be7:	6a 00                	push   $0x0
  pushl $209
80105be9:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105bee:	e9 30 f3 ff ff       	jmp    80104f23 <alltraps>

80105bf3 <vector210>:
.globl vector210
vector210:
  pushl $0
80105bf3:	6a 00                	push   $0x0
  pushl $210
80105bf5:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105bfa:	e9 24 f3 ff ff       	jmp    80104f23 <alltraps>

80105bff <vector211>:
.globl vector211
vector211:
  pushl $0
80105bff:	6a 00                	push   $0x0
  pushl $211
80105c01:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105c06:	e9 18 f3 ff ff       	jmp    80104f23 <alltraps>

80105c0b <vector212>:
.globl vector212
vector212:
  pushl $0
80105c0b:	6a 00                	push   $0x0
  pushl $212
80105c0d:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105c12:	e9 0c f3 ff ff       	jmp    80104f23 <alltraps>

80105c17 <vector213>:
.globl vector213
vector213:
  pushl $0
80105c17:	6a 00                	push   $0x0
  pushl $213
80105c19:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105c1e:	e9 00 f3 ff ff       	jmp    80104f23 <alltraps>

80105c23 <vector214>:
.globl vector214
vector214:
  pushl $0
80105c23:	6a 00                	push   $0x0
  pushl $214
80105c25:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105c2a:	e9 f4 f2 ff ff       	jmp    80104f23 <alltraps>

80105c2f <vector215>:
.globl vector215
vector215:
  pushl $0
80105c2f:	6a 00                	push   $0x0
  pushl $215
80105c31:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105c36:	e9 e8 f2 ff ff       	jmp    80104f23 <alltraps>

80105c3b <vector216>:
.globl vector216
vector216:
  pushl $0
80105c3b:	6a 00                	push   $0x0
  pushl $216
80105c3d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105c42:	e9 dc f2 ff ff       	jmp    80104f23 <alltraps>

80105c47 <vector217>:
.globl vector217
vector217:
  pushl $0
80105c47:	6a 00                	push   $0x0
  pushl $217
80105c49:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105c4e:	e9 d0 f2 ff ff       	jmp    80104f23 <alltraps>

80105c53 <vector218>:
.globl vector218
vector218:
  pushl $0
80105c53:	6a 00                	push   $0x0
  pushl $218
80105c55:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105c5a:	e9 c4 f2 ff ff       	jmp    80104f23 <alltraps>

80105c5f <vector219>:
.globl vector219
vector219:
  pushl $0
80105c5f:	6a 00                	push   $0x0
  pushl $219
80105c61:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105c66:	e9 b8 f2 ff ff       	jmp    80104f23 <alltraps>

80105c6b <vector220>:
.globl vector220
vector220:
  pushl $0
80105c6b:	6a 00                	push   $0x0
  pushl $220
80105c6d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105c72:	e9 ac f2 ff ff       	jmp    80104f23 <alltraps>

80105c77 <vector221>:
.globl vector221
vector221:
  pushl $0
80105c77:	6a 00                	push   $0x0
  pushl $221
80105c79:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105c7e:	e9 a0 f2 ff ff       	jmp    80104f23 <alltraps>

80105c83 <vector222>:
.globl vector222
vector222:
  pushl $0
80105c83:	6a 00                	push   $0x0
  pushl $222
80105c85:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105c8a:	e9 94 f2 ff ff       	jmp    80104f23 <alltraps>

80105c8f <vector223>:
.globl vector223
vector223:
  pushl $0
80105c8f:	6a 00                	push   $0x0
  pushl $223
80105c91:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105c96:	e9 88 f2 ff ff       	jmp    80104f23 <alltraps>

80105c9b <vector224>:
.globl vector224
vector224:
  pushl $0
80105c9b:	6a 00                	push   $0x0
  pushl $224
80105c9d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105ca2:	e9 7c f2 ff ff       	jmp    80104f23 <alltraps>

80105ca7 <vector225>:
.globl vector225
vector225:
  pushl $0
80105ca7:	6a 00                	push   $0x0
  pushl $225
80105ca9:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105cae:	e9 70 f2 ff ff       	jmp    80104f23 <alltraps>

80105cb3 <vector226>:
.globl vector226
vector226:
  pushl $0
80105cb3:	6a 00                	push   $0x0
  pushl $226
80105cb5:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105cba:	e9 64 f2 ff ff       	jmp    80104f23 <alltraps>

80105cbf <vector227>:
.globl vector227
vector227:
  pushl $0
80105cbf:	6a 00                	push   $0x0
  pushl $227
80105cc1:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105cc6:	e9 58 f2 ff ff       	jmp    80104f23 <alltraps>

80105ccb <vector228>:
.globl vector228
vector228:
  pushl $0
80105ccb:	6a 00                	push   $0x0
  pushl $228
80105ccd:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105cd2:	e9 4c f2 ff ff       	jmp    80104f23 <alltraps>

80105cd7 <vector229>:
.globl vector229
vector229:
  pushl $0
80105cd7:	6a 00                	push   $0x0
  pushl $229
80105cd9:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105cde:	e9 40 f2 ff ff       	jmp    80104f23 <alltraps>

80105ce3 <vector230>:
.globl vector230
vector230:
  pushl $0
80105ce3:	6a 00                	push   $0x0
  pushl $230
80105ce5:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105cea:	e9 34 f2 ff ff       	jmp    80104f23 <alltraps>

80105cef <vector231>:
.globl vector231
vector231:
  pushl $0
80105cef:	6a 00                	push   $0x0
  pushl $231
80105cf1:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105cf6:	e9 28 f2 ff ff       	jmp    80104f23 <alltraps>

80105cfb <vector232>:
.globl vector232
vector232:
  pushl $0
80105cfb:	6a 00                	push   $0x0
  pushl $232
80105cfd:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105d02:	e9 1c f2 ff ff       	jmp    80104f23 <alltraps>

80105d07 <vector233>:
.globl vector233
vector233:
  pushl $0
80105d07:	6a 00                	push   $0x0
  pushl $233
80105d09:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105d0e:	e9 10 f2 ff ff       	jmp    80104f23 <alltraps>

80105d13 <vector234>:
.globl vector234
vector234:
  pushl $0
80105d13:	6a 00                	push   $0x0
  pushl $234
80105d15:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105d1a:	e9 04 f2 ff ff       	jmp    80104f23 <alltraps>

80105d1f <vector235>:
.globl vector235
vector235:
  pushl $0
80105d1f:	6a 00                	push   $0x0
  pushl $235
80105d21:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105d26:	e9 f8 f1 ff ff       	jmp    80104f23 <alltraps>

80105d2b <vector236>:
.globl vector236
vector236:
  pushl $0
80105d2b:	6a 00                	push   $0x0
  pushl $236
80105d2d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105d32:	e9 ec f1 ff ff       	jmp    80104f23 <alltraps>

80105d37 <vector237>:
.globl vector237
vector237:
  pushl $0
80105d37:	6a 00                	push   $0x0
  pushl $237
80105d39:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105d3e:	e9 e0 f1 ff ff       	jmp    80104f23 <alltraps>

80105d43 <vector238>:
.globl vector238
vector238:
  pushl $0
80105d43:	6a 00                	push   $0x0
  pushl $238
80105d45:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105d4a:	e9 d4 f1 ff ff       	jmp    80104f23 <alltraps>

80105d4f <vector239>:
.globl vector239
vector239:
  pushl $0
80105d4f:	6a 00                	push   $0x0
  pushl $239
80105d51:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105d56:	e9 c8 f1 ff ff       	jmp    80104f23 <alltraps>

80105d5b <vector240>:
.globl vector240
vector240:
  pushl $0
80105d5b:	6a 00                	push   $0x0
  pushl $240
80105d5d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105d62:	e9 bc f1 ff ff       	jmp    80104f23 <alltraps>

80105d67 <vector241>:
.globl vector241
vector241:
  pushl $0
80105d67:	6a 00                	push   $0x0
  pushl $241
80105d69:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105d6e:	e9 b0 f1 ff ff       	jmp    80104f23 <alltraps>

80105d73 <vector242>:
.globl vector242
vector242:
  pushl $0
80105d73:	6a 00                	push   $0x0
  pushl $242
80105d75:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105d7a:	e9 a4 f1 ff ff       	jmp    80104f23 <alltraps>

80105d7f <vector243>:
.globl vector243
vector243:
  pushl $0
80105d7f:	6a 00                	push   $0x0
  pushl $243
80105d81:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105d86:	e9 98 f1 ff ff       	jmp    80104f23 <alltraps>

80105d8b <vector244>:
.globl vector244
vector244:
  pushl $0
80105d8b:	6a 00                	push   $0x0
  pushl $244
80105d8d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105d92:	e9 8c f1 ff ff       	jmp    80104f23 <alltraps>

80105d97 <vector245>:
.globl vector245
vector245:
  pushl $0
80105d97:	6a 00                	push   $0x0
  pushl $245
80105d99:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105d9e:	e9 80 f1 ff ff       	jmp    80104f23 <alltraps>

80105da3 <vector246>:
.globl vector246
vector246:
  pushl $0
80105da3:	6a 00                	push   $0x0
  pushl $246
80105da5:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105daa:	e9 74 f1 ff ff       	jmp    80104f23 <alltraps>

80105daf <vector247>:
.globl vector247
vector247:
  pushl $0
80105daf:	6a 00                	push   $0x0
  pushl $247
80105db1:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105db6:	e9 68 f1 ff ff       	jmp    80104f23 <alltraps>

80105dbb <vector248>:
.globl vector248
vector248:
  pushl $0
80105dbb:	6a 00                	push   $0x0
  pushl $248
80105dbd:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105dc2:	e9 5c f1 ff ff       	jmp    80104f23 <alltraps>

80105dc7 <vector249>:
.globl vector249
vector249:
  pushl $0
80105dc7:	6a 00                	push   $0x0
  pushl $249
80105dc9:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105dce:	e9 50 f1 ff ff       	jmp    80104f23 <alltraps>

80105dd3 <vector250>:
.globl vector250
vector250:
  pushl $0
80105dd3:	6a 00                	push   $0x0
  pushl $250
80105dd5:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105dda:	e9 44 f1 ff ff       	jmp    80104f23 <alltraps>

80105ddf <vector251>:
.globl vector251
vector251:
  pushl $0
80105ddf:	6a 00                	push   $0x0
  pushl $251
80105de1:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105de6:	e9 38 f1 ff ff       	jmp    80104f23 <alltraps>

80105deb <vector252>:
.globl vector252
vector252:
  pushl $0
80105deb:	6a 00                	push   $0x0
  pushl $252
80105ded:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105df2:	e9 2c f1 ff ff       	jmp    80104f23 <alltraps>

80105df7 <vector253>:
.globl vector253
vector253:
  pushl $0
80105df7:	6a 00                	push   $0x0
  pushl $253
80105df9:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105dfe:	e9 20 f1 ff ff       	jmp    80104f23 <alltraps>

80105e03 <vector254>:
.globl vector254
vector254:
  pushl $0
80105e03:	6a 00                	push   $0x0
  pushl $254
80105e05:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105e0a:	e9 14 f1 ff ff       	jmp    80104f23 <alltraps>

80105e0f <vector255>:
.globl vector255
vector255:
  pushl $0
80105e0f:	6a 00                	push   $0x0
  pushl $255
80105e11:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105e16:	e9 08 f1 ff ff       	jmp    80104f23 <alltraps>

80105e1b <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80105e1b:	55                   	push   %ebp
80105e1c:	89 e5                	mov    %esp,%ebp
80105e1e:	57                   	push   %edi
80105e1f:	56                   	push   %esi
80105e20:	53                   	push   %ebx
80105e21:	83 ec 1c             	sub    $0x1c,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80105e24:	e8 6e d4 ff ff       	call   80103297 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105e29:	69 f8 b0 00 00 00    	imul   $0xb0,%eax,%edi
80105e2f:	66 c7 87 18 18 11 80 	movw   $0xffff,-0x7feee7e8(%edi)
80105e36:	ff ff 
80105e38:	66 c7 87 1a 18 11 80 	movw   $0x0,-0x7feee7e6(%edi)
80105e3f:	00 00 
80105e41:	c6 87 1c 18 11 80 00 	movb   $0x0,-0x7feee7e4(%edi)
80105e48:	0f b6 8f 1d 18 11 80 	movzbl -0x7feee7e3(%edi),%ecx
80105e4f:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e52:	89 ce                	mov    %ecx,%esi
80105e54:	83 ce 0a             	or     $0xa,%esi
80105e57:	89 f2                	mov    %esi,%edx
80105e59:	88 97 1d 18 11 80    	mov    %dl,-0x7feee7e3(%edi)
80105e5f:	83 c9 1a             	or     $0x1a,%ecx
80105e62:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105e68:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e6b:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105e71:	83 c9 80             	or     $0xffffff80,%ecx
80105e74:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105e7a:	0f b6 8f 1e 18 11 80 	movzbl -0x7feee7e2(%edi),%ecx
80105e81:	83 c9 0f             	or     $0xf,%ecx
80105e84:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105e8a:	89 ce                	mov    %ecx,%esi
80105e8c:	83 e6 ef             	and    $0xffffffef,%esi
80105e8f:	89 f2                	mov    %esi,%edx
80105e91:	88 97 1e 18 11 80    	mov    %dl,-0x7feee7e2(%edi)
80105e97:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e9a:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105ea0:	89 ce                	mov    %ecx,%esi
80105ea2:	83 ce 40             	or     $0x40,%esi
80105ea5:	89 f2                	mov    %esi,%edx
80105ea7:	88 97 1e 18 11 80    	mov    %dl,-0x7feee7e2(%edi)
80105ead:	83 c9 c0             	or     $0xffffffc0,%ecx
80105eb0:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105eb6:	c6 87 1f 18 11 80 00 	movb   $0x0,-0x7feee7e1(%edi)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105ebd:	66 c7 87 20 18 11 80 	movw   $0xffff,-0x7feee7e0(%edi)
80105ec4:	ff ff 
80105ec6:	66 c7 87 22 18 11 80 	movw   $0x0,-0x7feee7de(%edi)
80105ecd:	00 00 
80105ecf:	c6 87 24 18 11 80 00 	movb   $0x0,-0x7feee7dc(%edi)
80105ed6:	0f b6 8f 25 18 11 80 	movzbl -0x7feee7db(%edi),%ecx
80105edd:	83 e1 f0             	and    $0xfffffff0,%ecx
80105ee0:	89 ce                	mov    %ecx,%esi
80105ee2:	83 ce 02             	or     $0x2,%esi
80105ee5:	89 f2                	mov    %esi,%edx
80105ee7:	88 97 25 18 11 80    	mov    %dl,-0x7feee7db(%edi)
80105eed:	83 c9 12             	or     $0x12,%ecx
80105ef0:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105ef6:	83 e1 9f             	and    $0xffffff9f,%ecx
80105ef9:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105eff:	83 c9 80             	or     $0xffffff80,%ecx
80105f02:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105f08:	0f b6 8f 26 18 11 80 	movzbl -0x7feee7da(%edi),%ecx
80105f0f:	83 c9 0f             	or     $0xf,%ecx
80105f12:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80105f18:	89 ce                	mov    %ecx,%esi
80105f1a:	83 e6 ef             	and    $0xffffffef,%esi
80105f1d:	89 f2                	mov    %esi,%edx
80105f1f:	88 97 26 18 11 80    	mov    %dl,-0x7feee7da(%edi)
80105f25:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f28:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80105f2e:	89 ce                	mov    %ecx,%esi
80105f30:	83 ce 40             	or     $0x40,%esi
80105f33:	89 f2                	mov    %esi,%edx
80105f35:	88 97 26 18 11 80    	mov    %dl,-0x7feee7da(%edi)
80105f3b:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f3e:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80105f44:	c6 87 27 18 11 80 00 	movb   $0x0,-0x7feee7d9(%edi)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105f4b:	66 c7 87 28 18 11 80 	movw   $0xffff,-0x7feee7d8(%edi)
80105f52:	ff ff 
80105f54:	66 c7 87 2a 18 11 80 	movw   $0x0,-0x7feee7d6(%edi)
80105f5b:	00 00 
80105f5d:	c6 87 2c 18 11 80 00 	movb   $0x0,-0x7feee7d4(%edi)
80105f64:	0f b6 9f 2d 18 11 80 	movzbl -0x7feee7d3(%edi),%ebx
80105f6b:	83 e3 f0             	and    $0xfffffff0,%ebx
80105f6e:	89 de                	mov    %ebx,%esi
80105f70:	83 ce 0a             	or     $0xa,%esi
80105f73:	89 f2                	mov    %esi,%edx
80105f75:	88 97 2d 18 11 80    	mov    %dl,-0x7feee7d3(%edi)
80105f7b:	89 de                	mov    %ebx,%esi
80105f7d:	83 ce 1a             	or     $0x1a,%esi
80105f80:	89 f2                	mov    %esi,%edx
80105f82:	88 97 2d 18 11 80    	mov    %dl,-0x7feee7d3(%edi)
80105f88:	83 cb 7a             	or     $0x7a,%ebx
80105f8b:	88 9f 2d 18 11 80    	mov    %bl,-0x7feee7d3(%edi)
80105f91:	c6 87 2d 18 11 80 fa 	movb   $0xfa,-0x7feee7d3(%edi)
80105f98:	0f b6 9f 2e 18 11 80 	movzbl -0x7feee7d2(%edi),%ebx
80105f9f:	83 cb 0f             	or     $0xf,%ebx
80105fa2:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
80105fa8:	89 de                	mov    %ebx,%esi
80105faa:	83 e6 ef             	and    $0xffffffef,%esi
80105fad:	89 f2                	mov    %esi,%edx
80105faf:	88 97 2e 18 11 80    	mov    %dl,-0x7feee7d2(%edi)
80105fb5:	83 e3 cf             	and    $0xffffffcf,%ebx
80105fb8:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
80105fbe:	89 de                	mov    %ebx,%esi
80105fc0:	83 ce 40             	or     $0x40,%esi
80105fc3:	89 f2                	mov    %esi,%edx
80105fc5:	88 97 2e 18 11 80    	mov    %dl,-0x7feee7d2(%edi)
80105fcb:	83 cb c0             	or     $0xffffffc0,%ebx
80105fce:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
80105fd4:	c6 87 2f 18 11 80 00 	movb   $0x0,-0x7feee7d1(%edi)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105fdb:	66 c7 87 30 18 11 80 	movw   $0xffff,-0x7feee7d0(%edi)
80105fe2:	ff ff 
80105fe4:	66 c7 87 32 18 11 80 	movw   $0x0,-0x7feee7ce(%edi)
80105feb:	00 00 
80105fed:	c6 87 34 18 11 80 00 	movb   $0x0,-0x7feee7cc(%edi)
80105ff4:	0f b6 9f 35 18 11 80 	movzbl -0x7feee7cb(%edi),%ebx
80105ffb:	83 e3 f0             	and    $0xfffffff0,%ebx
80105ffe:	89 de                	mov    %ebx,%esi
80106000:	83 ce 02             	or     $0x2,%esi
80106003:	89 f2                	mov    %esi,%edx
80106005:	88 97 35 18 11 80    	mov    %dl,-0x7feee7cb(%edi)
8010600b:	89 de                	mov    %ebx,%esi
8010600d:	83 ce 12             	or     $0x12,%esi
80106010:	89 f2                	mov    %esi,%edx
80106012:	88 97 35 18 11 80    	mov    %dl,-0x7feee7cb(%edi)
80106018:	83 cb 72             	or     $0x72,%ebx
8010601b:	88 9f 35 18 11 80    	mov    %bl,-0x7feee7cb(%edi)
80106021:	c6 87 35 18 11 80 f2 	movb   $0xf2,-0x7feee7cb(%edi)
80106028:	0f b6 9f 36 18 11 80 	movzbl -0x7feee7ca(%edi),%ebx
8010602f:	83 cb 0f             	or     $0xf,%ebx
80106032:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80106038:	89 de                	mov    %ebx,%esi
8010603a:	83 e6 ef             	and    $0xffffffef,%esi
8010603d:	89 f2                	mov    %esi,%edx
8010603f:	88 97 36 18 11 80    	mov    %dl,-0x7feee7ca(%edi)
80106045:	83 e3 cf             	and    $0xffffffcf,%ebx
80106048:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
8010604e:	89 de                	mov    %ebx,%esi
80106050:	83 ce 40             	or     $0x40,%esi
80106053:	89 f2                	mov    %esi,%edx
80106055:	88 97 36 18 11 80    	mov    %dl,-0x7feee7ca(%edi)
8010605b:	83 cb c0             	or     $0xffffffc0,%ebx
8010605e:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80106064:	c6 87 37 18 11 80 00 	movb   $0x0,-0x7feee7c9(%edi)
  lgdt(c->gdt, sizeof(c->gdt));
8010606b:	8d 97 10 18 11 80    	lea    -0x7feee7f0(%edi),%edx
  pd[0] = size-1;
80106071:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
80106077:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
8010607b:	c1 ea 10             	shr    $0x10,%edx
8010607e:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106082:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106085:	0f 01 10             	lgdtl  (%eax)
}
80106088:	83 c4 1c             	add    $0x1c,%esp
8010608b:	5b                   	pop    %ebx
8010608c:	5e                   	pop    %esi
8010608d:	5f                   	pop    %edi
8010608e:	5d                   	pop    %ebp
8010608f:	c3                   	ret    

80106090 <walkpgdir>:

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t* walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106090:	55                   	push   %ebp
80106091:	89 e5                	mov    %esp,%ebp
80106093:	57                   	push   %edi
80106094:	56                   	push   %esi
80106095:	53                   	push   %ebx
80106096:	83 ec 0c             	sub    $0xc,%esp
80106099:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010609c:	89 fe                	mov    %edi,%esi
8010609e:	c1 ee 16             	shr    $0x16,%esi
801060a1:	c1 e6 02             	shl    $0x2,%esi
801060a4:	03 75 08             	add    0x8(%ebp),%esi
  if(*pde & PTE_P){
801060a7:	8b 1e                	mov    (%esi),%ebx
801060a9:	f6 c3 01             	test   $0x1,%bl
801060ac:	74 35                	je     801060e3 <walkpgdir+0x53>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
801060ae:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (a > KERNBASE)
801060b4:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
801060ba:	77 1a                	ja     801060d6 <walkpgdir+0x46>
    return (char*)a + KERNBASE;
801060bc:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
801060c2:	c1 ef 0c             	shr    $0xc,%edi
801060c5:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
801060cb:	8d 04 bb             	lea    (%ebx,%edi,4),%eax
}
801060ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060d1:	5b                   	pop    %ebx
801060d2:	5e                   	pop    %esi
801060d3:	5f                   	pop    %edi
801060d4:	5d                   	pop    %ebp
801060d5:	c3                   	ret    
        panic("P2V on address > KERNBASE");
801060d6:	83 ec 0c             	sub    $0xc,%esp
801060d9:	68 d8 6e 10 80       	push   $0x80106ed8
801060de:	e8 65 a2 ff ff       	call   80100348 <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801060e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801060e7:	74 33                	je     8010611c <walkpgdir+0x8c>
801060e9:	e8 db bf ff ff       	call   801020c9 <kalloc>
801060ee:	89 c3                	mov    %eax,%ebx
801060f0:	85 c0                	test   %eax,%eax
801060f2:	74 28                	je     8010611c <walkpgdir+0x8c>
    memset(pgtab, 0, PGSIZE);
801060f4:	83 ec 04             	sub    $0x4,%esp
801060f7:	68 00 10 00 00       	push   $0x1000
801060fc:	6a 00                	push   $0x0
801060fe:	50                   	push   %eax
801060ff:	e8 b6 dd ff ff       	call   80103eba <memset>
    if (a < (void*) KERNBASE)
80106104:	83 c4 10             	add    $0x10,%esp
80106107:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
8010610d:	76 14                	jbe    80106123 <walkpgdir+0x93>
    return (uint)a - KERNBASE;
8010610f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106115:	83 c8 07             	or     $0x7,%eax
80106118:	89 06                	mov    %eax,(%esi)
8010611a:	eb a6                	jmp    801060c2 <walkpgdir+0x32>
      return 0;
8010611c:	b8 00 00 00 00       	mov    $0x0,%eax
80106121:	eb ab                	jmp    801060ce <walkpgdir+0x3e>
        panic("V2P on address < KERNBASE "
80106123:	83 ec 0c             	sub    $0xc,%esp
80106126:	68 a8 6b 10 80       	push   $0x80106ba8
8010612b:	e8 18 a2 ff ff       	call   80100348 <panic>

80106130 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106130:	55                   	push   %ebp
80106131:	89 e5                	mov    %esp,%ebp
80106133:	57                   	push   %edi
80106134:	56                   	push   %esi
80106135:	53                   	push   %ebx
80106136:	83 ec 1c             	sub    $0x1c,%esp
80106139:	89 c7                	mov    %eax,%edi
8010613b:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010613e:	89 d3                	mov    %edx,%ebx
80106140:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106146:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
8010614a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010614f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106152:	83 ec 04             	sub    $0x4,%esp
80106155:	6a 01                	push   $0x1
80106157:	53                   	push   %ebx
80106158:	57                   	push   %edi
80106159:	e8 32 ff ff ff       	call   80106090 <walkpgdir>
8010615e:	83 c4 10             	add    $0x10,%esp
80106161:	85 c0                	test   %eax,%eax
80106163:	74 2f                	je     80106194 <mappages+0x64>
      return -1;
    if(*pte & PTE_P)
80106165:	f6 00 01             	testb  $0x1,(%eax)
80106168:	75 1d                	jne    80106187 <mappages+0x57>
      panic("remap");
    *pte = pa | perm | PTE_P;
8010616a:	89 f2                	mov    %esi,%edx
8010616c:	0b 55 0c             	or     0xc(%ebp),%edx
8010616f:	83 ca 01             	or     $0x1,%edx
80106172:	89 10                	mov    %edx,(%eax)
    if(a == last)
80106174:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80106177:	74 28                	je     801061a1 <mappages+0x71>
      break;
    a += PGSIZE;
80106179:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
8010617f:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106185:	eb cb                	jmp    80106152 <mappages+0x22>
      panic("remap");
80106187:	83 ec 0c             	sub    $0xc,%esp
8010618a:	68 fc 72 10 80       	push   $0x801072fc
8010618f:	e8 b4 a1 ff ff       	call   80100348 <panic>
      return -1;
80106194:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80106199:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010619c:	5b                   	pop    %ebx
8010619d:	5e                   	pop    %esi
8010619e:	5f                   	pop    %edi
8010619f:	5d                   	pop    %ebp
801061a0:	c3                   	ret    
  return 0;
801061a1:	b8 00 00 00 00       	mov    $0x0,%eax
801061a6:	eb f1                	jmp    80106199 <mappages+0x69>

801061a8 <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801061a8:	a1 c4 44 11 80       	mov    0x801144c4,%eax
    if (a < (void*) KERNBASE)
801061ad:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801061b2:	76 09                	jbe    801061bd <switchkvm+0x15>
    return (uint)a - KERNBASE;
801061b4:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801061b9:	0f 22 d8             	mov    %eax,%cr3
801061bc:	c3                   	ret    
{
801061bd:	55                   	push   %ebp
801061be:	89 e5                	mov    %esp,%ebp
801061c0:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
801061c3:	68 a8 6b 10 80       	push   $0x80106ba8
801061c8:	e8 7b a1 ff ff       	call   80100348 <panic>

801061cd <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801061cd:	55                   	push   %ebp
801061ce:	89 e5                	mov    %esp,%ebp
801061d0:	57                   	push   %edi
801061d1:	56                   	push   %esi
801061d2:	53                   	push   %ebx
801061d3:	83 ec 1c             	sub    $0x1c,%esp
801061d6:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801061d9:	85 f6                	test   %esi,%esi
801061db:	0f 84 2c 01 00 00    	je     8010630d <switchuvm+0x140>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801061e1:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
801061e5:	0f 84 2f 01 00 00    	je     8010631a <switchuvm+0x14d>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801061eb:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
801061ef:	0f 84 32 01 00 00    	je     80106327 <switchuvm+0x15a>
    panic("switchuvm: no pgdir");

  pushcli();
801061f5:	e8 39 db ff ff       	call   80103d33 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801061fa:	e8 3c d0 ff ff       	call   8010323b <mycpu>
801061ff:	89 c3                	mov    %eax,%ebx
80106201:	e8 35 d0 ff ff       	call   8010323b <mycpu>
80106206:	8d 78 08             	lea    0x8(%eax),%edi
80106209:	e8 2d d0 ff ff       	call   8010323b <mycpu>
8010620e:	83 c0 08             	add    $0x8,%eax
80106211:	c1 e8 10             	shr    $0x10,%eax
80106214:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106217:	e8 1f d0 ff ff       	call   8010323b <mycpu>
8010621c:	83 c0 08             	add    $0x8,%eax
8010621f:	c1 e8 18             	shr    $0x18,%eax
80106222:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106229:	67 00 
8010622b:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106232:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106236:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
8010623c:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106243:	83 e2 f0             	and    $0xfffffff0,%edx
80106246:	89 d1                	mov    %edx,%ecx
80106248:	83 c9 09             	or     $0x9,%ecx
8010624b:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
80106251:	83 ca 19             	or     $0x19,%edx
80106254:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010625a:	83 e2 9f             	and    $0xffffff9f,%edx
8010625d:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106263:	83 ca 80             	or     $0xffffff80,%edx
80106266:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010626c:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80106273:	89 d1                	mov    %edx,%ecx
80106275:	83 e1 f0             	and    $0xfffffff0,%ecx
80106278:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
8010627e:	89 d1                	mov    %edx,%ecx
80106280:	83 e1 e0             	and    $0xffffffe0,%ecx
80106283:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106289:	83 e2 c0             	and    $0xffffffc0,%edx
8010628c:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106292:	83 ca 40             	or     $0x40,%edx
80106295:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010629b:	83 e2 7f             	and    $0x7f,%edx
8010629e:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801062a4:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801062aa:	e8 8c cf ff ff       	call   8010323b <mycpu>
801062af:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801062b6:	83 e2 ef             	and    $0xffffffef,%edx
801062b9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801062bf:	e8 77 cf ff ff       	call   8010323b <mycpu>
801062c4:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801062ca:	8b 5e 08             	mov    0x8(%esi),%ebx
801062cd:	e8 69 cf ff ff       	call   8010323b <mycpu>
801062d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062d8:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801062db:	e8 5b cf ff ff       	call   8010323b <mycpu>
801062e0:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801062e6:	b8 28 00 00 00       	mov    $0x28,%eax
801062eb:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801062ee:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
801062f1:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801062f6:	76 3c                	jbe    80106334 <switchuvm+0x167>
    return (uint)a - KERNBASE;
801062f8:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801062fd:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106300:	e8 6a da ff ff       	call   80103d6f <popcli>
}
80106305:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106308:	5b                   	pop    %ebx
80106309:	5e                   	pop    %esi
8010630a:	5f                   	pop    %edi
8010630b:	5d                   	pop    %ebp
8010630c:	c3                   	ret    
    panic("switchuvm: no process");
8010630d:	83 ec 0c             	sub    $0xc,%esp
80106310:	68 02 73 10 80       	push   $0x80107302
80106315:	e8 2e a0 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
8010631a:	83 ec 0c             	sub    $0xc,%esp
8010631d:	68 18 73 10 80       	push   $0x80107318
80106322:	e8 21 a0 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80106327:	83 ec 0c             	sub    $0xc,%esp
8010632a:	68 2d 73 10 80       	push   $0x8010732d
8010632f:	e8 14 a0 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106334:	83 ec 0c             	sub    $0xc,%esp
80106337:	68 a8 6b 10 80       	push   $0x80106ba8
8010633c:	e8 07 a0 ff ff       	call   80100348 <panic>

80106341 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106341:	55                   	push   %ebp
80106342:	89 e5                	mov    %esp,%ebp
80106344:	56                   	push   %esi
80106345:	53                   	push   %ebx
80106346:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80106349:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010634f:	77 57                	ja     801063a8 <inituvm+0x67>
    panic("inituvm: more than a page");
  mem = kalloc();
80106351:	e8 73 bd ff ff       	call   801020c9 <kalloc>
80106356:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106358:	83 ec 04             	sub    $0x4,%esp
8010635b:	68 00 10 00 00       	push   $0x1000
80106360:	6a 00                	push   $0x0
80106362:	50                   	push   %eax
80106363:	e8 52 db ff ff       	call   80103eba <memset>
    if (a < (void*) KERNBASE)
80106368:	83 c4 10             	add    $0x10,%esp
8010636b:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106371:	76 42                	jbe    801063b5 <inituvm+0x74>
    return (uint)a - KERNBASE;
80106373:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106379:	83 ec 08             	sub    $0x8,%esp
8010637c:	6a 06                	push   $0x6
8010637e:	50                   	push   %eax
8010637f:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106384:	ba 00 00 00 00       	mov    $0x0,%edx
80106389:	8b 45 08             	mov    0x8(%ebp),%eax
8010638c:	e8 9f fd ff ff       	call   80106130 <mappages>
  memmove(mem, init, sz);
80106391:	83 c4 0c             	add    $0xc,%esp
80106394:	56                   	push   %esi
80106395:	ff 75 0c             	push   0xc(%ebp)
80106398:	53                   	push   %ebx
80106399:	e8 94 db ff ff       	call   80103f32 <memmove>
}
8010639e:	83 c4 10             	add    $0x10,%esp
801063a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801063a4:	5b                   	pop    %ebx
801063a5:	5e                   	pop    %esi
801063a6:	5d                   	pop    %ebp
801063a7:	c3                   	ret    
    panic("inituvm: more than a page");
801063a8:	83 ec 0c             	sub    $0xc,%esp
801063ab:	68 41 73 10 80       	push   $0x80107341
801063b0:	e8 93 9f ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
801063b5:	83 ec 0c             	sub    $0xc,%esp
801063b8:	68 a8 6b 10 80       	push   $0x80106ba8
801063bd:	e8 86 9f ff ff       	call   80100348 <panic>

801063c2 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801063c2:	55                   	push   %ebp
801063c3:	89 e5                	mov    %esp,%ebp
801063c5:	57                   	push   %edi
801063c6:	56                   	push   %esi
801063c7:	53                   	push   %ebx
801063c8:	83 ec 0c             	sub    $0xc,%esp
801063cb:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801063ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801063d1:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801063d7:	74 43                	je     8010641c <loaduvm+0x5a>
    panic("loaduvm: addr must be page aligned");
801063d9:	83 ec 0c             	sub    $0xc,%esp
801063dc:	68 fc 73 10 80       	push   $0x801073fc
801063e1:	e8 62 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801063e6:	83 ec 0c             	sub    $0xc,%esp
801063e9:	68 5b 73 10 80       	push   $0x8010735b
801063ee:	e8 55 9f ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801063f3:	89 da                	mov    %ebx,%edx
801063f5:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
801063f8:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801063fd:	77 55                	ja     80106454 <loaduvm+0x92>
    return (char*)a + KERNBASE;
801063ff:	05 00 00 00 80       	add    $0x80000000,%eax
80106404:	56                   	push   %esi
80106405:	52                   	push   %edx
80106406:	50                   	push   %eax
80106407:	ff 75 10             	push   0x10(%ebp)
8010640a:	e8 52 b3 ff ff       	call   80101761 <readi>
8010640f:	83 c4 10             	add    $0x10,%esp
80106412:	39 f0                	cmp    %esi,%eax
80106414:	75 58                	jne    8010646e <loaduvm+0xac>
  for(i = 0; i < sz; i += PGSIZE){
80106416:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010641c:	39 fb                	cmp    %edi,%ebx
8010641e:	73 41                	jae    80106461 <loaduvm+0x9f>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106420:	89 d8                	mov    %ebx,%eax
80106422:	03 45 0c             	add    0xc(%ebp),%eax
80106425:	83 ec 04             	sub    $0x4,%esp
80106428:	6a 00                	push   $0x0
8010642a:	50                   	push   %eax
8010642b:	ff 75 08             	push   0x8(%ebp)
8010642e:	e8 5d fc ff ff       	call   80106090 <walkpgdir>
80106433:	83 c4 10             	add    $0x10,%esp
80106436:	85 c0                	test   %eax,%eax
80106438:	74 ac                	je     801063e6 <loaduvm+0x24>
    pa = PTE_ADDR(*pte);
8010643a:	8b 00                	mov    (%eax),%eax
8010643c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106441:	89 fe                	mov    %edi,%esi
80106443:	29 de                	sub    %ebx,%esi
80106445:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010644b:	76 a6                	jbe    801063f3 <loaduvm+0x31>
      n = PGSIZE;
8010644d:	be 00 10 00 00       	mov    $0x1000,%esi
80106452:	eb 9f                	jmp    801063f3 <loaduvm+0x31>
        panic("P2V on address > KERNBASE");
80106454:	83 ec 0c             	sub    $0xc,%esp
80106457:	68 d8 6e 10 80       	push   $0x80106ed8
8010645c:	e8 e7 9e ff ff       	call   80100348 <panic>
      return -1;
  }
  return 0;
80106461:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106466:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106469:	5b                   	pop    %ebx
8010646a:	5e                   	pop    %esi
8010646b:	5f                   	pop    %edi
8010646c:	5d                   	pop    %ebp
8010646d:	c3                   	ret    
      return -1;
8010646e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106473:	eb f1                	jmp    80106466 <loaduvm+0xa4>

80106475 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106475:	55                   	push   %ebp
80106476:	89 e5                	mov    %esp,%ebp
80106478:	57                   	push   %edi
80106479:	56                   	push   %esi
8010647a:	53                   	push   %ebx
8010647b:	83 ec 0c             	sub    $0xc,%esp
8010647e:	8b 7d 08             	mov    0x8(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106481:	8b 45 0c             	mov    0xc(%ebp),%eax
80106484:	39 45 10             	cmp    %eax,0x10(%ebp)
80106487:	0f 83 8a 00 00 00    	jae    80106517 <deallocuvm+0xa2>
    return oldsz;

  a = PGROUNDUP(newsz);
8010648d:	8b 45 10             	mov    0x10(%ebp),%eax
80106490:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106496:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010649c:	eb 15                	jmp    801064b3 <deallocuvm+0x3e>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010649e:	c1 eb 16             	shr    $0x16,%ebx
801064a1:	83 c3 01             	add    $0x1,%ebx
801064a4:	c1 e3 16             	shl    $0x16,%ebx
801064a7:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801064ad:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801064b3:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
801064b6:	73 5c                	jae    80106514 <deallocuvm+0x9f>
    pte = walkpgdir(pgdir, (char*)a, 0);
801064b8:	83 ec 04             	sub    $0x4,%esp
801064bb:	6a 00                	push   $0x0
801064bd:	53                   	push   %ebx
801064be:	57                   	push   %edi
801064bf:	e8 cc fb ff ff       	call   80106090 <walkpgdir>
801064c4:	89 c6                	mov    %eax,%esi
    if(!pte)
801064c6:	83 c4 10             	add    $0x10,%esp
801064c9:	85 c0                	test   %eax,%eax
801064cb:	74 d1                	je     8010649e <deallocuvm+0x29>
    else if((*pte & PTE_P) != 0){
801064cd:	8b 00                	mov    (%eax),%eax
801064cf:	a8 01                	test   $0x1,%al
801064d1:	74 da                	je     801064ad <deallocuvm+0x38>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
801064d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064d8:	74 20                	je     801064fa <deallocuvm+0x85>
    if (a > KERNBASE)
801064da:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801064df:	77 26                	ja     80106507 <deallocuvm+0x92>
    return (char*)a + KERNBASE;
801064e1:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
801064e6:	83 ec 0c             	sub    $0xc,%esp
801064e9:	50                   	push   %eax
801064ea:	e8 9d ba ff ff       	call   80101f8c <kfree>
      *pte = 0;
801064ef:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801064f5:	83 c4 10             	add    $0x10,%esp
801064f8:	eb b3                	jmp    801064ad <deallocuvm+0x38>
        panic("kfree");
801064fa:	83 ec 0c             	sub    $0xc,%esp
801064fd:	68 36 6c 10 80       	push   $0x80106c36
80106502:	e8 41 9e ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
80106507:	83 ec 0c             	sub    $0xc,%esp
8010650a:	68 d8 6e 10 80       	push   $0x80106ed8
8010650f:	e8 34 9e ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106514:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106517:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010651a:	5b                   	pop    %ebx
8010651b:	5e                   	pop    %esi
8010651c:	5f                   	pop    %edi
8010651d:	5d                   	pop    %ebp
8010651e:	c3                   	ret    

8010651f <allocuvm>:
{
8010651f:	55                   	push   %ebp
80106520:	89 e5                	mov    %esp,%ebp
80106522:	57                   	push   %edi
80106523:	56                   	push   %esi
80106524:	53                   	push   %ebx
80106525:	83 ec 1c             	sub    $0x1c,%esp
80106528:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
8010652b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010652e:	85 ff                	test   %edi,%edi
80106530:	0f 88 d9 00 00 00    	js     8010660f <allocuvm+0xf0>
  if(newsz < oldsz)
80106536:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106539:	72 67                	jb     801065a2 <allocuvm+0x83>
  a = PGROUNDUP(oldsz);
8010653b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010653e:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106544:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
8010654a:	39 fe                	cmp    %edi,%esi
8010654c:	0f 83 c4 00 00 00    	jae    80106616 <allocuvm+0xf7>
    mem = kalloc();
80106552:	e8 72 bb ff ff       	call   801020c9 <kalloc>
80106557:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106559:	85 c0                	test   %eax,%eax
8010655b:	74 4d                	je     801065aa <allocuvm+0x8b>
    memset(mem, 0, PGSIZE);
8010655d:	83 ec 04             	sub    $0x4,%esp
80106560:	68 00 10 00 00       	push   $0x1000
80106565:	6a 00                	push   $0x0
80106567:	50                   	push   %eax
80106568:	e8 4d d9 ff ff       	call   80103eba <memset>
    if (a < (void*) KERNBASE)
8010656d:	83 c4 10             	add    $0x10,%esp
80106570:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106576:	76 5a                	jbe    801065d2 <allocuvm+0xb3>
    return (uint)a - KERNBASE;
80106578:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010657e:	83 ec 08             	sub    $0x8,%esp
80106581:	6a 06                	push   $0x6
80106583:	50                   	push   %eax
80106584:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106589:	89 f2                	mov    %esi,%edx
8010658b:	8b 45 08             	mov    0x8(%ebp),%eax
8010658e:	e8 9d fb ff ff       	call   80106130 <mappages>
80106593:	83 c4 10             	add    $0x10,%esp
80106596:	85 c0                	test   %eax,%eax
80106598:	78 45                	js     801065df <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
8010659a:	81 c6 00 10 00 00    	add    $0x1000,%esi
801065a0:	eb a8                	jmp    8010654a <allocuvm+0x2b>
    return oldsz;
801065a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801065a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801065a8:	eb 6c                	jmp    80106616 <allocuvm+0xf7>
      cprintf("allocuvm out of memory\n");
801065aa:	83 ec 0c             	sub    $0xc,%esp
801065ad:	68 79 73 10 80       	push   $0x80107379
801065b2:	e8 50 a0 ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801065b7:	83 c4 0c             	add    $0xc,%esp
801065ba:	ff 75 0c             	push   0xc(%ebp)
801065bd:	57                   	push   %edi
801065be:	ff 75 08             	push   0x8(%ebp)
801065c1:	e8 af fe ff ff       	call   80106475 <deallocuvm>
      return 0;
801065c6:	83 c4 10             	add    $0x10,%esp
801065c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801065d0:	eb 44                	jmp    80106616 <allocuvm+0xf7>
        panic("V2P on address < KERNBASE "
801065d2:	83 ec 0c             	sub    $0xc,%esp
801065d5:	68 a8 6b 10 80       	push   $0x80106ba8
801065da:	e8 69 9d ff ff       	call   80100348 <panic>
      cprintf("allocuvm out of memory (2)\n");
801065df:	83 ec 0c             	sub    $0xc,%esp
801065e2:	68 91 73 10 80       	push   $0x80107391
801065e7:	e8 1b a0 ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801065ec:	83 c4 0c             	add    $0xc,%esp
801065ef:	ff 75 0c             	push   0xc(%ebp)
801065f2:	57                   	push   %edi
801065f3:	ff 75 08             	push   0x8(%ebp)
801065f6:	e8 7a fe ff ff       	call   80106475 <deallocuvm>
      kfree(mem);
801065fb:	89 1c 24             	mov    %ebx,(%esp)
801065fe:	e8 89 b9 ff ff       	call   80101f8c <kfree>
      return 0;
80106603:	83 c4 10             	add    $0x10,%esp
80106606:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010660d:	eb 07                	jmp    80106616 <allocuvm+0xf7>
    return 0;
8010660f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106616:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106619:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010661c:	5b                   	pop    %ebx
8010661d:	5e                   	pop    %esi
8010661e:	5f                   	pop    %edi
8010661f:	5d                   	pop    %ebp
80106620:	c3                   	ret    

80106621 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106621:	55                   	push   %ebp
80106622:	89 e5                	mov    %esp,%ebp
80106624:	56                   	push   %esi
80106625:	53                   	push   %ebx
80106626:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106629:	85 f6                	test   %esi,%esi
8010662b:	74 1a                	je     80106647 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010662d:	83 ec 04             	sub    $0x4,%esp
80106630:	6a 00                	push   $0x0
80106632:	68 00 00 00 80       	push   $0x80000000
80106637:	56                   	push   %esi
80106638:	e8 38 fe ff ff       	call   80106475 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010663d:	83 c4 10             	add    $0x10,%esp
80106640:	bb 00 00 00 00       	mov    $0x0,%ebx
80106645:	eb 21                	jmp    80106668 <freevm+0x47>
    panic("freevm: no pgdir");
80106647:	83 ec 0c             	sub    $0xc,%esp
8010664a:	68 ad 73 10 80       	push   $0x801073ad
8010664f:	e8 f4 9c ff ff       	call   80100348 <panic>
    return (char*)a + KERNBASE;
80106654:	05 00 00 00 80       	add    $0x80000000,%eax
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
80106659:	83 ec 0c             	sub    $0xc,%esp
8010665c:	50                   	push   %eax
8010665d:	e8 2a b9 ff ff       	call   80101f8c <kfree>
80106662:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80106665:	83 c3 01             	add    $0x1,%ebx
80106668:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
8010666e:	77 20                	ja     80106690 <freevm+0x6f>
    if(pgdir[i] & PTE_P){
80106670:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106673:	a8 01                	test   $0x1,%al
80106675:	74 ee                	je     80106665 <freevm+0x44>
80106677:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
8010667c:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106681:	76 d1                	jbe    80106654 <freevm+0x33>
        panic("P2V on address > KERNBASE");
80106683:	83 ec 0c             	sub    $0xc,%esp
80106686:	68 d8 6e 10 80       	push   $0x80106ed8
8010668b:	e8 b8 9c ff ff       	call   80100348 <panic>
    }
  }
  kfree((char*)pgdir);
80106690:	83 ec 0c             	sub    $0xc,%esp
80106693:	56                   	push   %esi
80106694:	e8 f3 b8 ff ff       	call   80101f8c <kfree>
}
80106699:	83 c4 10             	add    $0x10,%esp
8010669c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010669f:	5b                   	pop    %ebx
801066a0:	5e                   	pop    %esi
801066a1:	5d                   	pop    %ebp
801066a2:	c3                   	ret    

801066a3 <setupkvm>:
{
801066a3:	55                   	push   %ebp
801066a4:	89 e5                	mov    %esp,%ebp
801066a6:	56                   	push   %esi
801066a7:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801066a8:	e8 1c ba ff ff       	call   801020c9 <kalloc>
801066ad:	89 c6                	mov    %eax,%esi
801066af:	85 c0                	test   %eax,%eax
801066b1:	74 55                	je     80106708 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801066b3:	83 ec 04             	sub    $0x4,%esp
801066b6:	68 00 10 00 00       	push   $0x1000
801066bb:	6a 00                	push   $0x0
801066bd:	50                   	push   %eax
801066be:	e8 f7 d7 ff ff       	call   80103eba <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801066c3:	83 c4 10             	add    $0x10,%esp
801066c6:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
801066cb:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801066d1:	73 35                	jae    80106708 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
801066d3:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801066d6:	8b 4b 08             	mov    0x8(%ebx),%ecx
801066d9:	29 c1                	sub    %eax,%ecx
801066db:	83 ec 08             	sub    $0x8,%esp
801066de:	ff 73 0c             	push   0xc(%ebx)
801066e1:	50                   	push   %eax
801066e2:	8b 13                	mov    (%ebx),%edx
801066e4:	89 f0                	mov    %esi,%eax
801066e6:	e8 45 fa ff ff       	call   80106130 <mappages>
801066eb:	83 c4 10             	add    $0x10,%esp
801066ee:	85 c0                	test   %eax,%eax
801066f0:	78 05                	js     801066f7 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801066f2:	83 c3 10             	add    $0x10,%ebx
801066f5:	eb d4                	jmp    801066cb <setupkvm+0x28>
      freevm(pgdir);
801066f7:	83 ec 0c             	sub    $0xc,%esp
801066fa:	56                   	push   %esi
801066fb:	e8 21 ff ff ff       	call   80106621 <freevm>
      return 0;
80106700:	83 c4 10             	add    $0x10,%esp
80106703:	be 00 00 00 00       	mov    $0x0,%esi
}
80106708:	89 f0                	mov    %esi,%eax
8010670a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010670d:	5b                   	pop    %ebx
8010670e:	5e                   	pop    %esi
8010670f:	5d                   	pop    %ebp
80106710:	c3                   	ret    

80106711 <kvmalloc>:
{
80106711:	55                   	push   %ebp
80106712:	89 e5                	mov    %esp,%ebp
80106714:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106717:	e8 87 ff ff ff       	call   801066a3 <setupkvm>
8010671c:	a3 c4 44 11 80       	mov    %eax,0x801144c4
  switchkvm();
80106721:	e8 82 fa ff ff       	call   801061a8 <switchkvm>
}
80106726:	c9                   	leave  
80106727:	c3                   	ret    

80106728 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106728:	55                   	push   %ebp
80106729:	89 e5                	mov    %esp,%ebp
8010672b:	83 ec 0c             	sub    $0xc,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010672e:	6a 00                	push   $0x0
80106730:	ff 75 0c             	push   0xc(%ebp)
80106733:	ff 75 08             	push   0x8(%ebp)
80106736:	e8 55 f9 ff ff       	call   80106090 <walkpgdir>
  if(pte == 0)
8010673b:	83 c4 10             	add    $0x10,%esp
8010673e:	85 c0                	test   %eax,%eax
80106740:	74 05                	je     80106747 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106742:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106745:	c9                   	leave  
80106746:	c3                   	ret    
    panic("clearpteu");
80106747:	83 ec 0c             	sub    $0xc,%esp
8010674a:	68 be 73 10 80       	push   $0x801073be
8010674f:	e8 f4 9b ff ff       	call   80100348 <panic>

80106754 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106754:	55                   	push   %ebp
80106755:	89 e5                	mov    %esp,%ebp
80106757:	57                   	push   %edi
80106758:	56                   	push   %esi
80106759:	53                   	push   %ebx
8010675a:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010675d:	e8 41 ff ff ff       	call   801066a3 <setupkvm>
80106762:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106765:	85 c0                	test   %eax,%eax
80106767:	0f 84 f4 00 00 00    	je     80106861 <copyuvm+0x10d>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010676d:	bf 00 00 00 00       	mov    $0x0,%edi
80106772:	eb 3a                	jmp    801067ae <copyuvm+0x5a>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
80106774:	83 ec 0c             	sub    $0xc,%esp
80106777:	68 c8 73 10 80       	push   $0x801073c8
8010677c:	e8 c7 9b ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
80106781:	83 ec 0c             	sub    $0xc,%esp
80106784:	68 e2 73 10 80       	push   $0x801073e2
80106789:	e8 ba 9b ff ff       	call   80100348 <panic>
8010678e:	83 ec 0c             	sub    $0xc,%esp
80106791:	68 d8 6e 10 80       	push   $0x80106ed8
80106796:	e8 ad 9b ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
8010679b:	83 ec 0c             	sub    $0xc,%esp
8010679e:	68 a8 6b 10 80       	push   $0x80106ba8
801067a3:	e8 a0 9b ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801067a8:	81 c7 00 10 00 00    	add    $0x1000,%edi
801067ae:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801067b1:	0f 83 aa 00 00 00    	jae    80106861 <copyuvm+0x10d>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801067b7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801067ba:	83 ec 04             	sub    $0x4,%esp
801067bd:	6a 00                	push   $0x0
801067bf:	57                   	push   %edi
801067c0:	ff 75 08             	push   0x8(%ebp)
801067c3:	e8 c8 f8 ff ff       	call   80106090 <walkpgdir>
801067c8:	83 c4 10             	add    $0x10,%esp
801067cb:	85 c0                	test   %eax,%eax
801067cd:	74 a5                	je     80106774 <copyuvm+0x20>
    if(!(*pte & PTE_P))
801067cf:	8b 00                	mov    (%eax),%eax
801067d1:	a8 01                	test   $0x1,%al
801067d3:	74 ac                	je     80106781 <copyuvm+0x2d>
801067d5:	89 c6                	mov    %eax,%esi
801067d7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
801067dd:	25 ff 0f 00 00       	and    $0xfff,%eax
801067e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
801067e5:	e8 df b8 ff ff       	call   801020c9 <kalloc>
801067ea:	89 c3                	mov    %eax,%ebx
801067ec:	85 c0                	test   %eax,%eax
801067ee:	74 5c                	je     8010684c <copyuvm+0xf8>
    if (a > KERNBASE)
801067f0:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
801067f6:	77 96                	ja     8010678e <copyuvm+0x3a>
    return (char*)a + KERNBASE;
801067f8:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801067fe:	83 ec 04             	sub    $0x4,%esp
80106801:	68 00 10 00 00       	push   $0x1000
80106806:	56                   	push   %esi
80106807:	50                   	push   %eax
80106808:	e8 25 d7 ff ff       	call   80103f32 <memmove>
    if (a < (void*) KERNBASE)
8010680d:	83 c4 10             	add    $0x10,%esp
80106810:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106816:	76 83                	jbe    8010679b <copyuvm+0x47>
    return (uint)a - KERNBASE;
80106818:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010681e:	83 ec 08             	sub    $0x8,%esp
80106821:	ff 75 e0             	push   -0x20(%ebp)
80106824:	50                   	push   %eax
80106825:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010682a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010682d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106830:	e8 fb f8 ff ff       	call   80106130 <mappages>
80106835:	83 c4 10             	add    $0x10,%esp
80106838:	85 c0                	test   %eax,%eax
8010683a:	0f 89 68 ff ff ff    	jns    801067a8 <copyuvm+0x54>
      kfree(mem);
80106840:	83 ec 0c             	sub    $0xc,%esp
80106843:	53                   	push   %ebx
80106844:	e8 43 b7 ff ff       	call   80101f8c <kfree>
      goto bad;
80106849:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
8010684c:	83 ec 0c             	sub    $0xc,%esp
8010684f:	ff 75 dc             	push   -0x24(%ebp)
80106852:	e8 ca fd ff ff       	call   80106621 <freevm>
  return 0;
80106857:	83 c4 10             	add    $0x10,%esp
8010685a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106861:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106864:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106867:	5b                   	pop    %ebx
80106868:	5e                   	pop    %esi
80106869:	5f                   	pop    %edi
8010686a:	5d                   	pop    %ebp
8010686b:	c3                   	ret    

8010686c <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010686c:	55                   	push   %ebp
8010686d:	89 e5                	mov    %esp,%ebp
8010686f:	83 ec 0c             	sub    $0xc,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106872:	6a 00                	push   $0x0
80106874:	ff 75 0c             	push   0xc(%ebp)
80106877:	ff 75 08             	push   0x8(%ebp)
8010687a:	e8 11 f8 ff ff       	call   80106090 <walkpgdir>
  if((*pte & PTE_P) == 0)
8010687f:	8b 00                	mov    (%eax),%eax
80106881:	83 c4 10             	add    $0x10,%esp
80106884:	a8 01                	test   $0x1,%al
80106886:	74 24                	je     801068ac <uva2ka+0x40>
    return 0;
  if((*pte & PTE_U) == 0)
80106888:	a8 04                	test   $0x4,%al
8010688a:	74 27                	je     801068b3 <uva2ka+0x47>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
8010688c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106891:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106896:	77 07                	ja     8010689f <uva2ka+0x33>
    return (char*)a + KERNBASE;
80106898:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
8010689d:	c9                   	leave  
8010689e:	c3                   	ret    
        panic("P2V on address > KERNBASE");
8010689f:	83 ec 0c             	sub    $0xc,%esp
801068a2:	68 d8 6e 10 80       	push   $0x80106ed8
801068a7:	e8 9c 9a ff ff       	call   80100348 <panic>
    return 0;
801068ac:	b8 00 00 00 00       	mov    $0x0,%eax
801068b1:	eb ea                	jmp    8010689d <uva2ka+0x31>
    return 0;
801068b3:	b8 00 00 00 00       	mov    $0x0,%eax
801068b8:	eb e3                	jmp    8010689d <uva2ka+0x31>

801068ba <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801068ba:	55                   	push   %ebp
801068bb:	89 e5                	mov    %esp,%ebp
801068bd:	57                   	push   %edi
801068be:	56                   	push   %esi
801068bf:	53                   	push   %ebx
801068c0:	83 ec 0c             	sub    $0xc,%esp
801068c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801068c6:	eb 25                	jmp    801068ed <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801068c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801068cb:	29 f2                	sub    %esi,%edx
801068cd:	01 d0                	add    %edx,%eax
801068cf:	83 ec 04             	sub    $0x4,%esp
801068d2:	53                   	push   %ebx
801068d3:	ff 75 10             	push   0x10(%ebp)
801068d6:	50                   	push   %eax
801068d7:	e8 56 d6 ff ff       	call   80103f32 <memmove>
    len -= n;
801068dc:	29 df                	sub    %ebx,%edi
    buf += n;
801068de:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801068e1:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801068e7:	89 45 0c             	mov    %eax,0xc(%ebp)
801068ea:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801068ed:	85 ff                	test   %edi,%edi
801068ef:	74 2f                	je     80106920 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801068f1:	8b 75 0c             	mov    0xc(%ebp),%esi
801068f4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801068fa:	83 ec 08             	sub    $0x8,%esp
801068fd:	56                   	push   %esi
801068fe:	ff 75 08             	push   0x8(%ebp)
80106901:	e8 66 ff ff ff       	call   8010686c <uva2ka>
    if(pa0 == 0)
80106906:	83 c4 10             	add    $0x10,%esp
80106909:	85 c0                	test   %eax,%eax
8010690b:	74 20                	je     8010692d <copyout+0x73>
    n = PGSIZE - (va - va0);
8010690d:	89 f3                	mov    %esi,%ebx
8010690f:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106912:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106918:	39 df                	cmp    %ebx,%edi
8010691a:	73 ac                	jae    801068c8 <copyout+0xe>
      n = len;
8010691c:	89 fb                	mov    %edi,%ebx
8010691e:	eb a8                	jmp    801068c8 <copyout+0xe>
  }
  return 0;
80106920:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106925:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106928:	5b                   	pop    %ebx
80106929:	5e                   	pop    %esi
8010692a:	5f                   	pop    %edi
8010692b:	5d                   	pop    %ebp
8010692c:	c3                   	ret    
      return -1;
8010692d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106932:	eb f1                	jmp    80106925 <copyout+0x6b>
