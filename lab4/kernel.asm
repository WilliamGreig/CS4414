
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
80100028:	bc d0 55 11 80       	mov    $0x801155d0,%esp

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
80100046:	e8 c4 3b 00 00       	call   80103c0f <acquire>

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
8010007c:	e8 f3 3b 00 00       	call   80103c74 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 6f 39 00 00       	call   801039fb <acquiresleep>
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
801000ca:	e8 a5 3b 00 00       	call   80103c74 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 21 39 00 00       	call   801039fb <acquiresleep>
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
801000ea:	68 a0 67 10 80       	push   $0x801067a0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 b1 67 10 80       	push   $0x801067b1
80100100:	68 20 a5 10 80       	push   $0x8010a520
80100105:	e8 c9 39 00 00       	call   80103ad3 <initlock>
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
8010013a:	68 b8 67 10 80       	push   $0x801067b8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 80 38 00 00       	call   801039c8 <initsleeplock>
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
801001a8:	e8 d8 38 00 00       	call   80103a85 <holdingsleep>
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
801001cb:	68 bf 67 10 80       	push   $0x801067bf
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
801001e4:	e8 9c 38 00 00       	call   80103a85 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 51 38 00 00       	call   80103a4a <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100200:	e8 0a 3a 00 00       	call   80103c0f <acquire>
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
8010024c:	e8 23 3a 00 00       	call   80103c74 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 c6 67 10 80       	push   $0x801067c6
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
8010028a:	e8 80 39 00 00       	call   80103c0f <acquire>
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
801002bf:	e8 ff 33 00 00       	call   801036c3 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 ef 10 80       	push   $0x8010ef20
801002d1:	e8 9e 39 00 00       	call   80103c74 <release>
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
80100331:	e8 3e 39 00 00       	call   80103c74 <release>
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
80100363:	68 cd 67 10 80       	push   $0x801067cd
80100368:	e8 9a 02 00 00       	call   80100607 <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	push   0x8(%ebp)
80100373:	e8 8f 02 00 00       	call   80100607 <cprintf>
  cprintf("\n");
80100378:	c7 04 24 cf 71 10 80 	movl   $0x801071cf,(%esp)
8010037f:	e8 83 02 00 00       	call   80100607 <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 5a 37 00 00       	call   80103aee <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
801003a5:	68 e1 67 10 80       	push   $0x801067e1
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
80100492:	68 e5 67 10 80       	push   $0x801067e5
80100497:	e8 ac fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010049c:	83 ec 04             	sub    $0x4,%esp
8010049f:	68 60 0e 00 00       	push   $0xe60
801004a4:	68 a0 80 0b 80       	push   $0x800b80a0
801004a9:	68 00 80 0b 80       	push   $0x800b8000
801004ae:	e8 80 38 00 00       	call   80103d33 <memmove>
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
801004cd:	e8 e9 37 00 00       	call   80103cbb <memset>
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
801004fa:	e8 1e 4c 00 00       	call   8010511d <uartputc>
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
80100513:	e8 05 4c 00 00       	call   8010511d <uartputc>
80100518:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010051f:	e8 f9 4b 00 00       	call   8010511d <uartputc>
80100524:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010052b:	e8 ed 4b 00 00       	call   8010511d <uartputc>
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
80100568:	0f b6 92 10 68 10 80 	movzbl -0x7fef97f0(%edx),%edx
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
801005c6:	e8 44 36 00 00       	call   80103c0f <acquire>
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
801005ed:	e8 82 36 00 00       	call   80103c74 <release>
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
80100634:	e8 d6 35 00 00       	call   80103c0f <acquire>
80100639:	83 c4 10             	add    $0x10,%esp
8010063c:	eb de                	jmp    8010061c <cprintf+0x15>
    panic("null fmt");
8010063e:	83 ec 0c             	sub    $0xc,%esp
80100641:	68 ff 67 10 80       	push   $0x801067ff
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
801006cd:	bb f8 67 10 80       	mov    $0x801067f8,%ebx
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
80100729:	e8 46 35 00 00       	call   80103c74 <release>
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
80100744:	e8 c6 34 00 00       	call   80103c0f <acquire>
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
801007f2:	e8 31 30 00 00       	call   80103828 <wakeup>
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
8010086f:	e8 00 34 00 00       	call   80103c74 <release>
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
80100883:	e8 3d 30 00 00       	call   801038c5 <procdump>
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
80100890:	68 08 68 10 80       	push   $0x80106808
80100895:	68 20 ef 10 80       	push   $0x8010ef20
8010089a:	e8 34 32 00 00       	call   80103ad3 <initlock>

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
8010095a:	68 21 68 10 80       	push   $0x80106821
8010095f:	e8 a3 fc ff ff       	call   80100607 <cprintf>
    return -1;
80100964:	83 c4 10             	add    $0x10,%esp
80100967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096c:	eb dc                	jmp    8010094a <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
8010096e:	e8 91 5b 00 00       	call   80106504 <setupkvm>
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
80100a02:	e8 79 59 00 00       	call   80106380 <allocuvm>
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
80100a34:	e8 f2 57 00 00       	call   8010622b <loaduvm>
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
80100a71:	e8 0a 59 00 00       	call   80106380 <allocuvm>
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
80100a9c:	e8 e1 59 00 00       	call   80106482 <freevm>
80100aa1:	83 c4 10             	add    $0x10,%esp
80100aa4:	e9 83 fe ff ff       	jmp    8010092c <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aa9:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100aaf:	83 ec 08             	sub    $0x8,%esp
80100ab2:	50                   	push   %eax
80100ab3:	57                   	push   %edi
80100ab4:	e8 d0 5a 00 00       	call   80106589 <clearpteu>
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
80100ae6:	e8 79 33 00 00       	call   80103e64 <strlen>
80100aeb:	29 c6                	sub    %eax,%esi
80100aed:	83 ee 01             	sub    $0x1,%esi
80100af0:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100af3:	83 c4 04             	add    $0x4,%esp
80100af6:	ff 33                	push   (%ebx)
80100af8:	e8 67 33 00 00       	call   80103e64 <strlen>
80100afd:	83 c0 01             	add    $0x1,%eax
80100b00:	50                   	push   %eax
80100b01:	ff 33                	push   (%ebx)
80100b03:	56                   	push   %esi
80100b04:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100b0a:	e8 0a 5c 00 00       	call   80106719 <copyout>
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
80100b6a:	e8 aa 5b 00 00       	call   80106719 <copyout>
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
80100ba7:	e8 7b 32 00 00       	call   80103e27 <safestrcpy>
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
80100bd5:	e8 5c 54 00 00       	call   80106036 <switchuvm>
  freevm(oldpgdir);
80100bda:	89 1c 24             	mov    %ebx,(%esp)
80100bdd:	e8 a0 58 00 00       	call   80106482 <freevm>
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
80100c09:	68 2d 68 10 80       	push   $0x8010682d
80100c0e:	68 60 ef 10 80       	push   $0x8010ef60
80100c13:	e8 bb 2e 00 00       	call   80103ad3 <initlock>
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
80100c29:	e8 e1 2f 00 00       	call   80103c0f <acquire>
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
80100c58:	e8 17 30 00 00       	call   80103c74 <release>
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
80100c6f:	e8 00 30 00 00       	call   80103c74 <release>
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
80100c8d:	e8 7d 2f 00 00       	call   80103c0f <acquire>
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
80100caa:	e8 c5 2f 00 00       	call   80103c74 <release>
  return f;
}
80100caf:	89 d8                	mov    %ebx,%eax
80100cb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cb4:	c9                   	leave  
80100cb5:	c3                   	ret    
    panic("filedup");
80100cb6:	83 ec 0c             	sub    $0xc,%esp
80100cb9:	68 34 68 10 80       	push   $0x80106834
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
80100cd2:	e8 38 2f 00 00       	call   80103c0f <acquire>
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
80100d23:	e8 4c 2f 00 00       	call   80103c74 <release>

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
80100d55:	68 3c 68 10 80       	push   $0x8010683c
80100d5a:	e8 e9 f5 ff ff       	call   80100348 <panic>
    release(&ftable.lock);
80100d5f:	83 ec 0c             	sub    $0xc,%esp
80100d62:	68 60 ef 10 80       	push   $0x8010ef60
80100d67:	e8 08 2f 00 00       	call   80103c74 <release>
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
80100e44:	68 46 68 10 80       	push   $0x80106846
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
80100f0a:	68 4f 68 10 80       	push   $0x8010684f
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
80100f31:	68 55 68 10 80       	push   $0x80106855
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
80100f81:	e8 ad 2d 00 00       	call   80103d33 <memmove>
80100f86:	83 c4 10             	add    $0x10,%esp
80100f89:	eb 17                	jmp    80100fa2 <skipelem+0x60>
  else {
    memmove(name, s, len);
80100f8b:	83 ec 04             	sub    $0x4,%esp
80100f8e:	57                   	push   %edi
80100f8f:	50                   	push   %eax
80100f90:	56                   	push   %esi
80100f91:	e8 9d 2d 00 00       	call   80103d33 <memmove>
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
80100fd6:	e8 e0 2c 00 00       	call   80103cbb <memset>
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
8010105f:	68 5f 68 10 80       	push   $0x8010685f
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
80101116:	68 72 68 10 80       	push   $0x80106872
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
801011ed:	68 88 68 10 80       	push   $0x80106888
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
8010120a:	e8 00 2a 00 00       	call   80103c0f <acquire>
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
80101251:	e8 1e 2a 00 00       	call   80103c74 <release>
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
80101287:	e8 e8 29 00 00       	call   80103c74 <release>
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
8010129c:	68 9b 68 10 80       	push   $0x8010689b
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
801012c5:	e8 69 2a 00 00       	call   80103d33 <memmove>
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
801012e1:	68 ab 68 10 80       	push   $0x801068ab
801012e6:	68 60 f9 10 80       	push   $0x8010f960
801012eb:	e8 e3 27 00 00       	call   80103ad3 <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 b2 68 10 80       	push   $0x801068b2
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 a0 f9 10 80       	add    $0x8010f9a0,%eax
8010130f:	50                   	push   %eax
80101310:	e8 b3 26 00 00       	call   801039c8 <initsleeplock>
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
8010135a:	68 18 69 10 80       	push   $0x80106918
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
801013cd:	68 b8 68 10 80       	push   $0x801068b8
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 d7 28 00 00       	call   80103cbb <memset>
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
8010146e:	e8 c0 28 00 00       	call   80103d33 <memmove>
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
8010154e:	e8 bc 26 00 00       	call   80103c0f <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101563:	e8 0c 27 00 00       	call   80103c74 <release>
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
80101588:	e8 6e 24 00 00       	call   801039fb <acquiresleep>
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
801015a0:	68 ca 68 10 80       	push   $0x801068ca
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
80101602:	e8 2c 27 00 00       	call   80103d33 <memmove>
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
80101627:	68 d0 68 10 80       	push   $0x801068d0
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
80101644:	e8 3c 24 00 00       	call   80103a85 <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 eb 23 00 00       	call   80103a4a <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 df 68 10 80       	push   $0x801068df
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
80101686:	e8 70 23 00 00       	call   801039fb <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 a6 23 00 00       	call   80103a4a <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016ab:	e8 5f 25 00 00       	call   80103c0f <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016c0:	e8 af 25 00 00       	call   80103c74 <release>
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
801016d8:	e8 32 25 00 00       	call   80103c0f <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016e7:	e8 88 25 00 00       	call   80103c74 <release>
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
80101818:	e8 16 25 00 00       	call   80103d33 <memmove>
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
80101915:	e8 19 24 00 00       	call   80103d33 <memmove>
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
80101998:	e8 02 24 00 00       	call   80103d9f <strncmp>
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
801019bf:	68 e7 68 10 80       	push   $0x801068e7
801019c4:	e8 7f e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c9:	83 ec 0c             	sub    $0xc,%esp
801019cc:	68 f9 68 10 80       	push   $0x801068f9
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
80101b7e:	68 08 69 10 80       	push   $0x80106908
80101b83:	e8 c0 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b88:	83 ec 04             	sub    $0x4,%esp
80101b8b:	6a 0e                	push   $0xe
80101b8d:	57                   	push   %edi
80101b8e:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b91:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b94:	50                   	push   %eax
80101b95:	e8 44 22 00 00       	call   80103dde <strncpy>
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
80101bc3:	68 c8 6f 10 80       	push   $0x80106fc8
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
80101cc5:	68 6b 69 10 80       	push   $0x8010696b
80101cca:	e8 79 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101ccf:	83 ec 0c             	sub    $0xc,%esp
80101cd2:	68 74 69 10 80       	push   $0x80106974
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
80101cef:	68 86 69 10 80       	push   $0x80106986
80101cf4:	68 00 16 11 80       	push   $0x80111600
80101cf9:	e8 d5 1d 00 00       	call   80103ad3 <initlock>
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
80101d69:	e8 a1 1e 00 00       	call   80103c0f <acquire>

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
80101d98:	e8 8b 1a 00 00       	call   80103828 <wakeup>

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
80101db6:	e8 b9 1e 00 00       	call   80103c74 <release>
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
80101dcd:	e8 a2 1e 00 00       	call   80103c74 <release>
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
80101e05:	e8 7b 1c 00 00       	call   80103a85 <holdingsleep>
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
80101e32:	e8 d8 1d 00 00       	call   80103c0f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e37:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e3e:	83 c4 10             	add    $0x10,%esp
80101e41:	ba e4 15 11 80       	mov    $0x801115e4,%edx
80101e46:	eb 2a                	jmp    80101e72 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e48:	83 ec 0c             	sub    $0xc,%esp
80101e4b:	68 8a 69 10 80       	push   $0x8010698a
80101e50:	e8 f3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e55:	83 ec 0c             	sub    $0xc,%esp
80101e58:	68 a0 69 10 80       	push   $0x801069a0
80101e5d:	e8 e6 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e62:	83 ec 0c             	sub    $0xc,%esp
80101e65:	68 b5 69 10 80       	push   $0x801069b5
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
80101e94:	e8 2a 18 00 00       	call   801036c3 <sleep>
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
80101eae:	e8 c1 1d 00 00       	call   80103c74 <release>
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
80101f22:	68 d4 69 10 80       	push   $0x801069d4
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
80101f9e:	81 fb d0 55 11 80    	cmp    $0x801155d0,%ebx
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
80101fc6:	e8 f0 1c 00 00       	call   80103cbb <memset>

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
80101ff5:	68 08 6a 10 80       	push   $0x80106a08
80101ffa:	e8 49 e3 ff ff       	call   80100348 <panic>
    panic("kfree");
80101fff:	83 ec 0c             	sub    $0xc,%esp
80102002:	68 96 6a 10 80       	push   $0x80106a96
80102007:	e8 3c e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200c:	83 ec 0c             	sub    $0xc,%esp
8010200f:	68 40 16 11 80       	push   $0x80111640
80102014:	e8 f6 1b 00 00       	call   80103c0f <acquire>
80102019:	83 c4 10             	add    $0x10,%esp
8010201c:	eb b9                	jmp    80101fd7 <kfree+0x4b>
    release(&kmem.lock);
8010201e:	83 ec 0c             	sub    $0xc,%esp
80102021:	68 40 16 11 80       	push   $0x80111640
80102026:	e8 49 1c 00 00       	call   80103c74 <release>
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
8010204e:	68 9c 6a 10 80       	push   $0x80106a9c
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
8010207d:	68 a6 6a 10 80       	push   $0x80106aa6
80102082:	68 40 16 11 80       	push   $0x80111640
80102087:	e8 47 1a 00 00       	call   80103ad3 <initlock>
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
80102102:	e8 08 1b 00 00       	call   80103c0f <acquire>
80102107:	83 c4 10             	add    $0x10,%esp
8010210a:	eb cd                	jmp    801020d9 <kalloc+0x10>
    release(&kmem.lock);
8010210c:	83 ec 0c             	sub    $0xc,%esp
8010210f:	68 40 16 11 80       	push   $0x80111640
80102114:	e8 5b 1b 00 00       	call   80103c74 <release>
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
80102157:	0f b6 91 e0 6b 10 80 	movzbl -0x7fef9420(%ecx),%edx
8010215e:	0b 15 7c 16 11 80    	or     0x8011167c,%edx
80102164:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  shift ^= togglecode[data];
8010216a:	0f b6 81 e0 6a 10 80 	movzbl -0x7fef9520(%ecx),%eax
80102171:	31 c2                	xor    %eax,%edx
80102173:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
80102179:	89 d0                	mov    %edx,%eax
8010217b:	83 e0 03             	and    $0x3,%eax
8010217e:	8b 04 85 c0 6a 10 80 	mov    -0x7fef9540(,%eax,4),%eax
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
801021b7:	0f b6 81 e0 6b 10 80 	movzbl -0x7fef9420(%ecx),%eax
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
801024aa:	e8 4f 18 00 00       	call   80103cfe <memcmp>
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
80102605:	e8 29 17 00 00       	call   80103d33 <memmove>
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
80102704:	e8 2a 16 00 00       	call   80103d33 <memmove>
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
80102771:	68 e0 6c 10 80       	push   $0x80106ce0
80102776:	68 a0 16 11 80       	push   $0x801116a0
8010277b:	e8 53 13 00 00       	call   80103ad3 <initlock>
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
801027bb:	e8 4f 14 00 00       	call   80103c0f <acquire>
801027c0:	83 c4 10             	add    $0x10,%esp
801027c3:	eb 15                	jmp    801027da <begin_op+0x2a>
      sleep(&log, &log.lock);
801027c5:	83 ec 08             	sub    $0x8,%esp
801027c8:	68 a0 16 11 80       	push   $0x801116a0
801027cd:	68 a0 16 11 80       	push   $0x801116a0
801027d2:	e8 ec 0e 00 00       	call   801036c3 <sleep>
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
80102809:	e8 b5 0e 00 00       	call   801036c3 <sleep>
8010280e:	83 c4 10             	add    $0x10,%esp
80102811:	eb c7                	jmp    801027da <begin_op+0x2a>
      log.outstanding += 1;
80102813:	a3 dc 16 11 80       	mov    %eax,0x801116dc
      release(&log.lock);
80102818:	83 ec 0c             	sub    $0xc,%esp
8010281b:	68 a0 16 11 80       	push   $0x801116a0
80102820:	e8 4f 14 00 00       	call   80103c74 <release>
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
80102836:	e8 d4 13 00 00       	call   80103c0f <acquire>
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
80102870:	e8 ff 13 00 00       	call   80103c74 <release>
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
80102884:	68 e4 6c 10 80       	push   $0x80106ce4
80102889:	e8 ba da ff ff       	call   80100348 <panic>
    wakeup(&log);
8010288e:	83 ec 0c             	sub    $0xc,%esp
80102891:	68 a0 16 11 80       	push   $0x801116a0
80102896:	e8 8d 0f 00 00       	call   80103828 <wakeup>
8010289b:	83 c4 10             	add    $0x10,%esp
8010289e:	eb c8                	jmp    80102868 <end_op+0x3e>
    commit();
801028a0:	e8 92 fe ff ff       	call   80102737 <commit>
    acquire(&log.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 a0 16 11 80       	push   $0x801116a0
801028ad:	e8 5d 13 00 00       	call   80103c0f <acquire>
    log.committing = 0;
801028b2:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
801028b9:	00 00 00 
    wakeup(&log);
801028bc:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801028c3:	e8 60 0f 00 00       	call   80103828 <wakeup>
    release(&log.lock);
801028c8:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801028cf:	e8 a0 13 00 00       	call   80103c74 <release>
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
8010290b:	e8 ff 12 00 00       	call   80103c0f <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102910:	83 c4 10             	add    $0x10,%esp
80102913:	b8 00 00 00 00       	mov    $0x0,%eax
80102918:	eb 1d                	jmp    80102937 <log_write+0x5e>
    panic("too big a transaction");
8010291a:	83 ec 0c             	sub    $0xc,%esp
8010291d:	68 f3 6c 10 80       	push   $0x80106cf3
80102922:	e8 21 da ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102927:	83 ec 0c             	sub    $0xc,%esp
8010292a:	68 09 6d 10 80       	push   $0x80106d09
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
80102966:	e8 09 13 00 00       	call   80103c74 <release>
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
80102994:	e8 9a 13 00 00       	call   80103d33 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102999:	83 c4 10             	add    $0x10,%esp
8010299c:	bb a0 17 11 80       	mov    $0x801117a0,%ebx
801029a1:	eb 13                	jmp    801029b6 <startothers+0x38>
801029a3:	83 ec 0c             	sub    $0xc,%esp
801029a6:	68 08 6a 10 80       	push   $0x80106a08
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
80102a3e:	68 24 6d 10 80       	push   $0x80106d24
80102a43:	e8 bf db ff ff       	call   80100607 <cprintf>
  idtinit();       // load idt register
80102a48:	e8 6e 24 00 00       	call   80104ebb <idtinit>
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
80102a60:	e8 39 0a 00 00       	call   8010349e <scheduler>

80102a65 <mpenter>:
{
80102a65:	55                   	push   %ebp
80102a66:	89 e5                	mov    %esp,%ebp
80102a68:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a6b:	e8 a1 35 00 00       	call   80106011 <switchkvm>
  seginit();
80102a70:	e8 27 33 00 00       	call   80105d9c <seginit>
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
80102a95:	68 d0 55 11 80       	push   $0x801155d0
80102a9a:	e8 d8 f5 ff ff       	call   80102077 <kinit1>
  kvmalloc();      // kernel page table
80102a9f:	e8 ce 3a 00 00       	call   80106572 <kvmalloc>
  mpinit();        // detect other processors
80102aa4:	e8 db 01 00 00       	call   80102c84 <mpinit>
  lapicinit();     // interrupt controller
80102aa9:	e8 d8 f7 ff ff       	call   80102286 <lapicinit>
  seginit();       // segment descriptors
80102aae:	e8 e9 32 00 00       	call   80105d9c <seginit>
  picinit();       // disable pic
80102ab3:	e8 a2 02 00 00       	call   80102d5a <picinit>
  ioapicinit();    // another interrupt controller
80102ab8:	e8 20 f4 ff ff       	call   80101edd <ioapicinit>
  consoleinit();   // console hardware
80102abd:	e8 c8 dd ff ff       	call   8010088a <consoleinit>
  uartinit();      // serial port
80102ac2:	e8 9b 26 00 00       	call   80105162 <uartinit>
  pinit();         // process table
80102ac7:	e8 bd 06 00 00       	call   80103189 <pinit>
  tvinit();        // trap vectors
80102acc:	e8 e5 22 00 00       	call   80104db6 <tvinit>
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
80102b3f:	68 38 6d 10 80       	push   $0x80106d38
80102b44:	e8 ff d7 ff ff       	call   80100348 <panic>
80102b49:	83 c3 10             	add    $0x10,%ebx
80102b4c:	39 f3                	cmp    %esi,%ebx
80102b4e:	73 29                	jae    80102b79 <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b50:	83 ec 04             	sub    $0x4,%esp
80102b53:	6a 04                	push   $0x4
80102b55:	68 52 6d 10 80       	push   $0x80106d52
80102b5a:	53                   	push   %ebx
80102b5b:	e8 9e 11 00 00       	call   80103cfe <memcmp>
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
80102c1f:	68 57 6d 10 80       	push   $0x80106d57
80102c24:	53                   	push   %ebx
80102c25:	e8 d4 10 00 00       	call   80103cfe <memcmp>
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
80102c61:	68 38 6d 10 80       	push   $0x80106d38
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
80102cb5:	68 5c 6d 10 80       	push   $0x80106d5c
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
80102d50:	68 74 6d 10 80       	push   $0x80106d74
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
80102dd7:	68 93 6d 10 80       	push   $0x80106d93
80102ddc:	50                   	push   %eax
80102ddd:	e8 f1 0c 00 00       	call   80103ad3 <initlock>
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
80102e61:	e8 a9 0d 00 00       	call   80103c0f <acquire>
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
80102e83:	e8 a0 09 00 00       	call   80103828 <wakeup>
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
80102ea1:	e8 ce 0d 00 00       	call   80103c74 <release>
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
80102ec2:	e8 61 09 00 00       	call   80103828 <wakeup>
80102ec7:	83 c4 10             	add    $0x10,%esp
80102eca:	eb bf                	jmp    80102e8b <pipeclose+0x35>
    release(&p->lock);
80102ecc:	83 ec 0c             	sub    $0xc,%esp
80102ecf:	53                   	push   %ebx
80102ed0:	e8 9f 0d 00 00       	call   80103c74 <release>
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
80102ef2:	e8 18 0d 00 00       	call   80103c0f <acquire>
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
80102f0d:	e8 16 09 00 00       	call   80103828 <wakeup>
  release(&p->lock);
80102f12:	89 1c 24             	mov    %ebx,(%esp)
80102f15:	e8 5a 0d 00 00       	call   80103c74 <release>
  return n;
80102f1a:	83 c4 10             	add    $0x10,%esp
80102f1d:	89 f0                	mov    %esi,%eax
80102f1f:	eb 5c                	jmp    80102f7d <pipewrite+0x9b>
      wakeup(&p->nread);
80102f21:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f27:	83 ec 0c             	sub    $0xc,%esp
80102f2a:	50                   	push   %eax
80102f2b:	e8 f8 08 00 00       	call   80103828 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f30:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f36:	83 c4 08             	add    $0x8,%esp
80102f39:	53                   	push   %ebx
80102f3a:	50                   	push   %eax
80102f3b:	e8 83 07 00 00       	call   801036c3 <sleep>
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
80102f70:	e8 ff 0c 00 00       	call   80103c74 <release>
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
80102fb7:	e8 53 0c 00 00       	call   80103c0f <acquire>
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
80102fcc:	e8 f2 06 00 00       	call   801036c3 <sleep>
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
80102ffb:	e8 74 0c 00 00       	call   80103c74 <release>
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
80103040:	e8 e3 07 00 00       	call   80103828 <wakeup>
  release(&p->lock);
80103045:	89 1c 24             	mov    %ebx,(%esp)
80103048:	e8 27 0c 00 00       	call   80103c74 <release>
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
80103068:	83 ea 80             	sub    $0xffffff80,%edx
8010306b:	81 fa 54 3d 11 80    	cmp    $0x80113d54,%edx
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
allocproc(void) {
80103088:	55                   	push   %ebp
80103089:	89 e5                	mov    %esp,%ebp
8010308b:	53                   	push   %ebx
8010308c:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010308f:	68 20 1d 11 80       	push   $0x80111d20
80103094:	e8 76 0b 00 00       	call   80103c0f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103099:	83 c4 10             	add    $0x10,%esp
8010309c:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801030a1:	eb 03                	jmp    801030a6 <allocproc+0x1e>
801030a3:	83 eb 80             	sub    $0xffffff80,%ebx
801030a6:	81 fb 54 3d 11 80    	cmp    $0x80113d54,%ebx
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
801030d4:	e8 9b 0b 00 00       	call   80103c74 <release>
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
801030f1:	c7 80 b0 0f 00 00 ab 	movl   $0x80104dab,0xfb0(%eax)
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
8010310b:	e8 ab 0b 00 00       	call   80103cbb <memset>
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
8010312c:	e8 43 0b 00 00       	call   80103c74 <release>
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
80103151:	e8 1e 0b 00 00       	call   80103c74 <release>
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
8010318f:	68 98 6d 10 80       	push   $0x80106d98
80103194:	68 20 1d 11 80       	push   $0x80111d20
80103199:	e8 35 09 00 00       	call   80103ad3 <initlock>
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
801031db:	68 7c 6e 10 80       	push   $0x80106e7c
801031e0:	e8 63 d1 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
801031e5:	83 ec 0c             	sub    $0xc,%esp
801031e8:	68 9f 6d 10 80       	push   $0x80106d9f
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
80103221:	e8 0e 09 00 00       	call   80103b34 <pushcli>
  c = mycpu();
80103226:	e8 78 ff ff ff       	call   801031a3 <mycpu>
  p = c->proc;
8010322b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103231:	e8 3a 09 00 00       	call   80103b70 <popcli>
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
8010324b:	a3 54 3d 11 80       	mov    %eax,0x80113d54
  if((p->pgdir = setupkvm()) == 0)
80103250:	e8 af 32 00 00       	call   80106504 <setupkvm>
80103255:	89 43 04             	mov    %eax,0x4(%ebx)
80103258:	85 c0                	test   %eax,%eax
8010325a:	0f 84 bf 00 00 00    	je     8010331f <userinit+0xe2>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103260:	83 ec 04             	sub    $0x4,%esp
80103263:	68 2c 00 00 00       	push   $0x2c
80103268:	68 60 a4 10 80       	push   $0x8010a460
8010326d:	50                   	push   %eax
8010326e:	e8 37 2f 00 00       	call   801061aa <inituvm>
  p->sz = PGSIZE;
80103273:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103279:	8b 43 18             	mov    0x18(%ebx),%eax
8010327c:	83 c4 0c             	add    $0xc,%esp
8010327f:	6a 4c                	push   $0x4c
80103281:	6a 00                	push   $0x0
80103283:	50                   	push   %eax
80103284:	e8 32 0a 00 00       	call   80103cbb <memset>
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
801032d7:	68 c8 6d 10 80       	push   $0x80106dc8
801032dc:	50                   	push   %eax
801032dd:	e8 45 0b 00 00       	call   80103e27 <safestrcpy>
  p->cwd = namei("/");
801032e2:	c7 04 24 d1 6d 10 80 	movl   $0x80106dd1,(%esp)
801032e9:	e8 df e8 ff ff       	call   80101bcd <namei>
801032ee:	89 43 68             	mov    %eax,0x68(%ebx)
  p->times_scheduled = 0;
801032f1:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
  acquire(&ptable.lock);
801032f8:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801032ff:	e8 0b 09 00 00       	call   80103c0f <acquire>
  p->state = RUNNABLE;
80103304:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
8010330b:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103312:	e8 5d 09 00 00       	call   80103c74 <release>
}
80103317:	83 c4 10             	add    $0x10,%esp
8010331a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010331d:	c9                   	leave  
8010331e:	c3                   	ret    
    panic("userinit: out of memory?");
8010331f:	83 ec 0c             	sub    $0xc,%esp
80103322:	68 af 6d 10 80       	push   $0x80106daf
80103327:	e8 1c d0 ff ff       	call   80100348 <panic>

8010332c <growproc>:
{
8010332c:	55                   	push   %ebp
8010332d:	89 e5                	mov    %esp,%ebp
8010332f:	56                   	push   %esi
80103330:	53                   	push   %ebx
80103331:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103334:	e8 e1 fe ff ff       	call   8010321a <myproc>
80103339:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
8010333b:	8b 00                	mov    (%eax),%eax
  if(n > 0){
8010333d:	85 f6                	test   %esi,%esi
8010333f:	7f 1c                	jg     8010335d <growproc+0x31>
  } else if(n < 0){
80103341:	78 37                	js     8010337a <growproc+0x4e>
  curproc->sz = sz;
80103343:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103345:	83 ec 0c             	sub    $0xc,%esp
80103348:	53                   	push   %ebx
80103349:	e8 e8 2c 00 00       	call   80106036 <switchuvm>
  return 0;
8010334e:	83 c4 10             	add    $0x10,%esp
80103351:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103356:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103359:	5b                   	pop    %ebx
8010335a:	5e                   	pop    %esi
8010335b:	5d                   	pop    %ebp
8010335c:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010335d:	83 ec 04             	sub    $0x4,%esp
80103360:	01 c6                	add    %eax,%esi
80103362:	56                   	push   %esi
80103363:	50                   	push   %eax
80103364:	ff 73 04             	push   0x4(%ebx)
80103367:	e8 14 30 00 00       	call   80106380 <allocuvm>
8010336c:	83 c4 10             	add    $0x10,%esp
8010336f:	85 c0                	test   %eax,%eax
80103371:	75 d0                	jne    80103343 <growproc+0x17>
      return -1;
80103373:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103378:	eb dc                	jmp    80103356 <growproc+0x2a>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010337a:	83 ec 04             	sub    $0x4,%esp
8010337d:	01 c6                	add    %eax,%esi
8010337f:	56                   	push   %esi
80103380:	50                   	push   %eax
80103381:	ff 73 04             	push   0x4(%ebx)
80103384:	e8 51 2f 00 00       	call   801062da <deallocuvm>
80103389:	83 c4 10             	add    $0x10,%esp
8010338c:	85 c0                	test   %eax,%eax
8010338e:	75 b3                	jne    80103343 <growproc+0x17>
      return -1;
80103390:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103395:	eb bf                	jmp    80103356 <growproc+0x2a>

80103397 <fork>:
{
80103397:	55                   	push   %ebp
80103398:	89 e5                	mov    %esp,%ebp
8010339a:	57                   	push   %edi
8010339b:	56                   	push   %esi
8010339c:	53                   	push   %ebx
8010339d:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801033a0:	e8 75 fe ff ff       	call   8010321a <myproc>
801033a5:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801033a7:	e8 dc fc ff ff       	call   80103088 <allocproc>
801033ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801033af:	85 c0                	test   %eax,%eax
801033b1:	0f 84 e0 00 00 00    	je     80103497 <fork+0x100>
801033b7:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801033b9:	83 ec 08             	sub    $0x8,%esp
801033bc:	ff 33                	push   (%ebx)
801033be:	ff 73 04             	push   0x4(%ebx)
801033c1:	e8 ef 31 00 00       	call   801065b5 <copyuvm>
801033c6:	89 47 04             	mov    %eax,0x4(%edi)
801033c9:	83 c4 10             	add    $0x10,%esp
801033cc:	85 c0                	test   %eax,%eax
801033ce:	74 2a                	je     801033fa <fork+0x63>
  np->sz = curproc->sz;
801033d0:	8b 03                	mov    (%ebx),%eax
801033d2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801033d5:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
801033d7:	89 c8                	mov    %ecx,%eax
801033d9:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
801033dc:	8b 73 18             	mov    0x18(%ebx),%esi
801033df:	8b 79 18             	mov    0x18(%ecx),%edi
801033e2:	b9 13 00 00 00       	mov    $0x13,%ecx
801033e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
801033e9:	8b 40 18             	mov    0x18(%eax),%eax
801033ec:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801033f3:	be 00 00 00 00       	mov    $0x0,%esi
801033f8:	eb 29                	jmp    80103423 <fork+0x8c>
    kfree(np->kstack);
801033fa:	83 ec 0c             	sub    $0xc,%esp
801033fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103400:	ff 73 08             	push   0x8(%ebx)
80103403:	e8 84 eb ff ff       	call   80101f8c <kfree>
    np->kstack = 0;
80103408:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
8010340f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103416:	83 c4 10             	add    $0x10,%esp
80103419:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010341e:	eb 6d                	jmp    8010348d <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
80103420:	83 c6 01             	add    $0x1,%esi
80103423:	83 fe 0f             	cmp    $0xf,%esi
80103426:	7f 1d                	jg     80103445 <fork+0xae>
    if(curproc->ofile[i])
80103428:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010342c:	85 c0                	test   %eax,%eax
8010342e:	74 f0                	je     80103420 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103430:	83 ec 0c             	sub    $0xc,%esp
80103433:	50                   	push   %eax
80103434:	e8 45 d8 ff ff       	call   80100c7e <filedup>
80103439:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010343c:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103440:	83 c4 10             	add    $0x10,%esp
80103443:	eb db                	jmp    80103420 <fork+0x89>
  np->cwd = idup(curproc->cwd);
80103445:	83 ec 0c             	sub    $0xc,%esp
80103448:	ff 73 68             	push   0x68(%ebx)
8010344b:	e8 ef e0 ff ff       	call   8010153f <idup>
80103450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103453:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103456:	83 c3 6c             	add    $0x6c,%ebx
80103459:	8d 47 6c             	lea    0x6c(%edi),%eax
8010345c:	83 c4 0c             	add    $0xc,%esp
8010345f:	6a 10                	push   $0x10
80103461:	53                   	push   %ebx
80103462:	50                   	push   %eax
80103463:	e8 bf 09 00 00       	call   80103e27 <safestrcpy>
  pid = np->pid;
80103468:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010346b:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103472:	e8 98 07 00 00       	call   80103c0f <acquire>
  np->state = RUNNABLE;
80103477:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
8010347e:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103485:	e8 ea 07 00 00       	call   80103c74 <release>
  return pid;
8010348a:	83 c4 10             	add    $0x10,%esp
}
8010348d:	89 d8                	mov    %ebx,%eax
8010348f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103492:	5b                   	pop    %ebx
80103493:	5e                   	pop    %esi
80103494:	5f                   	pop    %edi
80103495:	5d                   	pop    %ebp
80103496:	c3                   	ret    
    return -1;
80103497:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010349c:	eb ef                	jmp    8010348d <fork+0xf6>

8010349e <scheduler>:
{
8010349e:	55                   	push   %ebp
8010349f:	89 e5                	mov    %esp,%ebp
801034a1:	56                   	push   %esi
801034a2:	53                   	push   %ebx
  struct cpu *c = mycpu();
801034a3:	e8 fb fc ff ff       	call   801031a3 <mycpu>
801034a8:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801034aa:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801034b1:	00 00 00 
801034b4:	eb 5a                	jmp    80103510 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801034b6:	83 eb 80             	sub    $0xffffff80,%ebx
801034b9:	81 fb 54 3d 11 80    	cmp    $0x80113d54,%ebx
801034bf:	73 3f                	jae    80103500 <scheduler+0x62>
      if(p->state != RUNNABLE)
801034c1:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801034c5:	75 ef                	jne    801034b6 <scheduler+0x18>
      c->proc = p;
801034c7:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801034cd:	83 ec 0c             	sub    $0xc,%esp
801034d0:	53                   	push   %ebx
801034d1:	e8 60 2b 00 00       	call   80106036 <switchuvm>
      p->state = RUNNING;
801034d6:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801034dd:	83 c4 08             	add    $0x8,%esp
801034e0:	ff 73 1c             	push   0x1c(%ebx)
801034e3:	8d 46 04             	lea    0x4(%esi),%eax
801034e6:	50                   	push   %eax
801034e7:	e8 90 09 00 00       	call   80103e7c <swtch>
      switchkvm();
801034ec:	e8 20 2b 00 00       	call   80106011 <switchkvm>
      c->proc = 0;
801034f1:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801034f8:	00 00 00 
801034fb:	83 c4 10             	add    $0x10,%esp
801034fe:	eb b6                	jmp    801034b6 <scheduler+0x18>
    release(&ptable.lock);
80103500:	83 ec 0c             	sub    $0xc,%esp
80103503:	68 20 1d 11 80       	push   $0x80111d20
80103508:	e8 67 07 00 00       	call   80103c74 <release>
    sti();
8010350d:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103510:	fb                   	sti    
    acquire(&ptable.lock);
80103511:	83 ec 0c             	sub    $0xc,%esp
80103514:	68 20 1d 11 80       	push   $0x80111d20
80103519:	e8 f1 06 00 00       	call   80103c0f <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010351e:	83 c4 10             	add    $0x10,%esp
80103521:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103526:	eb 91                	jmp    801034b9 <scheduler+0x1b>

80103528 <sched>:
{
80103528:	55                   	push   %ebp
80103529:	89 e5                	mov    %esp,%ebp
8010352b:	56                   	push   %esi
8010352c:	53                   	push   %ebx
  struct proc *p = myproc();
8010352d:	e8 e8 fc ff ff       	call   8010321a <myproc>
80103532:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103534:	83 ec 0c             	sub    $0xc,%esp
80103537:	68 20 1d 11 80       	push   $0x80111d20
8010353c:	e8 8f 06 00 00       	call   80103bd0 <holding>
80103541:	83 c4 10             	add    $0x10,%esp
80103544:	85 c0                	test   %eax,%eax
80103546:	74 4f                	je     80103597 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103548:	e8 56 fc ff ff       	call   801031a3 <mycpu>
8010354d:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103554:	75 4e                	jne    801035a4 <sched+0x7c>
  if(p->state == RUNNING)
80103556:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
8010355a:	74 55                	je     801035b1 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010355c:	9c                   	pushf  
8010355d:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010355e:	f6 c4 02             	test   $0x2,%ah
80103561:	75 5b                	jne    801035be <sched+0x96>
  intena = mycpu()->intena;
80103563:	e8 3b fc ff ff       	call   801031a3 <mycpu>
80103568:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
8010356e:	e8 30 fc ff ff       	call   801031a3 <mycpu>
80103573:	83 ec 08             	sub    $0x8,%esp
80103576:	ff 70 04             	push   0x4(%eax)
80103579:	83 c3 1c             	add    $0x1c,%ebx
8010357c:	53                   	push   %ebx
8010357d:	e8 fa 08 00 00       	call   80103e7c <swtch>
  mycpu()->intena = intena;
80103582:	e8 1c fc ff ff       	call   801031a3 <mycpu>
80103587:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010358d:	83 c4 10             	add    $0x10,%esp
80103590:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103593:	5b                   	pop    %ebx
80103594:	5e                   	pop    %esi
80103595:	5d                   	pop    %ebp
80103596:	c3                   	ret    
    panic("sched ptable.lock");
80103597:	83 ec 0c             	sub    $0xc,%esp
8010359a:	68 d3 6d 10 80       	push   $0x80106dd3
8010359f:	e8 a4 cd ff ff       	call   80100348 <panic>
    panic("sched locks");
801035a4:	83 ec 0c             	sub    $0xc,%esp
801035a7:	68 e5 6d 10 80       	push   $0x80106de5
801035ac:	e8 97 cd ff ff       	call   80100348 <panic>
    panic("sched running");
801035b1:	83 ec 0c             	sub    $0xc,%esp
801035b4:	68 f1 6d 10 80       	push   $0x80106df1
801035b9:	e8 8a cd ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801035be:	83 ec 0c             	sub    $0xc,%esp
801035c1:	68 ff 6d 10 80       	push   $0x80106dff
801035c6:	e8 7d cd ff ff       	call   80100348 <panic>

801035cb <exit>:
{
801035cb:	55                   	push   %ebp
801035cc:	89 e5                	mov    %esp,%ebp
801035ce:	56                   	push   %esi
801035cf:	53                   	push   %ebx
  struct proc *curproc = myproc();
801035d0:	e8 45 fc ff ff       	call   8010321a <myproc>
  if(curproc == initproc)
801035d5:	39 05 54 3d 11 80    	cmp    %eax,0x80113d54
801035db:	74 09                	je     801035e6 <exit+0x1b>
801035dd:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801035df:	bb 00 00 00 00       	mov    $0x0,%ebx
801035e4:	eb 24                	jmp    8010360a <exit+0x3f>
    panic("init exiting");
801035e6:	83 ec 0c             	sub    $0xc,%esp
801035e9:	68 13 6e 10 80       	push   $0x80106e13
801035ee:	e8 55 cd ff ff       	call   80100348 <panic>
      fileclose(curproc->ofile[fd]);
801035f3:	83 ec 0c             	sub    $0xc,%esp
801035f6:	50                   	push   %eax
801035f7:	e8 c7 d6 ff ff       	call   80100cc3 <fileclose>
      curproc->ofile[fd] = 0;
801035fc:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103603:	00 
80103604:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103607:	83 c3 01             	add    $0x1,%ebx
8010360a:	83 fb 0f             	cmp    $0xf,%ebx
8010360d:	7f 0a                	jg     80103619 <exit+0x4e>
    if(curproc->ofile[fd]){
8010360f:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103613:	85 c0                	test   %eax,%eax
80103615:	75 dc                	jne    801035f3 <exit+0x28>
80103617:	eb ee                	jmp    80103607 <exit+0x3c>
  begin_op();
80103619:	e8 92 f1 ff ff       	call   801027b0 <begin_op>
  iput(curproc->cwd);
8010361e:	83 ec 0c             	sub    $0xc,%esp
80103621:	ff 76 68             	push   0x68(%esi)
80103624:	e8 4d e0 ff ff       	call   80101676 <iput>
  end_op();
80103629:	e8 fc f1 ff ff       	call   8010282a <end_op>
  curproc->cwd = 0;
8010362e:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103635:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010363c:	e8 ce 05 00 00       	call   80103c0f <acquire>
  wakeup1(curproc->parent);
80103641:	8b 46 14             	mov    0x14(%esi),%eax
80103644:	e8 18 fa ff ff       	call   80103061 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103649:	83 c4 10             	add    $0x10,%esp
8010364c:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103651:	eb 03                	jmp    80103656 <exit+0x8b>
80103653:	83 eb 80             	sub    $0xffffff80,%ebx
80103656:	81 fb 54 3d 11 80    	cmp    $0x80113d54,%ebx
8010365c:	73 1a                	jae    80103678 <exit+0xad>
    if(p->parent == curproc){
8010365e:	39 73 14             	cmp    %esi,0x14(%ebx)
80103661:	75 f0                	jne    80103653 <exit+0x88>
      p->parent = initproc;
80103663:	a1 54 3d 11 80       	mov    0x80113d54,%eax
80103668:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
8010366b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010366f:	75 e2                	jne    80103653 <exit+0x88>
        wakeup1(initproc);
80103671:	e8 eb f9 ff ff       	call   80103061 <wakeup1>
80103676:	eb db                	jmp    80103653 <exit+0x88>
  curproc->state = ZOMBIE;
80103678:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
8010367f:	e8 a4 fe ff ff       	call   80103528 <sched>
  panic("zombie exit");
80103684:	83 ec 0c             	sub    $0xc,%esp
80103687:	68 20 6e 10 80       	push   $0x80106e20
8010368c:	e8 b7 cc ff ff       	call   80100348 <panic>

80103691 <yield>:
{
80103691:	55                   	push   %ebp
80103692:	89 e5                	mov    %esp,%ebp
80103694:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103697:	68 20 1d 11 80       	push   $0x80111d20
8010369c:	e8 6e 05 00 00       	call   80103c0f <acquire>
  myproc()->state = RUNNABLE;
801036a1:	e8 74 fb ff ff       	call   8010321a <myproc>
801036a6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801036ad:	e8 76 fe ff ff       	call   80103528 <sched>
  release(&ptable.lock);
801036b2:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801036b9:	e8 b6 05 00 00       	call   80103c74 <release>
}
801036be:	83 c4 10             	add    $0x10,%esp
801036c1:	c9                   	leave  
801036c2:	c3                   	ret    

801036c3 <sleep>:
{
801036c3:	55                   	push   %ebp
801036c4:	89 e5                	mov    %esp,%ebp
801036c6:	56                   	push   %esi
801036c7:	53                   	push   %ebx
801036c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
801036cb:	e8 4a fb ff ff       	call   8010321a <myproc>
  if(p == 0)
801036d0:	85 c0                	test   %eax,%eax
801036d2:	74 66                	je     8010373a <sleep+0x77>
801036d4:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
801036d6:	85 f6                	test   %esi,%esi
801036d8:	74 6d                	je     80103747 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801036da:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
801036e0:	74 18                	je     801036fa <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801036e2:	83 ec 0c             	sub    $0xc,%esp
801036e5:	68 20 1d 11 80       	push   $0x80111d20
801036ea:	e8 20 05 00 00       	call   80103c0f <acquire>
    release(lk);
801036ef:	89 34 24             	mov    %esi,(%esp)
801036f2:	e8 7d 05 00 00       	call   80103c74 <release>
801036f7:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801036fa:	8b 45 08             	mov    0x8(%ebp),%eax
801036fd:	89 43 20             	mov    %eax,0x20(%ebx)
  p->state = SLEEPING;
80103700:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80103707:	e8 1c fe ff ff       	call   80103528 <sched>
  p->chan = 0;
8010370c:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103713:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
80103719:	74 18                	je     80103733 <sleep+0x70>
    release(&ptable.lock);
8010371b:	83 ec 0c             	sub    $0xc,%esp
8010371e:	68 20 1d 11 80       	push   $0x80111d20
80103723:	e8 4c 05 00 00       	call   80103c74 <release>
    acquire(lk);
80103728:	89 34 24             	mov    %esi,(%esp)
8010372b:	e8 df 04 00 00       	call   80103c0f <acquire>
80103730:	83 c4 10             	add    $0x10,%esp
}
80103733:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103736:	5b                   	pop    %ebx
80103737:	5e                   	pop    %esi
80103738:	5d                   	pop    %ebp
80103739:	c3                   	ret    
    panic("sleep");
8010373a:	83 ec 0c             	sub    $0xc,%esp
8010373d:	68 2c 6e 10 80       	push   $0x80106e2c
80103742:	e8 01 cc ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	68 32 6e 10 80       	push   $0x80106e32
8010374f:	e8 f4 cb ff ff       	call   80100348 <panic>

80103754 <wait>:
{
80103754:	55                   	push   %ebp
80103755:	89 e5                	mov    %esp,%ebp
80103757:	56                   	push   %esi
80103758:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103759:	e8 bc fa ff ff       	call   8010321a <myproc>
8010375e:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103760:	83 ec 0c             	sub    $0xc,%esp
80103763:	68 20 1d 11 80       	push   $0x80111d20
80103768:	e8 a2 04 00 00       	call   80103c0f <acquire>
8010376d:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103770:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103775:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010377a:	eb 5b                	jmp    801037d7 <wait+0x83>
        pid = p->pid;
8010377c:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
8010377f:	83 ec 0c             	sub    $0xc,%esp
80103782:	ff 73 08             	push   0x8(%ebx)
80103785:	e8 02 e8 ff ff       	call   80101f8c <kfree>
        p->kstack = 0;
8010378a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103791:	83 c4 04             	add    $0x4,%esp
80103794:	ff 73 04             	push   0x4(%ebx)
80103797:	e8 e6 2c 00 00       	call   80106482 <freevm>
        p->pid = 0;
8010379c:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801037a3:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801037aa:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801037ae:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801037b5:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801037bc:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801037c3:	e8 ac 04 00 00       	call   80103c74 <release>
        return pid;
801037c8:	83 c4 10             	add    $0x10,%esp
}
801037cb:	89 f0                	mov    %esi,%eax
801037cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
801037d0:	5b                   	pop    %ebx
801037d1:	5e                   	pop    %esi
801037d2:	5d                   	pop    %ebp
801037d3:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037d4:	83 eb 80             	sub    $0xffffff80,%ebx
801037d7:	81 fb 54 3d 11 80    	cmp    $0x80113d54,%ebx
801037dd:	73 12                	jae    801037f1 <wait+0x9d>
      if(p->parent != curproc)
801037df:	39 73 14             	cmp    %esi,0x14(%ebx)
801037e2:	75 f0                	jne    801037d4 <wait+0x80>
      if(p->state == ZOMBIE){
801037e4:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801037e8:	74 92                	je     8010377c <wait+0x28>
      havekids = 1;
801037ea:	b8 01 00 00 00       	mov    $0x1,%eax
801037ef:	eb e3                	jmp    801037d4 <wait+0x80>
    if(!havekids || curproc->killed){
801037f1:	85 c0                	test   %eax,%eax
801037f3:	74 06                	je     801037fb <wait+0xa7>
801037f5:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801037f9:	74 17                	je     80103812 <wait+0xbe>
      release(&ptable.lock);
801037fb:	83 ec 0c             	sub    $0xc,%esp
801037fe:	68 20 1d 11 80       	push   $0x80111d20
80103803:	e8 6c 04 00 00       	call   80103c74 <release>
      return -1;
80103808:	83 c4 10             	add    $0x10,%esp
8010380b:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103810:	eb b9                	jmp    801037cb <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103812:	83 ec 08             	sub    $0x8,%esp
80103815:	68 20 1d 11 80       	push   $0x80111d20
8010381a:	56                   	push   %esi
8010381b:	e8 a3 fe ff ff       	call   801036c3 <sleep>
    havekids = 0;
80103820:	83 c4 10             	add    $0x10,%esp
80103823:	e9 48 ff ff ff       	jmp    80103770 <wait+0x1c>

80103828 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103828:	55                   	push   %ebp
80103829:	89 e5                	mov    %esp,%ebp
8010382b:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
8010382e:	68 20 1d 11 80       	push   $0x80111d20
80103833:	e8 d7 03 00 00       	call   80103c0f <acquire>
  wakeup1(chan);
80103838:	8b 45 08             	mov    0x8(%ebp),%eax
8010383b:	e8 21 f8 ff ff       	call   80103061 <wakeup1>
  release(&ptable.lock);
80103840:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103847:	e8 28 04 00 00       	call   80103c74 <release>
}
8010384c:	83 c4 10             	add    $0x10,%esp
8010384f:	c9                   	leave  
80103850:	c3                   	ret    

80103851 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103851:	55                   	push   %ebp
80103852:	89 e5                	mov    %esp,%ebp
80103854:	53                   	push   %ebx
80103855:	83 ec 10             	sub    $0x10,%esp
80103858:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010385b:	68 20 1d 11 80       	push   $0x80111d20
80103860:	e8 aa 03 00 00       	call   80103c0f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103865:	83 c4 10             	add    $0x10,%esp
80103868:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
8010386d:	eb 0c                	jmp    8010387b <kill+0x2a>
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
8010386f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103876:	eb 1c                	jmp    80103894 <kill+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103878:	83 e8 80             	sub    $0xffffff80,%eax
8010387b:	3d 54 3d 11 80       	cmp    $0x80113d54,%eax
80103880:	73 2c                	jae    801038ae <kill+0x5d>
    if(p->pid == pid){
80103882:	39 58 10             	cmp    %ebx,0x10(%eax)
80103885:	75 f1                	jne    80103878 <kill+0x27>
      p->killed = 1;
80103887:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
8010388e:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103892:	74 db                	je     8010386f <kill+0x1e>
      release(&ptable.lock);
80103894:	83 ec 0c             	sub    $0xc,%esp
80103897:	68 20 1d 11 80       	push   $0x80111d20
8010389c:	e8 d3 03 00 00       	call   80103c74 <release>
      return 0;
801038a1:	83 c4 10             	add    $0x10,%esp
801038a4:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801038a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038ac:	c9                   	leave  
801038ad:	c3                   	ret    
  release(&ptable.lock);
801038ae:	83 ec 0c             	sub    $0xc,%esp
801038b1:	68 20 1d 11 80       	push   $0x80111d20
801038b6:	e8 b9 03 00 00       	call   80103c74 <release>
  return -1;
801038bb:	83 c4 10             	add    $0x10,%esp
801038be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038c3:	eb e4                	jmp    801038a9 <kill+0x58>

801038c5 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801038c5:	55                   	push   %ebp
801038c6:	89 e5                	mov    %esp,%ebp
801038c8:	56                   	push   %esi
801038c9:	53                   	push   %ebx
801038ca:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038cd:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801038d2:	eb 33                	jmp    80103907 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801038d4:	b8 43 6e 10 80       	mov    $0x80106e43,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801038d9:	8d 53 6c             	lea    0x6c(%ebx),%edx
801038dc:	52                   	push   %edx
801038dd:	50                   	push   %eax
801038de:	ff 73 10             	push   0x10(%ebx)
801038e1:	68 47 6e 10 80       	push   $0x80106e47
801038e6:	e8 1c cd ff ff       	call   80100607 <cprintf>
    if(p->state == SLEEPING){
801038eb:	83 c4 10             	add    $0x10,%esp
801038ee:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801038f2:	74 39                	je     8010392d <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801038f4:	83 ec 0c             	sub    $0xc,%esp
801038f7:	68 cf 71 10 80       	push   $0x801071cf
801038fc:	e8 06 cd ff ff       	call   80100607 <cprintf>
80103901:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103904:	83 eb 80             	sub    $0xffffff80,%ebx
80103907:	81 fb 54 3d 11 80    	cmp    $0x80113d54,%ebx
8010390d:	73 61                	jae    80103970 <procdump+0xab>
    if(p->state == UNUSED)
8010390f:	8b 43 0c             	mov    0xc(%ebx),%eax
80103912:	85 c0                	test   %eax,%eax
80103914:	74 ee                	je     80103904 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103916:	83 f8 05             	cmp    $0x5,%eax
80103919:	77 b9                	ja     801038d4 <procdump+0xf>
8010391b:	8b 04 85 a4 6e 10 80 	mov    -0x7fef915c(,%eax,4),%eax
80103922:	85 c0                	test   %eax,%eax
80103924:	75 b3                	jne    801038d9 <procdump+0x14>
      state = "???";
80103926:	b8 43 6e 10 80       	mov    $0x80106e43,%eax
8010392b:	eb ac                	jmp    801038d9 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010392d:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103930:	8b 40 0c             	mov    0xc(%eax),%eax
80103933:	83 c0 08             	add    $0x8,%eax
80103936:	83 ec 08             	sub    $0x8,%esp
80103939:	8d 55 d0             	lea    -0x30(%ebp),%edx
8010393c:	52                   	push   %edx
8010393d:	50                   	push   %eax
8010393e:	e8 ab 01 00 00       	call   80103aee <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103943:	83 c4 10             	add    $0x10,%esp
80103946:	be 00 00 00 00       	mov    $0x0,%esi
8010394b:	eb 14                	jmp    80103961 <procdump+0x9c>
        cprintf(" %p", pc[i]);
8010394d:	83 ec 08             	sub    $0x8,%esp
80103950:	50                   	push   %eax
80103951:	68 e1 67 10 80       	push   $0x801067e1
80103956:	e8 ac cc ff ff       	call   80100607 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
8010395b:	83 c6 01             	add    $0x1,%esi
8010395e:	83 c4 10             	add    $0x10,%esp
80103961:	83 fe 09             	cmp    $0x9,%esi
80103964:	7f 8e                	jg     801038f4 <procdump+0x2f>
80103966:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
8010396a:	85 c0                	test   %eax,%eax
8010396c:	75 df                	jne    8010394d <procdump+0x88>
8010396e:	eb 84                	jmp    801038f4 <procdump+0x2f>
  }
}
80103970:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103973:	5b                   	pop    %ebx
80103974:	5e                   	pop    %esi
80103975:	5d                   	pop    %ebp
80103976:	c3                   	ret    

80103977 <sys_getprocessesinfo>:


int sys_getprocessesinfo(void) {
80103977:	55                   	push   %ebp
80103978:	89 e5                	mov    %esp,%ebp
8010397a:	83 ec 1c             	sub    $0x1c,%esp
  struct processes_info *p;
  if (argptr(0, (void*)&p, sizeof(*p)) < 0) {
8010397d:	68 04 03 00 00       	push   $0x304
80103982:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103985:	50                   	push   %eax
80103986:	6a 00                	push   $0x0
80103988:	e8 a6 05 00 00       	call   80103f33 <argptr>
8010398d:	83 c4 10             	add    $0x10,%esp
80103990:	85 c0                	test   %eax,%eax
80103992:	78 2d                	js     801039c1 <sys_getprocessesinfo+0x4a>
  }
  int count_unused = 0;
  struct proc *v;


  for(v = ptable.proc; v < &ptable.proc[NPROC]; v++){
80103994:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
  int count_unused = 0;
80103999:	ba 00 00 00 00       	mov    $0x0,%edx
8010399e:	eb 03                	jmp    801039a3 <sys_getprocessesinfo+0x2c>
  for(v = ptable.proc; v < &ptable.proc[NPROC]; v++){
801039a0:	83 e8 80             	sub    $0xffffff80,%eax
801039a3:	3d 54 3d 11 80       	cmp    $0x80113d54,%eax
801039a8:	73 0b                	jae    801039b5 <sys_getprocessesinfo+0x3e>
    if(v->state != UNUSED) {
801039aa:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
801039ae:	74 f0                	je     801039a0 <sys_getprocessesinfo+0x29>
      count_unused++;
801039b0:	83 c2 01             	add    $0x1,%edx
801039b3:	eb eb                	jmp    801039a0 <sys_getprocessesinfo+0x29>
    }
  }
  p->num_processes = count_unused;
801039b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b8:	89 10                	mov    %edx,(%eax)

  return 0;
801039ba:	b8 00 00 00 00       	mov    $0x0,%eax
801039bf:	c9                   	leave  
801039c0:	c3                   	ret    
    return -1; //error
801039c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801039c6:	eb f7                	jmp    801039bf <sys_getprocessesinfo+0x48>

801039c8 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801039c8:	55                   	push   %ebp
801039c9:	89 e5                	mov    %esp,%ebp
801039cb:	53                   	push   %ebx
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801039d2:	68 bc 6e 10 80       	push   $0x80106ebc
801039d7:	8d 43 04             	lea    0x4(%ebx),%eax
801039da:	50                   	push   %eax
801039db:	e8 f3 00 00 00       	call   80103ad3 <initlock>
  lk->name = name;
801039e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801039e3:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
801039e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801039ec:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
801039f3:	83 c4 10             	add    $0x10,%esp
801039f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039f9:	c9                   	leave  
801039fa:	c3                   	ret    

801039fb <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801039fb:	55                   	push   %ebp
801039fc:	89 e5                	mov    %esp,%ebp
801039fe:	56                   	push   %esi
801039ff:	53                   	push   %ebx
80103a00:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a03:	8d 73 04             	lea    0x4(%ebx),%esi
80103a06:	83 ec 0c             	sub    $0xc,%esp
80103a09:	56                   	push   %esi
80103a0a:	e8 00 02 00 00       	call   80103c0f <acquire>
  while (lk->locked) {
80103a0f:	83 c4 10             	add    $0x10,%esp
80103a12:	eb 0d                	jmp    80103a21 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103a14:	83 ec 08             	sub    $0x8,%esp
80103a17:	56                   	push   %esi
80103a18:	53                   	push   %ebx
80103a19:	e8 a5 fc ff ff       	call   801036c3 <sleep>
80103a1e:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103a21:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a24:	75 ee                	jne    80103a14 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103a26:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103a2c:	e8 e9 f7 ff ff       	call   8010321a <myproc>
80103a31:	8b 40 10             	mov    0x10(%eax),%eax
80103a34:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103a37:	83 ec 0c             	sub    $0xc,%esp
80103a3a:	56                   	push   %esi
80103a3b:	e8 34 02 00 00       	call   80103c74 <release>
}
80103a40:	83 c4 10             	add    $0x10,%esp
80103a43:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a46:	5b                   	pop    %ebx
80103a47:	5e                   	pop    %esi
80103a48:	5d                   	pop    %ebp
80103a49:	c3                   	ret    

80103a4a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103a4a:	55                   	push   %ebp
80103a4b:	89 e5                	mov    %esp,%ebp
80103a4d:	56                   	push   %esi
80103a4e:	53                   	push   %ebx
80103a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a52:	8d 73 04             	lea    0x4(%ebx),%esi
80103a55:	83 ec 0c             	sub    $0xc,%esp
80103a58:	56                   	push   %esi
80103a59:	e8 b1 01 00 00       	call   80103c0f <acquire>
  lk->locked = 0;
80103a5e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a64:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103a6b:	89 1c 24             	mov    %ebx,(%esp)
80103a6e:	e8 b5 fd ff ff       	call   80103828 <wakeup>
  release(&lk->lk);
80103a73:	89 34 24             	mov    %esi,(%esp)
80103a76:	e8 f9 01 00 00       	call   80103c74 <release>
}
80103a7b:	83 c4 10             	add    $0x10,%esp
80103a7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a81:	5b                   	pop    %ebx
80103a82:	5e                   	pop    %esi
80103a83:	5d                   	pop    %ebp
80103a84:	c3                   	ret    

80103a85 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103a85:	55                   	push   %ebp
80103a86:	89 e5                	mov    %esp,%ebp
80103a88:	56                   	push   %esi
80103a89:	53                   	push   %ebx
80103a8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103a8d:	8d 73 04             	lea    0x4(%ebx),%esi
80103a90:	83 ec 0c             	sub    $0xc,%esp
80103a93:	56                   	push   %esi
80103a94:	e8 76 01 00 00       	call   80103c0f <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103a99:	83 c4 10             	add    $0x10,%esp
80103a9c:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a9f:	75 17                	jne    80103ab8 <holdingsleep+0x33>
80103aa1:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103aa6:	83 ec 0c             	sub    $0xc,%esp
80103aa9:	56                   	push   %esi
80103aaa:	e8 c5 01 00 00       	call   80103c74 <release>
  return r;
}
80103aaf:	89 d8                	mov    %ebx,%eax
80103ab1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ab4:	5b                   	pop    %ebx
80103ab5:	5e                   	pop    %esi
80103ab6:	5d                   	pop    %ebp
80103ab7:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103ab8:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103abb:	e8 5a f7 ff ff       	call   8010321a <myproc>
80103ac0:	3b 58 10             	cmp    0x10(%eax),%ebx
80103ac3:	74 07                	je     80103acc <holdingsleep+0x47>
80103ac5:	bb 00 00 00 00       	mov    $0x0,%ebx
80103aca:	eb da                	jmp    80103aa6 <holdingsleep+0x21>
80103acc:	bb 01 00 00 00       	mov    $0x1,%ebx
80103ad1:	eb d3                	jmp    80103aa6 <holdingsleep+0x21>

80103ad3 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103ad3:	55                   	push   %ebp
80103ad4:	89 e5                	mov    %esp,%ebp
80103ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103ad9:	8b 55 0c             	mov    0xc(%ebp),%edx
80103adc:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103adf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103ae5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103aec:	5d                   	pop    %ebp
80103aed:	c3                   	ret    

80103aee <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103aee:	55                   	push   %ebp
80103aef:	89 e5                	mov    %esp,%ebp
80103af1:	53                   	push   %ebx
80103af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103af5:	8b 45 08             	mov    0x8(%ebp),%eax
80103af8:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103afb:	b8 00 00 00 00       	mov    $0x0,%eax
80103b00:	83 f8 09             	cmp    $0x9,%eax
80103b03:	7f 25                	jg     80103b2a <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103b05:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103b0b:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103b11:	77 17                	ja     80103b2a <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103b13:	8b 5a 04             	mov    0x4(%edx),%ebx
80103b16:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103b19:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103b1b:	83 c0 01             	add    $0x1,%eax
80103b1e:	eb e0                	jmp    80103b00 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103b20:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103b27:	83 c0 01             	add    $0x1,%eax
80103b2a:	83 f8 09             	cmp    $0x9,%eax
80103b2d:	7e f1                	jle    80103b20 <getcallerpcs+0x32>
}
80103b2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b32:	c9                   	leave  
80103b33:	c3                   	ret    

80103b34 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103b34:	55                   	push   %ebp
80103b35:	89 e5                	mov    %esp,%ebp
80103b37:	53                   	push   %ebx
80103b38:	83 ec 04             	sub    $0x4,%esp
80103b3b:	9c                   	pushf  
80103b3c:	5b                   	pop    %ebx
  asm volatile("cli");
80103b3d:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103b3e:	e8 60 f6 ff ff       	call   801031a3 <mycpu>
80103b43:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103b4a:	74 11                	je     80103b5d <pushcli+0x29>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103b4c:	e8 52 f6 ff ff       	call   801031a3 <mycpu>
80103b51:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103b58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b5b:	c9                   	leave  
80103b5c:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103b5d:	e8 41 f6 ff ff       	call   801031a3 <mycpu>
80103b62:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103b68:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103b6e:	eb dc                	jmp    80103b4c <pushcli+0x18>

80103b70 <popcli>:

void
popcli(void)
{
80103b70:	55                   	push   %ebp
80103b71:	89 e5                	mov    %esp,%ebp
80103b73:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b76:	9c                   	pushf  
80103b77:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103b78:	f6 c4 02             	test   $0x2,%ah
80103b7b:	75 28                	jne    80103ba5 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103b7d:	e8 21 f6 ff ff       	call   801031a3 <mycpu>
80103b82:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103b88:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103b8b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103b91:	85 d2                	test   %edx,%edx
80103b93:	78 1d                	js     80103bb2 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103b95:	e8 09 f6 ff ff       	call   801031a3 <mycpu>
80103b9a:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103ba1:	74 1c                	je     80103bbf <popcli+0x4f>
    sti();
}
80103ba3:	c9                   	leave  
80103ba4:	c3                   	ret    
    panic("popcli - interruptible");
80103ba5:	83 ec 0c             	sub    $0xc,%esp
80103ba8:	68 c7 6e 10 80       	push   $0x80106ec7
80103bad:	e8 96 c7 ff ff       	call   80100348 <panic>
    panic("popcli");
80103bb2:	83 ec 0c             	sub    $0xc,%esp
80103bb5:	68 de 6e 10 80       	push   $0x80106ede
80103bba:	e8 89 c7 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103bbf:	e8 df f5 ff ff       	call   801031a3 <mycpu>
80103bc4:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103bcb:	74 d6                	je     80103ba3 <popcli+0x33>
  asm volatile("sti");
80103bcd:	fb                   	sti    
}
80103bce:	eb d3                	jmp    80103ba3 <popcli+0x33>

80103bd0 <holding>:
{
80103bd0:	55                   	push   %ebp
80103bd1:	89 e5                	mov    %esp,%ebp
80103bd3:	53                   	push   %ebx
80103bd4:	83 ec 04             	sub    $0x4,%esp
80103bd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103bda:	e8 55 ff ff ff       	call   80103b34 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103bdf:	83 3b 00             	cmpl   $0x0,(%ebx)
80103be2:	75 11                	jne    80103bf5 <holding+0x25>
80103be4:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103be9:	e8 82 ff ff ff       	call   80103b70 <popcli>
}
80103bee:	89 d8                	mov    %ebx,%eax
80103bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103bf3:	c9                   	leave  
80103bf4:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103bf5:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103bf8:	e8 a6 f5 ff ff       	call   801031a3 <mycpu>
80103bfd:	39 c3                	cmp    %eax,%ebx
80103bff:	74 07                	je     80103c08 <holding+0x38>
80103c01:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c06:	eb e1                	jmp    80103be9 <holding+0x19>
80103c08:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c0d:	eb da                	jmp    80103be9 <holding+0x19>

80103c0f <acquire>:
{
80103c0f:	55                   	push   %ebp
80103c10:	89 e5                	mov    %esp,%ebp
80103c12:	53                   	push   %ebx
80103c13:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103c16:	e8 19 ff ff ff       	call   80103b34 <pushcli>
  if(holding(lk))
80103c1b:	83 ec 0c             	sub    $0xc,%esp
80103c1e:	ff 75 08             	push   0x8(%ebp)
80103c21:	e8 aa ff ff ff       	call   80103bd0 <holding>
80103c26:	83 c4 10             	add    $0x10,%esp
80103c29:	85 c0                	test   %eax,%eax
80103c2b:	75 3a                	jne    80103c67 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103c30:	b8 01 00 00 00       	mov    $0x1,%eax
80103c35:	f0 87 02             	lock xchg %eax,(%edx)
80103c38:	85 c0                	test   %eax,%eax
80103c3a:	75 f1                	jne    80103c2d <acquire+0x1e>
  __sync_synchronize();
80103c3c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103c41:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103c44:	e8 5a f5 ff ff       	call   801031a3 <mycpu>
80103c49:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c4f:	83 c0 0c             	add    $0xc,%eax
80103c52:	83 ec 08             	sub    $0x8,%esp
80103c55:	50                   	push   %eax
80103c56:	8d 45 08             	lea    0x8(%ebp),%eax
80103c59:	50                   	push   %eax
80103c5a:	e8 8f fe ff ff       	call   80103aee <getcallerpcs>
}
80103c5f:	83 c4 10             	add    $0x10,%esp
80103c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c65:	c9                   	leave  
80103c66:	c3                   	ret    
    panic("acquire");
80103c67:	83 ec 0c             	sub    $0xc,%esp
80103c6a:	68 e5 6e 10 80       	push   $0x80106ee5
80103c6f:	e8 d4 c6 ff ff       	call   80100348 <panic>

80103c74 <release>:
{
80103c74:	55                   	push   %ebp
80103c75:	89 e5                	mov    %esp,%ebp
80103c77:	53                   	push   %ebx
80103c78:	83 ec 10             	sub    $0x10,%esp
80103c7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103c7e:	53                   	push   %ebx
80103c7f:	e8 4c ff ff ff       	call   80103bd0 <holding>
80103c84:	83 c4 10             	add    $0x10,%esp
80103c87:	85 c0                	test   %eax,%eax
80103c89:	74 23                	je     80103cae <release+0x3a>
  lk->pcs[0] = 0;
80103c8b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103c92:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103c99:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103c9e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103ca4:	e8 c7 fe ff ff       	call   80103b70 <popcli>
}
80103ca9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cac:	c9                   	leave  
80103cad:	c3                   	ret    
    panic("release");
80103cae:	83 ec 0c             	sub    $0xc,%esp
80103cb1:	68 ed 6e 10 80       	push   $0x80106eed
80103cb6:	e8 8d c6 ff ff       	call   80100348 <panic>

80103cbb <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103cbb:	55                   	push   %ebp
80103cbc:	89 e5                	mov    %esp,%ebp
80103cbe:	57                   	push   %edi
80103cbf:	53                   	push   %ebx
80103cc0:	8b 55 08             	mov    0x8(%ebp),%edx
80103cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103cc9:	f6 c2 03             	test   $0x3,%dl
80103ccc:	75 25                	jne    80103cf3 <memset+0x38>
80103cce:	f6 c1 03             	test   $0x3,%cl
80103cd1:	75 20                	jne    80103cf3 <memset+0x38>
    c &= 0xFF;
80103cd3:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103cd6:	c1 e9 02             	shr    $0x2,%ecx
80103cd9:	c1 e0 18             	shl    $0x18,%eax
80103cdc:	89 fb                	mov    %edi,%ebx
80103cde:	c1 e3 10             	shl    $0x10,%ebx
80103ce1:	09 d8                	or     %ebx,%eax
80103ce3:	89 fb                	mov    %edi,%ebx
80103ce5:	c1 e3 08             	shl    $0x8,%ebx
80103ce8:	09 d8                	or     %ebx,%eax
80103cea:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103cec:	89 d7                	mov    %edx,%edi
80103cee:	fc                   	cld    
80103cef:	f3 ab                	rep stos %eax,%es:(%edi)
}
80103cf1:	eb 05                	jmp    80103cf8 <memset+0x3d>
  asm volatile("cld; rep stosb" :
80103cf3:	89 d7                	mov    %edx,%edi
80103cf5:	fc                   	cld    
80103cf6:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103cf8:	89 d0                	mov    %edx,%eax
80103cfa:	5b                   	pop    %ebx
80103cfb:	5f                   	pop    %edi
80103cfc:	5d                   	pop    %ebp
80103cfd:	c3                   	ret    

80103cfe <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103cfe:	55                   	push   %ebp
80103cff:	89 e5                	mov    %esp,%ebp
80103d01:	56                   	push   %esi
80103d02:	53                   	push   %ebx
80103d03:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103d06:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d09:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103d0c:	eb 08                	jmp    80103d16 <memcmp+0x18>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80103d0e:	83 c1 01             	add    $0x1,%ecx
80103d11:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103d14:	89 f0                	mov    %esi,%eax
80103d16:	8d 70 ff             	lea    -0x1(%eax),%esi
80103d19:	85 c0                	test   %eax,%eax
80103d1b:	74 12                	je     80103d2f <memcmp+0x31>
    if(*s1 != *s2)
80103d1d:	0f b6 01             	movzbl (%ecx),%eax
80103d20:	0f b6 1a             	movzbl (%edx),%ebx
80103d23:	38 d8                	cmp    %bl,%al
80103d25:	74 e7                	je     80103d0e <memcmp+0x10>
      return *s1 - *s2;
80103d27:	0f b6 c0             	movzbl %al,%eax
80103d2a:	0f b6 db             	movzbl %bl,%ebx
80103d2d:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103d2f:	5b                   	pop    %ebx
80103d30:	5e                   	pop    %esi
80103d31:	5d                   	pop    %ebp
80103d32:	c3                   	ret    

80103d33 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103d33:	55                   	push   %ebp
80103d34:	89 e5                	mov    %esp,%ebp
80103d36:	56                   	push   %esi
80103d37:	53                   	push   %ebx
80103d38:	8b 75 08             	mov    0x8(%ebp),%esi
80103d3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d3e:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103d41:	39 f2                	cmp    %esi,%edx
80103d43:	73 3c                	jae    80103d81 <memmove+0x4e>
80103d45:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103d48:	39 f1                	cmp    %esi,%ecx
80103d4a:	76 39                	jbe    80103d85 <memmove+0x52>
    s += n;
    d += n;
80103d4c:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
80103d4f:	eb 0d                	jmp    80103d5e <memmove+0x2b>
      *--d = *--s;
80103d51:	83 e9 01             	sub    $0x1,%ecx
80103d54:	83 ea 01             	sub    $0x1,%edx
80103d57:	0f b6 01             	movzbl (%ecx),%eax
80103d5a:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80103d5c:	89 d8                	mov    %ebx,%eax
80103d5e:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103d61:	85 c0                	test   %eax,%eax
80103d63:	75 ec                	jne    80103d51 <memmove+0x1e>
80103d65:	eb 14                	jmp    80103d7b <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103d67:	0f b6 02             	movzbl (%edx),%eax
80103d6a:	88 01                	mov    %al,(%ecx)
80103d6c:	8d 49 01             	lea    0x1(%ecx),%ecx
80103d6f:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80103d72:	89 d8                	mov    %ebx,%eax
80103d74:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103d77:	85 c0                	test   %eax,%eax
80103d79:	75 ec                	jne    80103d67 <memmove+0x34>

  return dst;
}
80103d7b:	89 f0                	mov    %esi,%eax
80103d7d:	5b                   	pop    %ebx
80103d7e:	5e                   	pop    %esi
80103d7f:	5d                   	pop    %ebp
80103d80:	c3                   	ret    
80103d81:	89 f1                	mov    %esi,%ecx
80103d83:	eb ef                	jmp    80103d74 <memmove+0x41>
80103d85:	89 f1                	mov    %esi,%ecx
80103d87:	eb eb                	jmp    80103d74 <memmove+0x41>

80103d89 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103d89:	55                   	push   %ebp
80103d8a:	89 e5                	mov    %esp,%ebp
80103d8c:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80103d8f:	ff 75 10             	push   0x10(%ebp)
80103d92:	ff 75 0c             	push   0xc(%ebp)
80103d95:	ff 75 08             	push   0x8(%ebp)
80103d98:	e8 96 ff ff ff       	call   80103d33 <memmove>
}
80103d9d:	c9                   	leave  
80103d9e:	c3                   	ret    

80103d9f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103d9f:	55                   	push   %ebp
80103da0:	89 e5                	mov    %esp,%ebp
80103da2:	53                   	push   %ebx
80103da3:	8b 55 08             	mov    0x8(%ebp),%edx
80103da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103da9:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103dac:	eb 09                	jmp    80103db7 <strncmp+0x18>
    n--, p++, q++;
80103dae:	83 e8 01             	sub    $0x1,%eax
80103db1:	83 c2 01             	add    $0x1,%edx
80103db4:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103db7:	85 c0                	test   %eax,%eax
80103db9:	74 0b                	je     80103dc6 <strncmp+0x27>
80103dbb:	0f b6 1a             	movzbl (%edx),%ebx
80103dbe:	84 db                	test   %bl,%bl
80103dc0:	74 04                	je     80103dc6 <strncmp+0x27>
80103dc2:	3a 19                	cmp    (%ecx),%bl
80103dc4:	74 e8                	je     80103dae <strncmp+0xf>
  if(n == 0)
80103dc6:	85 c0                	test   %eax,%eax
80103dc8:	74 0d                	je     80103dd7 <strncmp+0x38>
    return 0;
  return (uchar)*p - (uchar)*q;
80103dca:	0f b6 02             	movzbl (%edx),%eax
80103dcd:	0f b6 11             	movzbl (%ecx),%edx
80103dd0:	29 d0                	sub    %edx,%eax
}
80103dd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dd5:	c9                   	leave  
80103dd6:	c3                   	ret    
    return 0;
80103dd7:	b8 00 00 00 00       	mov    $0x0,%eax
80103ddc:	eb f4                	jmp    80103dd2 <strncmp+0x33>

80103dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103dde:	55                   	push   %ebp
80103ddf:	89 e5                	mov    %esp,%ebp
80103de1:	57                   	push   %edi
80103de2:	56                   	push   %esi
80103de3:	53                   	push   %ebx
80103de4:	8b 7d 08             	mov    0x8(%ebp),%edi
80103de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103dea:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103ded:	89 fa                	mov    %edi,%edx
80103def:	eb 04                	jmp    80103df5 <strncpy+0x17>
80103df1:	89 f1                	mov    %esi,%ecx
80103df3:	89 da                	mov    %ebx,%edx
80103df5:	89 c3                	mov    %eax,%ebx
80103df7:	83 e8 01             	sub    $0x1,%eax
80103dfa:	85 db                	test   %ebx,%ebx
80103dfc:	7e 11                	jle    80103e0f <strncpy+0x31>
80103dfe:	8d 71 01             	lea    0x1(%ecx),%esi
80103e01:	8d 5a 01             	lea    0x1(%edx),%ebx
80103e04:	0f b6 09             	movzbl (%ecx),%ecx
80103e07:	88 0a                	mov    %cl,(%edx)
80103e09:	84 c9                	test   %cl,%cl
80103e0b:	75 e4                	jne    80103df1 <strncpy+0x13>
80103e0d:	89 da                	mov    %ebx,%edx
    ;
  while(n-- > 0)
80103e0f:	8d 48 ff             	lea    -0x1(%eax),%ecx
80103e12:	85 c0                	test   %eax,%eax
80103e14:	7e 0a                	jle    80103e20 <strncpy+0x42>
    *s++ = 0;
80103e16:	c6 02 00             	movb   $0x0,(%edx)
  while(n-- > 0)
80103e19:	89 c8                	mov    %ecx,%eax
    *s++ = 0;
80103e1b:	8d 52 01             	lea    0x1(%edx),%edx
80103e1e:	eb ef                	jmp    80103e0f <strncpy+0x31>
  return os;
}
80103e20:	89 f8                	mov    %edi,%eax
80103e22:	5b                   	pop    %ebx
80103e23:	5e                   	pop    %esi
80103e24:	5f                   	pop    %edi
80103e25:	5d                   	pop    %ebp
80103e26:	c3                   	ret    

80103e27 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103e27:	55                   	push   %ebp
80103e28:	89 e5                	mov    %esp,%ebp
80103e2a:	57                   	push   %edi
80103e2b:	56                   	push   %esi
80103e2c:	53                   	push   %ebx
80103e2d:	8b 7d 08             	mov    0x8(%ebp),%edi
80103e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e33:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80103e36:	85 c0                	test   %eax,%eax
80103e38:	7e 23                	jle    80103e5d <safestrcpy+0x36>
80103e3a:	89 fa                	mov    %edi,%edx
80103e3c:	eb 04                	jmp    80103e42 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103e3e:	89 f1                	mov    %esi,%ecx
80103e40:	89 da                	mov    %ebx,%edx
80103e42:	83 e8 01             	sub    $0x1,%eax
80103e45:	85 c0                	test   %eax,%eax
80103e47:	7e 11                	jle    80103e5a <safestrcpy+0x33>
80103e49:	8d 71 01             	lea    0x1(%ecx),%esi
80103e4c:	8d 5a 01             	lea    0x1(%edx),%ebx
80103e4f:	0f b6 09             	movzbl (%ecx),%ecx
80103e52:	88 0a                	mov    %cl,(%edx)
80103e54:	84 c9                	test   %cl,%cl
80103e56:	75 e6                	jne    80103e3e <safestrcpy+0x17>
80103e58:	89 da                	mov    %ebx,%edx
    ;
  *s = 0;
80103e5a:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80103e5d:	89 f8                	mov    %edi,%eax
80103e5f:	5b                   	pop    %ebx
80103e60:	5e                   	pop    %esi
80103e61:	5f                   	pop    %edi
80103e62:	5d                   	pop    %ebp
80103e63:	c3                   	ret    

80103e64 <strlen>:

int
strlen(const char *s)
{
80103e64:	55                   	push   %ebp
80103e65:	89 e5                	mov    %esp,%ebp
80103e67:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103e6a:	b8 00 00 00 00       	mov    $0x0,%eax
80103e6f:	eb 03                	jmp    80103e74 <strlen+0x10>
80103e71:	83 c0 01             	add    $0x1,%eax
80103e74:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103e78:	75 f7                	jne    80103e71 <strlen+0xd>
    ;
  return n;
}
80103e7a:	5d                   	pop    %ebp
80103e7b:	c3                   	ret    

80103e7c <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103e7c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103e80:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103e84:	55                   	push   %ebp
  pushl %ebx
80103e85:	53                   	push   %ebx
  pushl %esi
80103e86:	56                   	push   %esi
  pushl %edi
80103e87:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103e88:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103e8a:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103e8c:	5f                   	pop    %edi
  popl %esi
80103e8d:	5e                   	pop    %esi
  popl %ebx
80103e8e:	5b                   	pop    %ebx
  popl %ebp
80103e8f:	5d                   	pop    %ebp
  ret
80103e90:	c3                   	ret    

80103e91 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103e91:	55                   	push   %ebp
80103e92:	89 e5                	mov    %esp,%ebp
80103e94:	53                   	push   %ebx
80103e95:	83 ec 04             	sub    $0x4,%esp
80103e98:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103e9b:	e8 7a f3 ff ff       	call   8010321a <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103ea0:	8b 00                	mov    (%eax),%eax
80103ea2:	39 d8                	cmp    %ebx,%eax
80103ea4:	76 18                	jbe    80103ebe <fetchint+0x2d>
80103ea6:	8d 53 04             	lea    0x4(%ebx),%edx
80103ea9:	39 d0                	cmp    %edx,%eax
80103eab:	72 18                	jb     80103ec5 <fetchint+0x34>
    return -1;
  *ip = *(int*)(addr);
80103ead:	8b 13                	mov    (%ebx),%edx
80103eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eb2:	89 10                	mov    %edx,(%eax)
  return 0;
80103eb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103eb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ebc:	c9                   	leave  
80103ebd:	c3                   	ret    
    return -1;
80103ebe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ec3:	eb f4                	jmp    80103eb9 <fetchint+0x28>
80103ec5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103eca:	eb ed                	jmp    80103eb9 <fetchint+0x28>

80103ecc <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103ecc:	55                   	push   %ebp
80103ecd:	89 e5                	mov    %esp,%ebp
80103ecf:	53                   	push   %ebx
80103ed0:	83 ec 04             	sub    $0x4,%esp
80103ed3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103ed6:	e8 3f f3 ff ff       	call   8010321a <myproc>

  if(addr >= curproc->sz)
80103edb:	39 18                	cmp    %ebx,(%eax)
80103edd:	76 25                	jbe    80103f04 <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
80103edf:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ee2:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103ee4:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103ee6:	89 d8                	mov    %ebx,%eax
80103ee8:	eb 03                	jmp    80103eed <fetchstr+0x21>
80103eea:	83 c0 01             	add    $0x1,%eax
80103eed:	39 d0                	cmp    %edx,%eax
80103eef:	73 09                	jae    80103efa <fetchstr+0x2e>
    if(*s == 0)
80103ef1:	80 38 00             	cmpb   $0x0,(%eax)
80103ef4:	75 f4                	jne    80103eea <fetchstr+0x1e>
      return s - *pp;
80103ef6:	29 d8                	sub    %ebx,%eax
80103ef8:	eb 05                	jmp    80103eff <fetchstr+0x33>
  }
  return -1;
80103efa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103eff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f02:	c9                   	leave  
80103f03:	c3                   	ret    
    return -1;
80103f04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f09:	eb f4                	jmp    80103eff <fetchstr+0x33>

80103f0b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103f0b:	55                   	push   %ebp
80103f0c:	89 e5                	mov    %esp,%ebp
80103f0e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103f11:	e8 04 f3 ff ff       	call   8010321a <myproc>
80103f16:	8b 50 18             	mov    0x18(%eax),%edx
80103f19:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1c:	c1 e0 02             	shl    $0x2,%eax
80103f1f:	03 42 44             	add    0x44(%edx),%eax
80103f22:	83 ec 08             	sub    $0x8,%esp
80103f25:	ff 75 0c             	push   0xc(%ebp)
80103f28:	83 c0 04             	add    $0x4,%eax
80103f2b:	50                   	push   %eax
80103f2c:	e8 60 ff ff ff       	call   80103e91 <fetchint>
}
80103f31:	c9                   	leave  
80103f32:	c3                   	ret    

80103f33 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103f33:	55                   	push   %ebp
80103f34:	89 e5                	mov    %esp,%ebp
80103f36:	56                   	push   %esi
80103f37:	53                   	push   %ebx
80103f38:	83 ec 10             	sub    $0x10,%esp
80103f3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103f3e:	e8 d7 f2 ff ff       	call   8010321a <myproc>
80103f43:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103f45:	83 ec 08             	sub    $0x8,%esp
80103f48:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103f4b:	50                   	push   %eax
80103f4c:	ff 75 08             	push   0x8(%ebp)
80103f4f:	e8 b7 ff ff ff       	call   80103f0b <argint>
80103f54:	83 c4 10             	add    $0x10,%esp
80103f57:	85 c0                	test   %eax,%eax
80103f59:	78 24                	js     80103f7f <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103f5b:	85 db                	test   %ebx,%ebx
80103f5d:	78 27                	js     80103f86 <argptr+0x53>
80103f5f:	8b 16                	mov    (%esi),%edx
80103f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f64:	39 c2                	cmp    %eax,%edx
80103f66:	76 25                	jbe    80103f8d <argptr+0x5a>
80103f68:	01 c3                	add    %eax,%ebx
80103f6a:	39 da                	cmp    %ebx,%edx
80103f6c:	72 26                	jb     80103f94 <argptr+0x61>
    return -1;
  *pp = (char*)i;
80103f6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f71:	89 02                	mov    %eax,(%edx)
  return 0;
80103f73:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f78:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f7b:	5b                   	pop    %ebx
80103f7c:	5e                   	pop    %esi
80103f7d:	5d                   	pop    %ebp
80103f7e:	c3                   	ret    
    return -1;
80103f7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f84:	eb f2                	jmp    80103f78 <argptr+0x45>
    return -1;
80103f86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f8b:	eb eb                	jmp    80103f78 <argptr+0x45>
80103f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f92:	eb e4                	jmp    80103f78 <argptr+0x45>
80103f94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f99:	eb dd                	jmp    80103f78 <argptr+0x45>

80103f9b <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103f9b:	55                   	push   %ebp
80103f9c:	89 e5                	mov    %esp,%ebp
80103f9e:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103fa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103fa4:	50                   	push   %eax
80103fa5:	ff 75 08             	push   0x8(%ebp)
80103fa8:	e8 5e ff ff ff       	call   80103f0b <argint>
80103fad:	83 c4 10             	add    $0x10,%esp
80103fb0:	85 c0                	test   %eax,%eax
80103fb2:	78 13                	js     80103fc7 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80103fb4:	83 ec 08             	sub    $0x8,%esp
80103fb7:	ff 75 0c             	push   0xc(%ebp)
80103fba:	ff 75 f4             	push   -0xc(%ebp)
80103fbd:	e8 0a ff ff ff       	call   80103ecc <fetchstr>
80103fc2:	83 c4 10             	add    $0x10,%esp
}
80103fc5:	c9                   	leave  
80103fc6:	c3                   	ret    
    return -1;
80103fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fcc:	eb f7                	jmp    80103fc5 <argstr+0x2a>

80103fce <syscall>:

};

void
syscall(void)
{
80103fce:	55                   	push   %ebp
80103fcf:	89 e5                	mov    %esp,%ebp
80103fd1:	53                   	push   %ebx
80103fd2:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80103fd5:	e8 40 f2 ff ff       	call   8010321a <myproc>
80103fda:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80103fdc:	8b 40 18             	mov    0x18(%eax),%eax
80103fdf:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80103fe2:	8d 50 ff             	lea    -0x1(%eax),%edx
80103fe5:	83 fa 1a             	cmp    $0x1a,%edx
80103fe8:	77 17                	ja     80104001 <syscall+0x33>
80103fea:	8b 14 85 20 6f 10 80 	mov    -0x7fef90e0(,%eax,4),%edx
80103ff1:	85 d2                	test   %edx,%edx
80103ff3:	74 0c                	je     80104001 <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
80103ff5:	ff d2                	call   *%edx
80103ff7:	89 c2                	mov    %eax,%edx
80103ff9:	8b 43 18             	mov    0x18(%ebx),%eax
80103ffc:	89 50 1c             	mov    %edx,0x1c(%eax)
80103fff:	eb 1f                	jmp    80104020 <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104001:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104004:	50                   	push   %eax
80104005:	52                   	push   %edx
80104006:	ff 73 10             	push   0x10(%ebx)
80104009:	68 f5 6e 10 80       	push   $0x80106ef5
8010400e:	e8 f4 c5 ff ff       	call   80100607 <cprintf>
    curproc->tf->eax = -1;
80104013:	8b 43 18             	mov    0x18(%ebx),%eax
80104016:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010401d:	83 c4 10             	add    $0x10,%esp
  }
}
80104020:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104023:	c9                   	leave  
80104024:	c3                   	ret    

80104025 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104025:	55                   	push   %ebp
80104026:	89 e5                	mov    %esp,%ebp
80104028:	56                   	push   %esi
80104029:	53                   	push   %ebx
8010402a:	83 ec 18             	sub    $0x18,%esp
8010402d:	89 d6                	mov    %edx,%esi
8010402f:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104031:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104034:	52                   	push   %edx
80104035:	50                   	push   %eax
80104036:	e8 d0 fe ff ff       	call   80103f0b <argint>
8010403b:	83 c4 10             	add    $0x10,%esp
8010403e:	85 c0                	test   %eax,%eax
80104040:	78 35                	js     80104077 <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104042:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104046:	77 28                	ja     80104070 <argfd+0x4b>
80104048:	e8 cd f1 ff ff       	call   8010321a <myproc>
8010404d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104050:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104054:	85 c0                	test   %eax,%eax
80104056:	74 18                	je     80104070 <argfd+0x4b>
    return -1;
  if(pfd)
80104058:	85 f6                	test   %esi,%esi
8010405a:	74 02                	je     8010405e <argfd+0x39>
    *pfd = fd;
8010405c:	89 16                	mov    %edx,(%esi)
  if(pf)
8010405e:	85 db                	test   %ebx,%ebx
80104060:	74 1c                	je     8010407e <argfd+0x59>
    *pf = f;
80104062:	89 03                	mov    %eax,(%ebx)
  return 0;
80104064:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104069:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010406c:	5b                   	pop    %ebx
8010406d:	5e                   	pop    %esi
8010406e:	5d                   	pop    %ebp
8010406f:	c3                   	ret    
    return -1;
80104070:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104075:	eb f2                	jmp    80104069 <argfd+0x44>
    return -1;
80104077:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010407c:	eb eb                	jmp    80104069 <argfd+0x44>
  return 0;
8010407e:	b8 00 00 00 00       	mov    $0x0,%eax
80104083:	eb e4                	jmp    80104069 <argfd+0x44>

80104085 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104085:	55                   	push   %ebp
80104086:	89 e5                	mov    %esp,%ebp
80104088:	53                   	push   %ebx
80104089:	83 ec 04             	sub    $0x4,%esp
8010408c:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
8010408e:	e8 87 f1 ff ff       	call   8010321a <myproc>
80104093:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
80104095:	b8 00 00 00 00       	mov    $0x0,%eax
8010409a:	83 f8 0f             	cmp    $0xf,%eax
8010409d:	7f 12                	jg     801040b1 <fdalloc+0x2c>
    if(curproc->ofile[fd] == 0){
8010409f:	83 7c 82 28 00       	cmpl   $0x0,0x28(%edx,%eax,4)
801040a4:	74 05                	je     801040ab <fdalloc+0x26>
  for(fd = 0; fd < NOFILE; fd++){
801040a6:	83 c0 01             	add    $0x1,%eax
801040a9:	eb ef                	jmp    8010409a <fdalloc+0x15>
      curproc->ofile[fd] = f;
801040ab:	89 5c 82 28          	mov    %ebx,0x28(%edx,%eax,4)
      return fd;
801040af:	eb 05                	jmp    801040b6 <fdalloc+0x31>
    }
  }
  return -1;
801040b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040b9:	c9                   	leave  
801040ba:	c3                   	ret    

801040bb <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801040bb:	55                   	push   %ebp
801040bc:	89 e5                	mov    %esp,%ebp
801040be:	56                   	push   %esi
801040bf:	53                   	push   %ebx
801040c0:	83 ec 10             	sub    $0x10,%esp
801040c3:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801040c5:	b8 20 00 00 00       	mov    $0x20,%eax
801040ca:	89 c6                	mov    %eax,%esi
801040cc:	39 43 58             	cmp    %eax,0x58(%ebx)
801040cf:	76 2e                	jbe    801040ff <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801040d1:	6a 10                	push   $0x10
801040d3:	50                   	push   %eax
801040d4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801040d7:	50                   	push   %eax
801040d8:	53                   	push   %ebx
801040d9:	e8 83 d6 ff ff       	call   80101761 <readi>
801040de:	83 c4 10             	add    $0x10,%esp
801040e1:	83 f8 10             	cmp    $0x10,%eax
801040e4:	75 0c                	jne    801040f2 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
801040e6:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
801040eb:	75 1e                	jne    8010410b <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801040ed:	8d 46 10             	lea    0x10(%esi),%eax
801040f0:	eb d8                	jmp    801040ca <isdirempty+0xf>
      panic("isdirempty: readi");
801040f2:	83 ec 0c             	sub    $0xc,%esp
801040f5:	68 90 6f 10 80       	push   $0x80106f90
801040fa:	e8 49 c2 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
801040ff:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104104:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104107:	5b                   	pop    %ebx
80104108:	5e                   	pop    %esi
80104109:	5d                   	pop    %ebp
8010410a:	c3                   	ret    
      return 0;
8010410b:	b8 00 00 00 00       	mov    $0x0,%eax
80104110:	eb f2                	jmp    80104104 <isdirempty+0x49>

80104112 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104112:	55                   	push   %ebp
80104113:	89 e5                	mov    %esp,%ebp
80104115:	57                   	push   %edi
80104116:	56                   	push   %esi
80104117:	53                   	push   %ebx
80104118:	83 ec 34             	sub    $0x34,%esp
8010411b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010411e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104121:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104124:	8d 55 da             	lea    -0x26(%ebp),%edx
80104127:	52                   	push   %edx
80104128:	50                   	push   %eax
80104129:	e8 b7 da ff ff       	call   80101be5 <nameiparent>
8010412e:	89 c6                	mov    %eax,%esi
80104130:	83 c4 10             	add    $0x10,%esp
80104133:	85 c0                	test   %eax,%eax
80104135:	0f 84 33 01 00 00    	je     8010426e <create+0x15c>
    return 0;
  ilock(dp);
8010413b:	83 ec 0c             	sub    $0xc,%esp
8010413e:	50                   	push   %eax
8010413f:	e8 2b d4 ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104144:	83 c4 0c             	add    $0xc,%esp
80104147:	6a 00                	push   $0x0
80104149:	8d 45 da             	lea    -0x26(%ebp),%eax
8010414c:	50                   	push   %eax
8010414d:	56                   	push   %esi
8010414e:	e8 4c d8 ff ff       	call   8010199f <dirlookup>
80104153:	89 c3                	mov    %eax,%ebx
80104155:	83 c4 10             	add    $0x10,%esp
80104158:	85 c0                	test   %eax,%eax
8010415a:	74 3d                	je     80104199 <create+0x87>
    iunlockput(dp);
8010415c:	83 ec 0c             	sub    $0xc,%esp
8010415f:	56                   	push   %esi
80104160:	e8 b1 d5 ff ff       	call   80101716 <iunlockput>
    ilock(ip);
80104165:	89 1c 24             	mov    %ebx,(%esp)
80104168:	e8 02 d4 ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010416d:	83 c4 10             	add    $0x10,%esp
80104170:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104175:	75 07                	jne    8010417e <create+0x6c>
80104177:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
8010417c:	74 11                	je     8010418f <create+0x7d>
      return ip;
    iunlockput(ip);
8010417e:	83 ec 0c             	sub    $0xc,%esp
80104181:	53                   	push   %ebx
80104182:	e8 8f d5 ff ff       	call   80101716 <iunlockput>
    return 0;
80104187:	83 c4 10             	add    $0x10,%esp
8010418a:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010418f:	89 d8                	mov    %ebx,%eax
80104191:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104194:	5b                   	pop    %ebx
80104195:	5e                   	pop    %esi
80104196:	5f                   	pop    %edi
80104197:	5d                   	pop    %ebp
80104198:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104199:	83 ec 08             	sub    $0x8,%esp
8010419c:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
801041a0:	50                   	push   %eax
801041a1:	ff 36                	push   (%esi)
801041a3:	e8 c4 d1 ff ff       	call   8010136c <ialloc>
801041a8:	89 c3                	mov    %eax,%ebx
801041aa:	83 c4 10             	add    $0x10,%esp
801041ad:	85 c0                	test   %eax,%eax
801041af:	74 52                	je     80104203 <create+0xf1>
  ilock(ip);
801041b1:	83 ec 0c             	sub    $0xc,%esp
801041b4:	50                   	push   %eax
801041b5:	e8 b5 d3 ff ff       	call   8010156f <ilock>
  ip->major = major;
801041ba:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
801041be:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801041c2:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801041c6:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801041cc:	89 1c 24             	mov    %ebx,(%esp)
801041cf:	e8 3a d2 ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801041d4:	83 c4 10             	add    $0x10,%esp
801041d7:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801041dc:	74 32                	je     80104210 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
801041de:	83 ec 04             	sub    $0x4,%esp
801041e1:	ff 73 04             	push   0x4(%ebx)
801041e4:	8d 45 da             	lea    -0x26(%ebp),%eax
801041e7:	50                   	push   %eax
801041e8:	56                   	push   %esi
801041e9:	e8 2e d9 ff ff       	call   80101b1c <dirlink>
801041ee:	83 c4 10             	add    $0x10,%esp
801041f1:	85 c0                	test   %eax,%eax
801041f3:	78 6c                	js     80104261 <create+0x14f>
  iunlockput(dp);
801041f5:	83 ec 0c             	sub    $0xc,%esp
801041f8:	56                   	push   %esi
801041f9:	e8 18 d5 ff ff       	call   80101716 <iunlockput>
  return ip;
801041fe:	83 c4 10             	add    $0x10,%esp
80104201:	eb 8c                	jmp    8010418f <create+0x7d>
    panic("create: ialloc");
80104203:	83 ec 0c             	sub    $0xc,%esp
80104206:	68 a2 6f 10 80       	push   $0x80106fa2
8010420b:	e8 38 c1 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104210:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104214:	83 c0 01             	add    $0x1,%eax
80104217:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010421b:	83 ec 0c             	sub    $0xc,%esp
8010421e:	56                   	push   %esi
8010421f:	e8 ea d1 ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104224:	83 c4 0c             	add    $0xc,%esp
80104227:	ff 73 04             	push   0x4(%ebx)
8010422a:	68 b2 6f 10 80       	push   $0x80106fb2
8010422f:	53                   	push   %ebx
80104230:	e8 e7 d8 ff ff       	call   80101b1c <dirlink>
80104235:	83 c4 10             	add    $0x10,%esp
80104238:	85 c0                	test   %eax,%eax
8010423a:	78 18                	js     80104254 <create+0x142>
8010423c:	83 ec 04             	sub    $0x4,%esp
8010423f:	ff 76 04             	push   0x4(%esi)
80104242:	68 b1 6f 10 80       	push   $0x80106fb1
80104247:	53                   	push   %ebx
80104248:	e8 cf d8 ff ff       	call   80101b1c <dirlink>
8010424d:	83 c4 10             	add    $0x10,%esp
80104250:	85 c0                	test   %eax,%eax
80104252:	79 8a                	jns    801041de <create+0xcc>
      panic("create dots");
80104254:	83 ec 0c             	sub    $0xc,%esp
80104257:	68 b4 6f 10 80       	push   $0x80106fb4
8010425c:	e8 e7 c0 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
80104261:	83 ec 0c             	sub    $0xc,%esp
80104264:	68 c0 6f 10 80       	push   $0x80106fc0
80104269:	e8 da c0 ff ff       	call   80100348 <panic>
    return 0;
8010426e:	89 c3                	mov    %eax,%ebx
80104270:	e9 1a ff ff ff       	jmp    8010418f <create+0x7d>

80104275 <sys_settickets>:
int sys_settickets(void) {
80104275:	55                   	push   %ebp
80104276:	89 e5                	mov    %esp,%ebp
80104278:	83 ec 20             	sub    $0x20,%esp
  if(argint(0, &i) < 0){
8010427b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010427e:	50                   	push   %eax
8010427f:	6a 00                	push   $0x0
80104281:	e8 85 fc ff ff       	call   80103f0b <argint>
80104286:	83 c4 10             	add    $0x10,%esp
80104289:	85 c0                	test   %eax,%eax
8010428b:	78 0f                	js     8010429c <sys_settickets+0x27>
  tickets = i;
8010428d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104290:	a3 58 3d 11 80       	mov    %eax,0x80113d58
  return 0;
80104295:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010429a:	c9                   	leave  
8010429b:	c3                   	ret    
    return -1;
8010429c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a1:	eb f7                	jmp    8010429a <sys_settickets+0x25>

801042a3 <sys_writecount>:
  w_count++;
801042a3:	a1 5c 3d 11 80       	mov    0x80113d5c,%eax
801042a8:	83 c0 01             	add    $0x1,%eax
801042ab:	a3 5c 3d 11 80       	mov    %eax,0x80113d5c
}
801042b0:	c3                   	ret    

801042b1 <sys_setwritecount>:
sys_setwritecount(void) {
801042b1:	55                   	push   %ebp
801042b2:	89 e5                	mov    %esp,%ebp
801042b4:	83 ec 20             	sub    $0x20,%esp
  if(argint(0, &i) < 0){
801042b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801042ba:	50                   	push   %eax
801042bb:	6a 00                	push   $0x0
801042bd:	e8 49 fc ff ff       	call   80103f0b <argint>
801042c2:	83 c4 10             	add    $0x10,%esp
801042c5:	85 c0                	test   %eax,%eax
801042c7:	78 0f                	js     801042d8 <sys_setwritecount+0x27>
  w_count = i;
801042c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cc:	a3 5c 3d 11 80       	mov    %eax,0x80113d5c
  return 0;
801042d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042d6:	c9                   	leave  
801042d7:	c3                   	ret    
    return -1;
801042d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042dd:	eb f7                	jmp    801042d6 <sys_setwritecount+0x25>

801042df <sys_dup>:
{
801042df:	55                   	push   %ebp
801042e0:	89 e5                	mov    %esp,%ebp
801042e2:	53                   	push   %ebx
801042e3:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801042e6:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801042e9:	ba 00 00 00 00       	mov    $0x0,%edx
801042ee:	b8 00 00 00 00       	mov    $0x0,%eax
801042f3:	e8 2d fd ff ff       	call   80104025 <argfd>
801042f8:	85 c0                	test   %eax,%eax
801042fa:	78 23                	js     8010431f <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801042fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ff:	e8 81 fd ff ff       	call   80104085 <fdalloc>
80104304:	89 c3                	mov    %eax,%ebx
80104306:	85 c0                	test   %eax,%eax
80104308:	78 1c                	js     80104326 <sys_dup+0x47>
  filedup(f);
8010430a:	83 ec 0c             	sub    $0xc,%esp
8010430d:	ff 75 f4             	push   -0xc(%ebp)
80104310:	e8 69 c9 ff ff       	call   80100c7e <filedup>
  return fd;
80104315:	83 c4 10             	add    $0x10,%esp
}
80104318:	89 d8                	mov    %ebx,%eax
8010431a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010431d:	c9                   	leave  
8010431e:	c3                   	ret    
    return -1;
8010431f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104324:	eb f2                	jmp    80104318 <sys_dup+0x39>
    return -1;
80104326:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010432b:	eb eb                	jmp    80104318 <sys_dup+0x39>

8010432d <sys_read>:
{
8010432d:	55                   	push   %ebp
8010432e:	89 e5                	mov    %esp,%ebp
80104330:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104333:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104336:	ba 00 00 00 00       	mov    $0x0,%edx
8010433b:	b8 00 00 00 00       	mov    $0x0,%eax
80104340:	e8 e0 fc ff ff       	call   80104025 <argfd>
80104345:	85 c0                	test   %eax,%eax
80104347:	78 43                	js     8010438c <sys_read+0x5f>
80104349:	83 ec 08             	sub    $0x8,%esp
8010434c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010434f:	50                   	push   %eax
80104350:	6a 02                	push   $0x2
80104352:	e8 b4 fb ff ff       	call   80103f0b <argint>
80104357:	83 c4 10             	add    $0x10,%esp
8010435a:	85 c0                	test   %eax,%eax
8010435c:	78 2e                	js     8010438c <sys_read+0x5f>
8010435e:	83 ec 04             	sub    $0x4,%esp
80104361:	ff 75 f0             	push   -0x10(%ebp)
80104364:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104367:	50                   	push   %eax
80104368:	6a 01                	push   $0x1
8010436a:	e8 c4 fb ff ff       	call   80103f33 <argptr>
8010436f:	83 c4 10             	add    $0x10,%esp
80104372:	85 c0                	test   %eax,%eax
80104374:	78 16                	js     8010438c <sys_read+0x5f>
  return fileread(f, p, n);
80104376:	83 ec 04             	sub    $0x4,%esp
80104379:	ff 75 f0             	push   -0x10(%ebp)
8010437c:	ff 75 ec             	push   -0x14(%ebp)
8010437f:	ff 75 f4             	push   -0xc(%ebp)
80104382:	e8 49 ca ff ff       	call   80100dd0 <fileread>
80104387:	83 c4 10             	add    $0x10,%esp
}
8010438a:	c9                   	leave  
8010438b:	c3                   	ret    
    return -1;
8010438c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104391:	eb f7                	jmp    8010438a <sys_read+0x5d>

80104393 <sys_write>:
{
80104393:	55                   	push   %ebp
80104394:	89 e5                	mov    %esp,%ebp
80104396:	83 ec 18             	sub    $0x18,%esp
  sys_writecount(); // ADDED THIS LINE
80104399:	e8 05 ff ff ff       	call   801042a3 <sys_writecount>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010439e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043a1:	ba 00 00 00 00       	mov    $0x0,%edx
801043a6:	b8 00 00 00 00       	mov    $0x0,%eax
801043ab:	e8 75 fc ff ff       	call   80104025 <argfd>
801043b0:	85 c0                	test   %eax,%eax
801043b2:	78 43                	js     801043f7 <sys_write+0x64>
801043b4:	83 ec 08             	sub    $0x8,%esp
801043b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801043ba:	50                   	push   %eax
801043bb:	6a 02                	push   $0x2
801043bd:	e8 49 fb ff ff       	call   80103f0b <argint>
801043c2:	83 c4 10             	add    $0x10,%esp
801043c5:	85 c0                	test   %eax,%eax
801043c7:	78 2e                	js     801043f7 <sys_write+0x64>
801043c9:	83 ec 04             	sub    $0x4,%esp
801043cc:	ff 75 f0             	push   -0x10(%ebp)
801043cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801043d2:	50                   	push   %eax
801043d3:	6a 01                	push   $0x1
801043d5:	e8 59 fb ff ff       	call   80103f33 <argptr>
801043da:	83 c4 10             	add    $0x10,%esp
801043dd:	85 c0                	test   %eax,%eax
801043df:	78 16                	js     801043f7 <sys_write+0x64>
  return filewrite(f, p, n);
801043e1:	83 ec 04             	sub    $0x4,%esp
801043e4:	ff 75 f0             	push   -0x10(%ebp)
801043e7:	ff 75 ec             	push   -0x14(%ebp)
801043ea:	ff 75 f4             	push   -0xc(%ebp)
801043ed:	e8 63 ca ff ff       	call   80100e55 <filewrite>
801043f2:	83 c4 10             	add    $0x10,%esp
}
801043f5:	c9                   	leave  
801043f6:	c3                   	ret    
    return -1;
801043f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043fc:	eb f7                	jmp    801043f5 <sys_write+0x62>

801043fe <sys_close>:
{
801043fe:	55                   	push   %ebp
801043ff:	89 e5                	mov    %esp,%ebp
80104401:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104404:	8d 4d f0             	lea    -0x10(%ebp),%ecx
80104407:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010440a:	b8 00 00 00 00       	mov    $0x0,%eax
8010440f:	e8 11 fc ff ff       	call   80104025 <argfd>
80104414:	85 c0                	test   %eax,%eax
80104416:	78 25                	js     8010443d <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
80104418:	e8 fd ed ff ff       	call   8010321a <myproc>
8010441d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104420:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104427:	00 
  fileclose(f);
80104428:	83 ec 0c             	sub    $0xc,%esp
8010442b:	ff 75 f0             	push   -0x10(%ebp)
8010442e:	e8 90 c8 ff ff       	call   80100cc3 <fileclose>
  return 0;
80104433:	83 c4 10             	add    $0x10,%esp
80104436:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010443b:	c9                   	leave  
8010443c:	c3                   	ret    
    return -1;
8010443d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104442:	eb f7                	jmp    8010443b <sys_close+0x3d>

80104444 <sys_fstat>:
{
80104444:	55                   	push   %ebp
80104445:	89 e5                	mov    %esp,%ebp
80104447:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010444a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010444d:	ba 00 00 00 00       	mov    $0x0,%edx
80104452:	b8 00 00 00 00       	mov    $0x0,%eax
80104457:	e8 c9 fb ff ff       	call   80104025 <argfd>
8010445c:	85 c0                	test   %eax,%eax
8010445e:	78 2a                	js     8010448a <sys_fstat+0x46>
80104460:	83 ec 04             	sub    $0x4,%esp
80104463:	6a 14                	push   $0x14
80104465:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104468:	50                   	push   %eax
80104469:	6a 01                	push   $0x1
8010446b:	e8 c3 fa ff ff       	call   80103f33 <argptr>
80104470:	83 c4 10             	add    $0x10,%esp
80104473:	85 c0                	test   %eax,%eax
80104475:	78 13                	js     8010448a <sys_fstat+0x46>
  return filestat(f, st);
80104477:	83 ec 08             	sub    $0x8,%esp
8010447a:	ff 75 f0             	push   -0x10(%ebp)
8010447d:	ff 75 f4             	push   -0xc(%ebp)
80104480:	e8 04 c9 ff ff       	call   80100d89 <filestat>
80104485:	83 c4 10             	add    $0x10,%esp
}
80104488:	c9                   	leave  
80104489:	c3                   	ret    
    return -1;
8010448a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010448f:	eb f7                	jmp    80104488 <sys_fstat+0x44>

80104491 <sys_link>:
{
80104491:	55                   	push   %ebp
80104492:	89 e5                	mov    %esp,%ebp
80104494:	56                   	push   %esi
80104495:	53                   	push   %ebx
80104496:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104499:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010449c:	50                   	push   %eax
8010449d:	6a 00                	push   $0x0
8010449f:	e8 f7 fa ff ff       	call   80103f9b <argstr>
801044a4:	83 c4 10             	add    $0x10,%esp
801044a7:	85 c0                	test   %eax,%eax
801044a9:	0f 88 d3 00 00 00    	js     80104582 <sys_link+0xf1>
801044af:	83 ec 08             	sub    $0x8,%esp
801044b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801044b5:	50                   	push   %eax
801044b6:	6a 01                	push   $0x1
801044b8:	e8 de fa ff ff       	call   80103f9b <argstr>
801044bd:	83 c4 10             	add    $0x10,%esp
801044c0:	85 c0                	test   %eax,%eax
801044c2:	0f 88 ba 00 00 00    	js     80104582 <sys_link+0xf1>
  begin_op();
801044c8:	e8 e3 e2 ff ff       	call   801027b0 <begin_op>
  if((ip = namei(old)) == 0){
801044cd:	83 ec 0c             	sub    $0xc,%esp
801044d0:	ff 75 e0             	push   -0x20(%ebp)
801044d3:	e8 f5 d6 ff ff       	call   80101bcd <namei>
801044d8:	89 c3                	mov    %eax,%ebx
801044da:	83 c4 10             	add    $0x10,%esp
801044dd:	85 c0                	test   %eax,%eax
801044df:	0f 84 a4 00 00 00    	je     80104589 <sys_link+0xf8>
  ilock(ip);
801044e5:	83 ec 0c             	sub    $0xc,%esp
801044e8:	50                   	push   %eax
801044e9:	e8 81 d0 ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
801044ee:	83 c4 10             	add    $0x10,%esp
801044f1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801044f6:	0f 84 99 00 00 00    	je     80104595 <sys_link+0x104>
  ip->nlink++;
801044fc:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104500:	83 c0 01             	add    $0x1,%eax
80104503:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104507:	83 ec 0c             	sub    $0xc,%esp
8010450a:	53                   	push   %ebx
8010450b:	e8 fe ce ff ff       	call   8010140e <iupdate>
  iunlock(ip);
80104510:	89 1c 24             	mov    %ebx,(%esp)
80104513:	e8 19 d1 ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104518:	83 c4 08             	add    $0x8,%esp
8010451b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010451e:	50                   	push   %eax
8010451f:	ff 75 e4             	push   -0x1c(%ebp)
80104522:	e8 be d6 ff ff       	call   80101be5 <nameiparent>
80104527:	89 c6                	mov    %eax,%esi
80104529:	83 c4 10             	add    $0x10,%esp
8010452c:	85 c0                	test   %eax,%eax
8010452e:	0f 84 85 00 00 00    	je     801045b9 <sys_link+0x128>
  ilock(dp);
80104534:	83 ec 0c             	sub    $0xc,%esp
80104537:	50                   	push   %eax
80104538:	e8 32 d0 ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010453d:	83 c4 10             	add    $0x10,%esp
80104540:	8b 03                	mov    (%ebx),%eax
80104542:	39 06                	cmp    %eax,(%esi)
80104544:	75 67                	jne    801045ad <sys_link+0x11c>
80104546:	83 ec 04             	sub    $0x4,%esp
80104549:	ff 73 04             	push   0x4(%ebx)
8010454c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010454f:	50                   	push   %eax
80104550:	56                   	push   %esi
80104551:	e8 c6 d5 ff ff       	call   80101b1c <dirlink>
80104556:	83 c4 10             	add    $0x10,%esp
80104559:	85 c0                	test   %eax,%eax
8010455b:	78 50                	js     801045ad <sys_link+0x11c>
  iunlockput(dp);
8010455d:	83 ec 0c             	sub    $0xc,%esp
80104560:	56                   	push   %esi
80104561:	e8 b0 d1 ff ff       	call   80101716 <iunlockput>
  iput(ip);
80104566:	89 1c 24             	mov    %ebx,(%esp)
80104569:	e8 08 d1 ff ff       	call   80101676 <iput>
  end_op();
8010456e:	e8 b7 e2 ff ff       	call   8010282a <end_op>
  return 0;
80104573:	83 c4 10             	add    $0x10,%esp
80104576:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010457b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010457e:	5b                   	pop    %ebx
8010457f:	5e                   	pop    %esi
80104580:	5d                   	pop    %ebp
80104581:	c3                   	ret    
    return -1;
80104582:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104587:	eb f2                	jmp    8010457b <sys_link+0xea>
    end_op();
80104589:	e8 9c e2 ff ff       	call   8010282a <end_op>
    return -1;
8010458e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104593:	eb e6                	jmp    8010457b <sys_link+0xea>
    iunlockput(ip);
80104595:	83 ec 0c             	sub    $0xc,%esp
80104598:	53                   	push   %ebx
80104599:	e8 78 d1 ff ff       	call   80101716 <iunlockput>
    end_op();
8010459e:	e8 87 e2 ff ff       	call   8010282a <end_op>
    return -1;
801045a3:	83 c4 10             	add    $0x10,%esp
801045a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ab:	eb ce                	jmp    8010457b <sys_link+0xea>
    iunlockput(dp);
801045ad:	83 ec 0c             	sub    $0xc,%esp
801045b0:	56                   	push   %esi
801045b1:	e8 60 d1 ff ff       	call   80101716 <iunlockput>
    goto bad;
801045b6:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801045b9:	83 ec 0c             	sub    $0xc,%esp
801045bc:	53                   	push   %ebx
801045bd:	e8 ad cf ff ff       	call   8010156f <ilock>
  ip->nlink--;
801045c2:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045c6:	83 e8 01             	sub    $0x1,%eax
801045c9:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045cd:	89 1c 24             	mov    %ebx,(%esp)
801045d0:	e8 39 ce ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
801045d5:	89 1c 24             	mov    %ebx,(%esp)
801045d8:	e8 39 d1 ff ff       	call   80101716 <iunlockput>
  end_op();
801045dd:	e8 48 e2 ff ff       	call   8010282a <end_op>
  return -1;
801045e2:	83 c4 10             	add    $0x10,%esp
801045e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ea:	eb 8f                	jmp    8010457b <sys_link+0xea>

801045ec <sys_unlink>:
{
801045ec:	55                   	push   %ebp
801045ed:	89 e5                	mov    %esp,%ebp
801045ef:	57                   	push   %edi
801045f0:	56                   	push   %esi
801045f1:	53                   	push   %ebx
801045f2:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801045f5:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801045f8:	50                   	push   %eax
801045f9:	6a 00                	push   $0x0
801045fb:	e8 9b f9 ff ff       	call   80103f9b <argstr>
80104600:	83 c4 10             	add    $0x10,%esp
80104603:	85 c0                	test   %eax,%eax
80104605:	0f 88 83 01 00 00    	js     8010478e <sys_unlink+0x1a2>
  begin_op();
8010460b:	e8 a0 e1 ff ff       	call   801027b0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104610:	83 ec 08             	sub    $0x8,%esp
80104613:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104616:	50                   	push   %eax
80104617:	ff 75 c4             	push   -0x3c(%ebp)
8010461a:	e8 c6 d5 ff ff       	call   80101be5 <nameiparent>
8010461f:	89 c6                	mov    %eax,%esi
80104621:	83 c4 10             	add    $0x10,%esp
80104624:	85 c0                	test   %eax,%eax
80104626:	0f 84 ed 00 00 00    	je     80104719 <sys_unlink+0x12d>
  ilock(dp);
8010462c:	83 ec 0c             	sub    $0xc,%esp
8010462f:	50                   	push   %eax
80104630:	e8 3a cf ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104635:	83 c4 08             	add    $0x8,%esp
80104638:	68 b2 6f 10 80       	push   $0x80106fb2
8010463d:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104640:	50                   	push   %eax
80104641:	e8 44 d3 ff ff       	call   8010198a <namecmp>
80104646:	83 c4 10             	add    $0x10,%esp
80104649:	85 c0                	test   %eax,%eax
8010464b:	0f 84 fc 00 00 00    	je     8010474d <sys_unlink+0x161>
80104651:	83 ec 08             	sub    $0x8,%esp
80104654:	68 b1 6f 10 80       	push   $0x80106fb1
80104659:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010465c:	50                   	push   %eax
8010465d:	e8 28 d3 ff ff       	call   8010198a <namecmp>
80104662:	83 c4 10             	add    $0x10,%esp
80104665:	85 c0                	test   %eax,%eax
80104667:	0f 84 e0 00 00 00    	je     8010474d <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010466d:	83 ec 04             	sub    $0x4,%esp
80104670:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104673:	50                   	push   %eax
80104674:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104677:	50                   	push   %eax
80104678:	56                   	push   %esi
80104679:	e8 21 d3 ff ff       	call   8010199f <dirlookup>
8010467e:	89 c3                	mov    %eax,%ebx
80104680:	83 c4 10             	add    $0x10,%esp
80104683:	85 c0                	test   %eax,%eax
80104685:	0f 84 c2 00 00 00    	je     8010474d <sys_unlink+0x161>
  ilock(ip);
8010468b:	83 ec 0c             	sub    $0xc,%esp
8010468e:	50                   	push   %eax
8010468f:	e8 db ce ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
80104694:	83 c4 10             	add    $0x10,%esp
80104697:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010469c:	0f 8e 83 00 00 00    	jle    80104725 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801046a2:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046a7:	0f 84 85 00 00 00    	je     80104732 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801046ad:	83 ec 04             	sub    $0x4,%esp
801046b0:	6a 10                	push   $0x10
801046b2:	6a 00                	push   $0x0
801046b4:	8d 7d d8             	lea    -0x28(%ebp),%edi
801046b7:	57                   	push   %edi
801046b8:	e8 fe f5 ff ff       	call   80103cbb <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801046bd:	6a 10                	push   $0x10
801046bf:	ff 75 c0             	push   -0x40(%ebp)
801046c2:	57                   	push   %edi
801046c3:	56                   	push   %esi
801046c4:	e8 95 d1 ff ff       	call   8010185e <writei>
801046c9:	83 c4 20             	add    $0x20,%esp
801046cc:	83 f8 10             	cmp    $0x10,%eax
801046cf:	0f 85 90 00 00 00    	jne    80104765 <sys_unlink+0x179>
  if(ip->type == T_DIR){
801046d5:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046da:	0f 84 92 00 00 00    	je     80104772 <sys_unlink+0x186>
  iunlockput(dp);
801046e0:	83 ec 0c             	sub    $0xc,%esp
801046e3:	56                   	push   %esi
801046e4:	e8 2d d0 ff ff       	call   80101716 <iunlockput>
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
  return 0;
80104709:	83 c4 10             	add    $0x10,%esp
8010470c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104711:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104714:	5b                   	pop    %ebx
80104715:	5e                   	pop    %esi
80104716:	5f                   	pop    %edi
80104717:	5d                   	pop    %ebp
80104718:	c3                   	ret    
    end_op();
80104719:	e8 0c e1 ff ff       	call   8010282a <end_op>
    return -1;
8010471e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104723:	eb ec                	jmp    80104711 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104725:	83 ec 0c             	sub    $0xc,%esp
80104728:	68 d0 6f 10 80       	push   $0x80106fd0
8010472d:	e8 16 bc ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104732:	89 d8                	mov    %ebx,%eax
80104734:	e8 82 f9 ff ff       	call   801040bb <isdirempty>
80104739:	85 c0                	test   %eax,%eax
8010473b:	0f 85 6c ff ff ff    	jne    801046ad <sys_unlink+0xc1>
    iunlockput(ip);
80104741:	83 ec 0c             	sub    $0xc,%esp
80104744:	53                   	push   %ebx
80104745:	e8 cc cf ff ff       	call   80101716 <iunlockput>
    goto bad;
8010474a:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010474d:	83 ec 0c             	sub    $0xc,%esp
80104750:	56                   	push   %esi
80104751:	e8 c0 cf ff ff       	call   80101716 <iunlockput>
  end_op();
80104756:	e8 cf e0 ff ff       	call   8010282a <end_op>
  return -1;
8010475b:	83 c4 10             	add    $0x10,%esp
8010475e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104763:	eb ac                	jmp    80104711 <sys_unlink+0x125>
    panic("unlink: writei");
80104765:	83 ec 0c             	sub    $0xc,%esp
80104768:	68 e2 6f 10 80       	push   $0x80106fe2
8010476d:	e8 d6 bb ff ff       	call   80100348 <panic>
    dp->nlink--;
80104772:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104776:	83 e8 01             	sub    $0x1,%eax
80104779:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010477d:	83 ec 0c             	sub    $0xc,%esp
80104780:	56                   	push   %esi
80104781:	e8 88 cc ff ff       	call   8010140e <iupdate>
80104786:	83 c4 10             	add    $0x10,%esp
80104789:	e9 52 ff ff ff       	jmp    801046e0 <sys_unlink+0xf4>
    return -1;
8010478e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104793:	e9 79 ff ff ff       	jmp    80104711 <sys_unlink+0x125>

80104798 <sys_open>:

int
sys_open(void)
{
80104798:	55                   	push   %ebp
80104799:	89 e5                	mov    %esp,%ebp
8010479b:	57                   	push   %edi
8010479c:	56                   	push   %esi
8010479d:	53                   	push   %ebx
8010479e:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801047a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801047a4:	50                   	push   %eax
801047a5:	6a 00                	push   $0x0
801047a7:	e8 ef f7 ff ff       	call   80103f9b <argstr>
801047ac:	83 c4 10             	add    $0x10,%esp
801047af:	85 c0                	test   %eax,%eax
801047b1:	0f 88 a0 00 00 00    	js     80104857 <sys_open+0xbf>
801047b7:	83 ec 08             	sub    $0x8,%esp
801047ba:	8d 45 e0             	lea    -0x20(%ebp),%eax
801047bd:	50                   	push   %eax
801047be:	6a 01                	push   $0x1
801047c0:	e8 46 f7 ff ff       	call   80103f0b <argint>
801047c5:	83 c4 10             	add    $0x10,%esp
801047c8:	85 c0                	test   %eax,%eax
801047ca:	0f 88 87 00 00 00    	js     80104857 <sys_open+0xbf>
    return -1;

  begin_op();
801047d0:	e8 db df ff ff       	call   801027b0 <begin_op>

  if(omode & O_CREATE){
801047d5:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801047d9:	0f 84 8b 00 00 00    	je     8010486a <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
801047df:	83 ec 0c             	sub    $0xc,%esp
801047e2:	6a 00                	push   $0x0
801047e4:	b9 00 00 00 00       	mov    $0x0,%ecx
801047e9:	ba 02 00 00 00       	mov    $0x2,%edx
801047ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801047f1:	e8 1c f9 ff ff       	call   80104112 <create>
801047f6:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801047f8:	83 c4 10             	add    $0x10,%esp
801047fb:	85 c0                	test   %eax,%eax
801047fd:	74 5f                	je     8010485e <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801047ff:	e8 19 c4 ff ff       	call   80100c1d <filealloc>
80104804:	89 c3                	mov    %eax,%ebx
80104806:	85 c0                	test   %eax,%eax
80104808:	0f 84 b5 00 00 00    	je     801048c3 <sys_open+0x12b>
8010480e:	e8 72 f8 ff ff       	call   80104085 <fdalloc>
80104813:	89 c7                	mov    %eax,%edi
80104815:	85 c0                	test   %eax,%eax
80104817:	0f 88 a6 00 00 00    	js     801048c3 <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010481d:	83 ec 0c             	sub    $0xc,%esp
80104820:	56                   	push   %esi
80104821:	e8 0b ce ff ff       	call   80101631 <iunlock>
  end_op();
80104826:	e8 ff df ff ff       	call   8010282a <end_op>

  f->type = FD_INODE;
8010482b:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104831:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104834:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
8010483b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010483e:	83 c4 10             	add    $0x10,%esp
80104841:	a8 01                	test   $0x1,%al
80104843:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104847:	a8 03                	test   $0x3,%al
80104849:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010484d:	89 f8                	mov    %edi,%eax
8010484f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104852:	5b                   	pop    %ebx
80104853:	5e                   	pop    %esi
80104854:	5f                   	pop    %edi
80104855:	5d                   	pop    %ebp
80104856:	c3                   	ret    
    return -1;
80104857:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010485c:	eb ef                	jmp    8010484d <sys_open+0xb5>
      end_op();
8010485e:	e8 c7 df ff ff       	call   8010282a <end_op>
      return -1;
80104863:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104868:	eb e3                	jmp    8010484d <sys_open+0xb5>
    if((ip = namei(path)) == 0){
8010486a:	83 ec 0c             	sub    $0xc,%esp
8010486d:	ff 75 e4             	push   -0x1c(%ebp)
80104870:	e8 58 d3 ff ff       	call   80101bcd <namei>
80104875:	89 c6                	mov    %eax,%esi
80104877:	83 c4 10             	add    $0x10,%esp
8010487a:	85 c0                	test   %eax,%eax
8010487c:	74 39                	je     801048b7 <sys_open+0x11f>
    ilock(ip);
8010487e:	83 ec 0c             	sub    $0xc,%esp
80104881:	50                   	push   %eax
80104882:	e8 e8 cc ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104887:	83 c4 10             	add    $0x10,%esp
8010488a:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010488f:	0f 85 6a ff ff ff    	jne    801047ff <sys_open+0x67>
80104895:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104899:	0f 84 60 ff ff ff    	je     801047ff <sys_open+0x67>
      iunlockput(ip);
8010489f:	83 ec 0c             	sub    $0xc,%esp
801048a2:	56                   	push   %esi
801048a3:	e8 6e ce ff ff       	call   80101716 <iunlockput>
      end_op();
801048a8:	e8 7d df ff ff       	call   8010282a <end_op>
      return -1;
801048ad:	83 c4 10             	add    $0x10,%esp
801048b0:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048b5:	eb 96                	jmp    8010484d <sys_open+0xb5>
      end_op();
801048b7:	e8 6e df ff ff       	call   8010282a <end_op>
      return -1;
801048bc:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048c1:	eb 8a                	jmp    8010484d <sys_open+0xb5>
    if(f)
801048c3:	85 db                	test   %ebx,%ebx
801048c5:	74 0c                	je     801048d3 <sys_open+0x13b>
      fileclose(f);
801048c7:	83 ec 0c             	sub    $0xc,%esp
801048ca:	53                   	push   %ebx
801048cb:	e8 f3 c3 ff ff       	call   80100cc3 <fileclose>
801048d0:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801048d3:	83 ec 0c             	sub    $0xc,%esp
801048d6:	56                   	push   %esi
801048d7:	e8 3a ce ff ff       	call   80101716 <iunlockput>
    end_op();
801048dc:	e8 49 df ff ff       	call   8010282a <end_op>
    return -1;
801048e1:	83 c4 10             	add    $0x10,%esp
801048e4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048e9:	e9 5f ff ff ff       	jmp    8010484d <sys_open+0xb5>

801048ee <sys_mkdir>:

int
sys_mkdir(void)
{
801048ee:	55                   	push   %ebp
801048ef:	89 e5                	mov    %esp,%ebp
801048f1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801048f4:	e8 b7 de ff ff       	call   801027b0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801048f9:	83 ec 08             	sub    $0x8,%esp
801048fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048ff:	50                   	push   %eax
80104900:	6a 00                	push   $0x0
80104902:	e8 94 f6 ff ff       	call   80103f9b <argstr>
80104907:	83 c4 10             	add    $0x10,%esp
8010490a:	85 c0                	test   %eax,%eax
8010490c:	78 36                	js     80104944 <sys_mkdir+0x56>
8010490e:	83 ec 0c             	sub    $0xc,%esp
80104911:	6a 00                	push   $0x0
80104913:	b9 00 00 00 00       	mov    $0x0,%ecx
80104918:	ba 01 00 00 00       	mov    $0x1,%edx
8010491d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104920:	e8 ed f7 ff ff       	call   80104112 <create>
80104925:	83 c4 10             	add    $0x10,%esp
80104928:	85 c0                	test   %eax,%eax
8010492a:	74 18                	je     80104944 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010492c:	83 ec 0c             	sub    $0xc,%esp
8010492f:	50                   	push   %eax
80104930:	e8 e1 cd ff ff       	call   80101716 <iunlockput>
  end_op();
80104935:	e8 f0 de ff ff       	call   8010282a <end_op>
  return 0;
8010493a:	83 c4 10             	add    $0x10,%esp
8010493d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104942:	c9                   	leave  
80104943:	c3                   	ret    
    end_op();
80104944:	e8 e1 de ff ff       	call   8010282a <end_op>
    return -1;
80104949:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010494e:	eb f2                	jmp    80104942 <sys_mkdir+0x54>

80104950 <sys_mknod>:

int
sys_mknod(void)
{
80104950:	55                   	push   %ebp
80104951:	89 e5                	mov    %esp,%ebp
80104953:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104956:	e8 55 de ff ff       	call   801027b0 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010495b:	83 ec 08             	sub    $0x8,%esp
8010495e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104961:	50                   	push   %eax
80104962:	6a 00                	push   $0x0
80104964:	e8 32 f6 ff ff       	call   80103f9b <argstr>
80104969:	83 c4 10             	add    $0x10,%esp
8010496c:	85 c0                	test   %eax,%eax
8010496e:	78 62                	js     801049d2 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104970:	83 ec 08             	sub    $0x8,%esp
80104973:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104976:	50                   	push   %eax
80104977:	6a 01                	push   $0x1
80104979:	e8 8d f5 ff ff       	call   80103f0b <argint>
  if((argstr(0, &path)) < 0 ||
8010497e:	83 c4 10             	add    $0x10,%esp
80104981:	85 c0                	test   %eax,%eax
80104983:	78 4d                	js     801049d2 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104985:	83 ec 08             	sub    $0x8,%esp
80104988:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010498b:	50                   	push   %eax
8010498c:	6a 02                	push   $0x2
8010498e:	e8 78 f5 ff ff       	call   80103f0b <argint>
     argint(1, &major) < 0 ||
80104993:	83 c4 10             	add    $0x10,%esp
80104996:	85 c0                	test   %eax,%eax
80104998:	78 38                	js     801049d2 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010499a:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
8010499e:	83 ec 0c             	sub    $0xc,%esp
801049a1:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
801049a5:	50                   	push   %eax
801049a6:	ba 03 00 00 00       	mov    $0x3,%edx
801049ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ae:	e8 5f f7 ff ff       	call   80104112 <create>
     argint(2, &minor) < 0 ||
801049b3:	83 c4 10             	add    $0x10,%esp
801049b6:	85 c0                	test   %eax,%eax
801049b8:	74 18                	je     801049d2 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801049ba:	83 ec 0c             	sub    $0xc,%esp
801049bd:	50                   	push   %eax
801049be:	e8 53 cd ff ff       	call   80101716 <iunlockput>
  end_op();
801049c3:	e8 62 de ff ff       	call   8010282a <end_op>
  return 0;
801049c8:	83 c4 10             	add    $0x10,%esp
801049cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049d0:	c9                   	leave  
801049d1:	c3                   	ret    
    end_op();
801049d2:	e8 53 de ff ff       	call   8010282a <end_op>
    return -1;
801049d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049dc:	eb f2                	jmp    801049d0 <sys_mknod+0x80>

801049de <sys_chdir>:

int
sys_chdir(void)
{
801049de:	55                   	push   %ebp
801049df:	89 e5                	mov    %esp,%ebp
801049e1:	56                   	push   %esi
801049e2:	53                   	push   %ebx
801049e3:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801049e6:	e8 2f e8 ff ff       	call   8010321a <myproc>
801049eb:	89 c6                	mov    %eax,%esi
  
  begin_op();
801049ed:	e8 be dd ff ff       	call   801027b0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801049f2:	83 ec 08             	sub    $0x8,%esp
801049f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049f8:	50                   	push   %eax
801049f9:	6a 00                	push   $0x0
801049fb:	e8 9b f5 ff ff       	call   80103f9b <argstr>
80104a00:	83 c4 10             	add    $0x10,%esp
80104a03:	85 c0                	test   %eax,%eax
80104a05:	78 52                	js     80104a59 <sys_chdir+0x7b>
80104a07:	83 ec 0c             	sub    $0xc,%esp
80104a0a:	ff 75 f4             	push   -0xc(%ebp)
80104a0d:	e8 bb d1 ff ff       	call   80101bcd <namei>
80104a12:	89 c3                	mov    %eax,%ebx
80104a14:	83 c4 10             	add    $0x10,%esp
80104a17:	85 c0                	test   %eax,%eax
80104a19:	74 3e                	je     80104a59 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104a1b:	83 ec 0c             	sub    $0xc,%esp
80104a1e:	50                   	push   %eax
80104a1f:	e8 4b cb ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
80104a24:	83 c4 10             	add    $0x10,%esp
80104a27:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a2c:	75 37                	jne    80104a65 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104a2e:	83 ec 0c             	sub    $0xc,%esp
80104a31:	53                   	push   %ebx
80104a32:	e8 fa cb ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
80104a37:	83 c4 04             	add    $0x4,%esp
80104a3a:	ff 76 68             	push   0x68(%esi)
80104a3d:	e8 34 cc ff ff       	call   80101676 <iput>
  end_op();
80104a42:	e8 e3 dd ff ff       	call   8010282a <end_op>
  curproc->cwd = ip;
80104a47:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104a4a:	83 c4 10             	add    $0x10,%esp
80104a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a52:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a55:	5b                   	pop    %ebx
80104a56:	5e                   	pop    %esi
80104a57:	5d                   	pop    %ebp
80104a58:	c3                   	ret    
    end_op();
80104a59:	e8 cc dd ff ff       	call   8010282a <end_op>
    return -1;
80104a5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a63:	eb ed                	jmp    80104a52 <sys_chdir+0x74>
    iunlockput(ip);
80104a65:	83 ec 0c             	sub    $0xc,%esp
80104a68:	53                   	push   %ebx
80104a69:	e8 a8 cc ff ff       	call   80101716 <iunlockput>
    end_op();
80104a6e:	e8 b7 dd ff ff       	call   8010282a <end_op>
    return -1;
80104a73:	83 c4 10             	add    $0x10,%esp
80104a76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a7b:	eb d5                	jmp    80104a52 <sys_chdir+0x74>

80104a7d <sys_exec>:

int
sys_exec(void)
{
80104a7d:	55                   	push   %ebp
80104a7e:	89 e5                	mov    %esp,%ebp
80104a80:	53                   	push   %ebx
80104a81:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104a87:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a8a:	50                   	push   %eax
80104a8b:	6a 00                	push   $0x0
80104a8d:	e8 09 f5 ff ff       	call   80103f9b <argstr>
80104a92:	83 c4 10             	add    $0x10,%esp
80104a95:	85 c0                	test   %eax,%eax
80104a97:	78 38                	js     80104ad1 <sys_exec+0x54>
80104a99:	83 ec 08             	sub    $0x8,%esp
80104a9c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104aa2:	50                   	push   %eax
80104aa3:	6a 01                	push   $0x1
80104aa5:	e8 61 f4 ff ff       	call   80103f0b <argint>
80104aaa:	83 c4 10             	add    $0x10,%esp
80104aad:	85 c0                	test   %eax,%eax
80104aaf:	78 20                	js     80104ad1 <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104ab1:	83 ec 04             	sub    $0x4,%esp
80104ab4:	68 80 00 00 00       	push   $0x80
80104ab9:	6a 00                	push   $0x0
80104abb:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104ac1:	50                   	push   %eax
80104ac2:	e8 f4 f1 ff ff       	call   80103cbb <memset>
80104ac7:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104aca:	bb 00 00 00 00       	mov    $0x0,%ebx
80104acf:	eb 2c                	jmp    80104afd <sys_exec+0x80>
    return -1;
80104ad1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ad6:	eb 78                	jmp    80104b50 <sys_exec+0xd3>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104ad8:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104adf:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104ae3:	83 ec 08             	sub    $0x8,%esp
80104ae6:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104aec:	50                   	push   %eax
80104aed:	ff 75 f4             	push   -0xc(%ebp)
80104af0:	e8 d9 bd ff ff       	call   801008ce <exec>
80104af5:	83 c4 10             	add    $0x10,%esp
80104af8:	eb 56                	jmp    80104b50 <sys_exec+0xd3>
  for(i=0;; i++){
80104afa:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104afd:	83 fb 1f             	cmp    $0x1f,%ebx
80104b00:	77 49                	ja     80104b4b <sys_exec+0xce>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104b02:	83 ec 08             	sub    $0x8,%esp
80104b05:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104b0b:	50                   	push   %eax
80104b0c:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104b12:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104b15:	50                   	push   %eax
80104b16:	e8 76 f3 ff ff       	call   80103e91 <fetchint>
80104b1b:	83 c4 10             	add    $0x10,%esp
80104b1e:	85 c0                	test   %eax,%eax
80104b20:	78 33                	js     80104b55 <sys_exec+0xd8>
    if(uarg == 0){
80104b22:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104b28:	85 c0                	test   %eax,%eax
80104b2a:	74 ac                	je     80104ad8 <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
80104b2c:	83 ec 08             	sub    $0x8,%esp
80104b2f:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104b36:	52                   	push   %edx
80104b37:	50                   	push   %eax
80104b38:	e8 8f f3 ff ff       	call   80103ecc <fetchstr>
80104b3d:	83 c4 10             	add    $0x10,%esp
80104b40:	85 c0                	test   %eax,%eax
80104b42:	79 b6                	jns    80104afa <sys_exec+0x7d>
      return -1;
80104b44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b49:	eb 05                	jmp    80104b50 <sys_exec+0xd3>
      return -1;
80104b4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b53:	c9                   	leave  
80104b54:	c3                   	ret    
      return -1;
80104b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b5a:	eb f4                	jmp    80104b50 <sys_exec+0xd3>

80104b5c <sys_pipe>:

int
sys_pipe(void)
{
80104b5c:	55                   	push   %ebp
80104b5d:	89 e5                	mov    %esp,%ebp
80104b5f:	53                   	push   %ebx
80104b60:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104b63:	6a 08                	push   $0x8
80104b65:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b68:	50                   	push   %eax
80104b69:	6a 00                	push   $0x0
80104b6b:	e8 c3 f3 ff ff       	call   80103f33 <argptr>
80104b70:	83 c4 10             	add    $0x10,%esp
80104b73:	85 c0                	test   %eax,%eax
80104b75:	78 79                	js     80104bf0 <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104b77:	83 ec 08             	sub    $0x8,%esp
80104b7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b7d:	50                   	push   %eax
80104b7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b81:	50                   	push   %eax
80104b82:	e8 e5 e1 ff ff       	call   80102d6c <pipealloc>
80104b87:	83 c4 10             	add    $0x10,%esp
80104b8a:	85 c0                	test   %eax,%eax
80104b8c:	78 69                	js     80104bf7 <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b91:	e8 ef f4 ff ff       	call   80104085 <fdalloc>
80104b96:	89 c3                	mov    %eax,%ebx
80104b98:	85 c0                	test   %eax,%eax
80104b9a:	78 21                	js     80104bbd <sys_pipe+0x61>
80104b9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b9f:	e8 e1 f4 ff ff       	call   80104085 <fdalloc>
80104ba4:	85 c0                	test   %eax,%eax
80104ba6:	78 15                	js     80104bbd <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104ba8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bab:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104bad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bb0:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104bb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bbb:	c9                   	leave  
80104bbc:	c3                   	ret    
    if(fd0 >= 0)
80104bbd:	85 db                	test   %ebx,%ebx
80104bbf:	79 20                	jns    80104be1 <sys_pipe+0x85>
    fileclose(rf);
80104bc1:	83 ec 0c             	sub    $0xc,%esp
80104bc4:	ff 75 f0             	push   -0x10(%ebp)
80104bc7:	e8 f7 c0 ff ff       	call   80100cc3 <fileclose>
    fileclose(wf);
80104bcc:	83 c4 04             	add    $0x4,%esp
80104bcf:	ff 75 ec             	push   -0x14(%ebp)
80104bd2:	e8 ec c0 ff ff       	call   80100cc3 <fileclose>
    return -1;
80104bd7:	83 c4 10             	add    $0x10,%esp
80104bda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bdf:	eb d7                	jmp    80104bb8 <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
80104be1:	e8 34 e6 ff ff       	call   8010321a <myproc>
80104be6:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104bed:	00 
80104bee:	eb d1                	jmp    80104bc1 <sys_pipe+0x65>
    return -1;
80104bf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bf5:	eb c1                	jmp    80104bb8 <sys_pipe+0x5c>
    return -1;
80104bf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bfc:	eb ba                	jmp    80104bb8 <sys_pipe+0x5c>

80104bfe <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104bfe:	55                   	push   %ebp
80104bff:	89 e5                	mov    %esp,%ebp
80104c01:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104c04:	e8 8e e7 ff ff       	call   80103397 <fork>
}
80104c09:	c9                   	leave  
80104c0a:	c3                   	ret    

80104c0b <sys_exit>:

int
sys_exit(void)
{
80104c0b:	55                   	push   %ebp
80104c0c:	89 e5                	mov    %esp,%ebp
80104c0e:	83 ec 08             	sub    $0x8,%esp
  exit();
80104c11:	e8 b5 e9 ff ff       	call   801035cb <exit>
  return 0;  // not reached
}
80104c16:	b8 00 00 00 00       	mov    $0x0,%eax
80104c1b:	c9                   	leave  
80104c1c:	c3                   	ret    

80104c1d <sys_wait>:

int
sys_wait(void)
{
80104c1d:	55                   	push   %ebp
80104c1e:	89 e5                	mov    %esp,%ebp
80104c20:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104c23:	e8 2c eb ff ff       	call   80103754 <wait>
}
80104c28:	c9                   	leave  
80104c29:	c3                   	ret    

80104c2a <sys_kill>:

int
sys_kill(void)
{
80104c2a:	55                   	push   %ebp
80104c2b:	89 e5                	mov    %esp,%ebp
80104c2d:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104c30:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c33:	50                   	push   %eax
80104c34:	6a 00                	push   $0x0
80104c36:	e8 d0 f2 ff ff       	call   80103f0b <argint>
80104c3b:	83 c4 10             	add    $0x10,%esp
80104c3e:	85 c0                	test   %eax,%eax
80104c40:	78 10                	js     80104c52 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104c42:	83 ec 0c             	sub    $0xc,%esp
80104c45:	ff 75 f4             	push   -0xc(%ebp)
80104c48:	e8 04 ec ff ff       	call   80103851 <kill>
80104c4d:	83 c4 10             	add    $0x10,%esp
}
80104c50:	c9                   	leave  
80104c51:	c3                   	ret    
    return -1;
80104c52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c57:	eb f7                	jmp    80104c50 <sys_kill+0x26>

80104c59 <sys_getpid>:

int
sys_getpid(void)
{
80104c59:	55                   	push   %ebp
80104c5a:	89 e5                	mov    %esp,%ebp
80104c5c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104c5f:	e8 b6 e5 ff ff       	call   8010321a <myproc>
80104c64:	8b 40 10             	mov    0x10(%eax),%eax
}
80104c67:	c9                   	leave  
80104c68:	c3                   	ret    

80104c69 <sys_sbrk>:

int
sys_sbrk(void)
{
80104c69:	55                   	push   %ebp
80104c6a:	89 e5                	mov    %esp,%ebp
80104c6c:	53                   	push   %ebx
80104c6d:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104c70:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c73:	50                   	push   %eax
80104c74:	6a 00                	push   $0x0
80104c76:	e8 90 f2 ff ff       	call   80103f0b <argint>
80104c7b:	83 c4 10             	add    $0x10,%esp
80104c7e:	85 c0                	test   %eax,%eax
80104c80:	78 20                	js     80104ca2 <sys_sbrk+0x39>
    return -1;
  addr = myproc()->sz;
80104c82:	e8 93 e5 ff ff       	call   8010321a <myproc>
80104c87:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104c89:	83 ec 0c             	sub    $0xc,%esp
80104c8c:	ff 75 f4             	push   -0xc(%ebp)
80104c8f:	e8 98 e6 ff ff       	call   8010332c <growproc>
80104c94:	83 c4 10             	add    $0x10,%esp
80104c97:	85 c0                	test   %eax,%eax
80104c99:	78 0e                	js     80104ca9 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80104c9b:	89 d8                	mov    %ebx,%eax
80104c9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ca0:	c9                   	leave  
80104ca1:	c3                   	ret    
    return -1;
80104ca2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104ca7:	eb f2                	jmp    80104c9b <sys_sbrk+0x32>
    return -1;
80104ca9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104cae:	eb eb                	jmp    80104c9b <sys_sbrk+0x32>

80104cb0 <sys_sleep>:

int
sys_sleep(void)
{
80104cb0:	55                   	push   %ebp
80104cb1:	89 e5                	mov    %esp,%ebp
80104cb3:	53                   	push   %ebx
80104cb4:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104cb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cba:	50                   	push   %eax
80104cbb:	6a 00                	push   $0x0
80104cbd:	e8 49 f2 ff ff       	call   80103f0b <argint>
80104cc2:	83 c4 10             	add    $0x10,%esp
80104cc5:	85 c0                	test   %eax,%eax
80104cc7:	78 75                	js     80104d3e <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104cc9:	83 ec 0c             	sub    $0xc,%esp
80104ccc:	68 80 3d 11 80       	push   $0x80113d80
80104cd1:	e8 39 ef ff ff       	call   80103c0f <acquire>
  ticks0 = ticks;
80104cd6:	8b 1d 60 3d 11 80    	mov    0x80113d60,%ebx
  while(ticks - ticks0 < n){
80104cdc:	83 c4 10             	add    $0x10,%esp
80104cdf:	a1 60 3d 11 80       	mov    0x80113d60,%eax
80104ce4:	29 d8                	sub    %ebx,%eax
80104ce6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104ce9:	73 39                	jae    80104d24 <sys_sleep+0x74>
    if(myproc()->killed){
80104ceb:	e8 2a e5 ff ff       	call   8010321a <myproc>
80104cf0:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104cf4:	75 17                	jne    80104d0d <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104cf6:	83 ec 08             	sub    $0x8,%esp
80104cf9:	68 80 3d 11 80       	push   $0x80113d80
80104cfe:	68 60 3d 11 80       	push   $0x80113d60
80104d03:	e8 bb e9 ff ff       	call   801036c3 <sleep>
80104d08:	83 c4 10             	add    $0x10,%esp
80104d0b:	eb d2                	jmp    80104cdf <sys_sleep+0x2f>
      release(&tickslock);
80104d0d:	83 ec 0c             	sub    $0xc,%esp
80104d10:	68 80 3d 11 80       	push   $0x80113d80
80104d15:	e8 5a ef ff ff       	call   80103c74 <release>
      return -1;
80104d1a:	83 c4 10             	add    $0x10,%esp
80104d1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d22:	eb 15                	jmp    80104d39 <sys_sleep+0x89>
  }
  release(&tickslock);
80104d24:	83 ec 0c             	sub    $0xc,%esp
80104d27:	68 80 3d 11 80       	push   $0x80113d80
80104d2c:	e8 43 ef ff ff       	call   80103c74 <release>
  return 0;
80104d31:	83 c4 10             	add    $0x10,%esp
80104d34:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d3c:	c9                   	leave  
80104d3d:	c3                   	ret    
    return -1;
80104d3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d43:	eb f4                	jmp    80104d39 <sys_sleep+0x89>

80104d45 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104d45:	55                   	push   %ebp
80104d46:	89 e5                	mov    %esp,%ebp
80104d48:	53                   	push   %ebx
80104d49:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104d4c:	68 80 3d 11 80       	push   $0x80113d80
80104d51:	e8 b9 ee ff ff       	call   80103c0f <acquire>
  xticks = ticks;
80104d56:	8b 1d 60 3d 11 80    	mov    0x80113d60,%ebx
  release(&tickslock);
80104d5c:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
80104d63:	e8 0c ef ff ff       	call   80103c74 <release>
  return xticks;
}
80104d68:	89 d8                	mov    %ebx,%eax
80104d6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d6d:	c9                   	leave  
80104d6e:	c3                   	ret    

80104d6f <sys_yield>:

int
sys_yield(void)
{
80104d6f:	55                   	push   %ebp
80104d70:	89 e5                	mov    %esp,%ebp
80104d72:	83 ec 08             	sub    $0x8,%esp
  yield();
80104d75:	e8 17 e9 ff ff       	call   80103691 <yield>
  return 0;
}
80104d7a:	b8 00 00 00 00       	mov    $0x0,%eax
80104d7f:	c9                   	leave  
80104d80:	c3                   	ret    

80104d81 <sys_shutdown>:

int sys_shutdown(void)
{
80104d81:	55                   	push   %ebp
80104d82:	89 e5                	mov    %esp,%ebp
80104d84:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80104d87:	e8 6f d4 ff ff       	call   801021fb <shutdown>
  return 0;
}
80104d8c:	b8 00 00 00 00       	mov    $0x0,%eax
80104d91:	c9                   	leave  
80104d92:	c3                   	ret    

80104d93 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104d93:	1e                   	push   %ds
  pushl %es
80104d94:	06                   	push   %es
  pushl %fs
80104d95:	0f a0                	push   %fs
  pushl %gs
80104d97:	0f a8                	push   %gs
  pushal
80104d99:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104d9a:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104d9e:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104da0:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104da2:	54                   	push   %esp
  call trap
80104da3:	e8 37 01 00 00       	call   80104edf <trap>
  addl $4, %esp
80104da8:	83 c4 04             	add    $0x4,%esp

80104dab <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104dab:	61                   	popa   
  popl %gs
80104dac:	0f a9                	pop    %gs
  popl %fs
80104dae:	0f a1                	pop    %fs
  popl %es
80104db0:	07                   	pop    %es
  popl %ds
80104db1:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104db2:	83 c4 08             	add    $0x8,%esp
  iret
80104db5:	cf                   	iret   

80104db6 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104db6:	55                   	push   %ebp
80104db7:	89 e5                	mov    %esp,%ebp
80104db9:	53                   	push   %ebx
80104dba:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80104dbd:	b8 00 00 00 00       	mov    $0x0,%eax
80104dc2:	eb 76                	jmp    80104e3a <tvinit+0x84>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104dc4:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104dcb:	66 89 0c c5 c0 3d 11 	mov    %cx,-0x7feec240(,%eax,8)
80104dd2:	80 
80104dd3:	66 c7 04 c5 c2 3d 11 	movw   $0x8,-0x7feec23e(,%eax,8)
80104dda:	80 08 00 
80104ddd:	0f b6 14 c5 c4 3d 11 	movzbl -0x7feec23c(,%eax,8),%edx
80104de4:	80 
80104de5:	83 e2 e0             	and    $0xffffffe0,%edx
80104de8:	88 14 c5 c4 3d 11 80 	mov    %dl,-0x7feec23c(,%eax,8)
80104def:	c6 04 c5 c4 3d 11 80 	movb   $0x0,-0x7feec23c(,%eax,8)
80104df6:	00 
80104df7:	0f b6 14 c5 c5 3d 11 	movzbl -0x7feec23b(,%eax,8),%edx
80104dfe:	80 
80104dff:	83 e2 f0             	and    $0xfffffff0,%edx
80104e02:	83 ca 0e             	or     $0xe,%edx
80104e05:	88 14 c5 c5 3d 11 80 	mov    %dl,-0x7feec23b(,%eax,8)
80104e0c:	89 d3                	mov    %edx,%ebx
80104e0e:	83 e3 ef             	and    $0xffffffef,%ebx
80104e11:	88 1c c5 c5 3d 11 80 	mov    %bl,-0x7feec23b(,%eax,8)
80104e18:	83 e2 8f             	and    $0xffffff8f,%edx
80104e1b:	88 14 c5 c5 3d 11 80 	mov    %dl,-0x7feec23b(,%eax,8)
80104e22:	83 ca 80             	or     $0xffffff80,%edx
80104e25:	88 14 c5 c5 3d 11 80 	mov    %dl,-0x7feec23b(,%eax,8)
80104e2c:	c1 e9 10             	shr    $0x10,%ecx
80104e2f:	66 89 0c c5 c6 3d 11 	mov    %cx,-0x7feec23a(,%eax,8)
80104e36:	80 
  for(i = 0; i < 256; i++)
80104e37:	83 c0 01             	add    $0x1,%eax
80104e3a:	3d ff 00 00 00       	cmp    $0xff,%eax
80104e3f:	7e 83                	jle    80104dc4 <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104e41:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104e47:	66 89 15 c0 3f 11 80 	mov    %dx,0x80113fc0
80104e4e:	66 c7 05 c2 3f 11 80 	movw   $0x8,0x80113fc2
80104e55:	08 00 
80104e57:	0f b6 05 c4 3f 11 80 	movzbl 0x80113fc4,%eax
80104e5e:	83 e0 e0             	and    $0xffffffe0,%eax
80104e61:	a2 c4 3f 11 80       	mov    %al,0x80113fc4
80104e66:	c6 05 c4 3f 11 80 00 	movb   $0x0,0x80113fc4
80104e6d:	0f b6 05 c5 3f 11 80 	movzbl 0x80113fc5,%eax
80104e74:	83 c8 0f             	or     $0xf,%eax
80104e77:	a2 c5 3f 11 80       	mov    %al,0x80113fc5
80104e7c:	83 e0 ef             	and    $0xffffffef,%eax
80104e7f:	a2 c5 3f 11 80       	mov    %al,0x80113fc5
80104e84:	89 c1                	mov    %eax,%ecx
80104e86:	83 c9 60             	or     $0x60,%ecx
80104e89:	88 0d c5 3f 11 80    	mov    %cl,0x80113fc5
80104e8f:	83 c8 e0             	or     $0xffffffe0,%eax
80104e92:	a2 c5 3f 11 80       	mov    %al,0x80113fc5
80104e97:	c1 ea 10             	shr    $0x10,%edx
80104e9a:	66 89 15 c6 3f 11 80 	mov    %dx,0x80113fc6

  initlock(&tickslock, "time");
80104ea1:	83 ec 08             	sub    $0x8,%esp
80104ea4:	68 f1 6f 10 80       	push   $0x80106ff1
80104ea9:	68 80 3d 11 80       	push   $0x80113d80
80104eae:	e8 20 ec ff ff       	call   80103ad3 <initlock>
}
80104eb3:	83 c4 10             	add    $0x10,%esp
80104eb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104eb9:	c9                   	leave  
80104eba:	c3                   	ret    

80104ebb <idtinit>:

void
idtinit(void)
{
80104ebb:	55                   	push   %ebp
80104ebc:	89 e5                	mov    %esp,%ebp
80104ebe:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104ec1:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104ec7:	b8 c0 3d 11 80       	mov    $0x80113dc0,%eax
80104ecc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104ed0:	c1 e8 10             	shr    $0x10,%eax
80104ed3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104ed7:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104eda:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104edd:	c9                   	leave  
80104ede:	c3                   	ret    

80104edf <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104edf:	55                   	push   %ebp
80104ee0:	89 e5                	mov    %esp,%ebp
80104ee2:	57                   	push   %edi
80104ee3:	56                   	push   %esi
80104ee4:	53                   	push   %ebx
80104ee5:	83 ec 1c             	sub    $0x1c,%esp
80104ee8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104eeb:	8b 43 30             	mov    0x30(%ebx),%eax
80104eee:	83 f8 40             	cmp    $0x40,%eax
80104ef1:	74 13                	je     80104f06 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104ef3:	83 e8 20             	sub    $0x20,%eax
80104ef6:	83 f8 1f             	cmp    $0x1f,%eax
80104ef9:	0f 87 3a 01 00 00    	ja     80105039 <trap+0x15a>
80104eff:	ff 24 85 98 70 10 80 	jmp    *-0x7fef8f68(,%eax,4)
    if(myproc()->killed)
80104f06:	e8 0f e3 ff ff       	call   8010321a <myproc>
80104f0b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f0f:	75 1f                	jne    80104f30 <trap+0x51>
    myproc()->tf = tf;
80104f11:	e8 04 e3 ff ff       	call   8010321a <myproc>
80104f16:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104f19:	e8 b0 f0 ff ff       	call   80103fce <syscall>
    if(myproc()->killed)
80104f1e:	e8 f7 e2 ff ff       	call   8010321a <myproc>
80104f23:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f27:	74 7e                	je     80104fa7 <trap+0xc8>
      exit();
80104f29:	e8 9d e6 ff ff       	call   801035cb <exit>
    return;
80104f2e:	eb 77                	jmp    80104fa7 <trap+0xc8>
      exit();
80104f30:	e8 96 e6 ff ff       	call   801035cb <exit>
80104f35:	eb da                	jmp    80104f11 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104f37:	e8 c3 e2 ff ff       	call   801031ff <cpuid>
80104f3c:	85 c0                	test   %eax,%eax
80104f3e:	74 6f                	je     80104faf <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104f40:	e8 63 d4 ff ff       	call   801023a8 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f45:	e8 d0 e2 ff ff       	call   8010321a <myproc>
80104f4a:	85 c0                	test   %eax,%eax
80104f4c:	74 1c                	je     80104f6a <trap+0x8b>
80104f4e:	e8 c7 e2 ff ff       	call   8010321a <myproc>
80104f53:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f57:	74 11                	je     80104f6a <trap+0x8b>
80104f59:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f5d:	83 e0 03             	and    $0x3,%eax
80104f60:	66 83 f8 03          	cmp    $0x3,%ax
80104f64:	0f 84 62 01 00 00    	je     801050cc <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104f6a:	e8 ab e2 ff ff       	call   8010321a <myproc>
80104f6f:	85 c0                	test   %eax,%eax
80104f71:	74 0f                	je     80104f82 <trap+0xa3>
80104f73:	e8 a2 e2 ff ff       	call   8010321a <myproc>
80104f78:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80104f7c:	0f 84 54 01 00 00    	je     801050d6 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f82:	e8 93 e2 ff ff       	call   8010321a <myproc>
80104f87:	85 c0                	test   %eax,%eax
80104f89:	74 1c                	je     80104fa7 <trap+0xc8>
80104f8b:	e8 8a e2 ff ff       	call   8010321a <myproc>
80104f90:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f94:	74 11                	je     80104fa7 <trap+0xc8>
80104f96:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f9a:	83 e0 03             	and    $0x3,%eax
80104f9d:	66 83 f8 03          	cmp    $0x3,%ax
80104fa1:	0f 84 43 01 00 00    	je     801050ea <trap+0x20b>
    exit();
}
80104fa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104faa:	5b                   	pop    %ebx
80104fab:	5e                   	pop    %esi
80104fac:	5f                   	pop    %edi
80104fad:	5d                   	pop    %ebp
80104fae:	c3                   	ret    
      acquire(&tickslock);
80104faf:	83 ec 0c             	sub    $0xc,%esp
80104fb2:	68 80 3d 11 80       	push   $0x80113d80
80104fb7:	e8 53 ec ff ff       	call   80103c0f <acquire>
      ticks++;
80104fbc:	83 05 60 3d 11 80 01 	addl   $0x1,0x80113d60
      wakeup(&ticks);
80104fc3:	c7 04 24 60 3d 11 80 	movl   $0x80113d60,(%esp)
80104fca:	e8 59 e8 ff ff       	call   80103828 <wakeup>
      release(&tickslock);
80104fcf:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
80104fd6:	e8 99 ec ff ff       	call   80103c74 <release>
80104fdb:	83 c4 10             	add    $0x10,%esp
80104fde:	e9 5d ff ff ff       	jmp    80104f40 <trap+0x61>
    ideintr();
80104fe3:	e8 74 cd ff ff       	call   80101d5c <ideintr>
    lapiceoi();
80104fe8:	e8 bb d3 ff ff       	call   801023a8 <lapiceoi>
    break;
80104fed:	e9 53 ff ff ff       	jmp    80104f45 <trap+0x66>
    kbdintr();
80104ff2:	e8 ef d1 ff ff       	call   801021e6 <kbdintr>
    lapiceoi();
80104ff7:	e8 ac d3 ff ff       	call   801023a8 <lapiceoi>
    break;
80104ffc:	e9 44 ff ff ff       	jmp    80104f45 <trap+0x66>
    uartintr();
80105001:	e8 fe 01 00 00       	call   80105204 <uartintr>
    lapiceoi();
80105006:	e8 9d d3 ff ff       	call   801023a8 <lapiceoi>
    break;
8010500b:	e9 35 ff ff ff       	jmp    80104f45 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105010:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105013:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105017:	e8 e3 e1 ff ff       	call   801031ff <cpuid>
8010501c:	57                   	push   %edi
8010501d:	0f b7 f6             	movzwl %si,%esi
80105020:	56                   	push   %esi
80105021:	50                   	push   %eax
80105022:	68 fc 6f 10 80       	push   $0x80106ffc
80105027:	e8 db b5 ff ff       	call   80100607 <cprintf>
    lapiceoi();
8010502c:	e8 77 d3 ff ff       	call   801023a8 <lapiceoi>
    break;
80105031:	83 c4 10             	add    $0x10,%esp
80105034:	e9 0c ff ff ff       	jmp    80104f45 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105039:	e8 dc e1 ff ff       	call   8010321a <myproc>
8010503e:	85 c0                	test   %eax,%eax
80105040:	74 5f                	je     801050a1 <trap+0x1c2>
80105042:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105046:	74 59                	je     801050a1 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105048:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010504b:	8b 43 38             	mov    0x38(%ebx),%eax
8010504e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105051:	e8 a9 e1 ff ff       	call   801031ff <cpuid>
80105056:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105059:	8b 53 34             	mov    0x34(%ebx),%edx
8010505c:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010505f:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105062:	e8 b3 e1 ff ff       	call   8010321a <myproc>
80105067:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010506a:	89 4d d8             	mov    %ecx,-0x28(%ebp)
8010506d:	e8 a8 e1 ff ff       	call   8010321a <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105072:	57                   	push   %edi
80105073:	ff 75 e4             	push   -0x1c(%ebp)
80105076:	ff 75 e0             	push   -0x20(%ebp)
80105079:	ff 75 dc             	push   -0x24(%ebp)
8010507c:	56                   	push   %esi
8010507d:	ff 75 d8             	push   -0x28(%ebp)
80105080:	ff 70 10             	push   0x10(%eax)
80105083:	68 54 70 10 80       	push   $0x80107054
80105088:	e8 7a b5 ff ff       	call   80100607 <cprintf>
    myproc()->killed = 1;
8010508d:	83 c4 20             	add    $0x20,%esp
80105090:	e8 85 e1 ff ff       	call   8010321a <myproc>
80105095:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010509c:	e9 a4 fe ff ff       	jmp    80104f45 <trap+0x66>
801050a1:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801050a4:	8b 73 38             	mov    0x38(%ebx),%esi
801050a7:	e8 53 e1 ff ff       	call   801031ff <cpuid>
801050ac:	83 ec 0c             	sub    $0xc,%esp
801050af:	57                   	push   %edi
801050b0:	56                   	push   %esi
801050b1:	50                   	push   %eax
801050b2:	ff 73 30             	push   0x30(%ebx)
801050b5:	68 20 70 10 80       	push   $0x80107020
801050ba:	e8 48 b5 ff ff       	call   80100607 <cprintf>
      panic("trap");
801050bf:	83 c4 14             	add    $0x14,%esp
801050c2:	68 f6 6f 10 80       	push   $0x80106ff6
801050c7:	e8 7c b2 ff ff       	call   80100348 <panic>
    exit();
801050cc:	e8 fa e4 ff ff       	call   801035cb <exit>
801050d1:	e9 94 fe ff ff       	jmp    80104f6a <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801050d6:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801050da:	0f 85 a2 fe ff ff    	jne    80104f82 <trap+0xa3>
    yield();
801050e0:	e8 ac e5 ff ff       	call   80103691 <yield>
801050e5:	e9 98 fe ff ff       	jmp    80104f82 <trap+0xa3>
    exit();
801050ea:	e8 dc e4 ff ff       	call   801035cb <exit>
801050ef:	e9 b3 fe ff ff       	jmp    80104fa7 <trap+0xc8>

801050f4 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
801050f4:	83 3d c0 45 11 80 00 	cmpl   $0x0,0x801145c0
801050fb:	74 14                	je     80105111 <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801050fd:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105102:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105103:	a8 01                	test   $0x1,%al
80105105:	74 10                	je     80105117 <uartgetc+0x23>
80105107:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010510c:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010510d:	0f b6 c0             	movzbl %al,%eax
80105110:	c3                   	ret    
    return -1;
80105111:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105116:	c3                   	ret    
    return -1;
80105117:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010511c:	c3                   	ret    

8010511d <uartputc>:
  if(!uart)
8010511d:	83 3d c0 45 11 80 00 	cmpl   $0x0,0x801145c0
80105124:	74 3b                	je     80105161 <uartputc+0x44>
{
80105126:	55                   	push   %ebp
80105127:	89 e5                	mov    %esp,%ebp
80105129:	53                   	push   %ebx
8010512a:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010512d:	bb 00 00 00 00       	mov    $0x0,%ebx
80105132:	eb 10                	jmp    80105144 <uartputc+0x27>
    microdelay(10);
80105134:	83 ec 0c             	sub    $0xc,%esp
80105137:	6a 0a                	push   $0xa
80105139:	e8 8b d2 ff ff       	call   801023c9 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010513e:	83 c3 01             	add    $0x1,%ebx
80105141:	83 c4 10             	add    $0x10,%esp
80105144:	83 fb 7f             	cmp    $0x7f,%ebx
80105147:	7f 0a                	jg     80105153 <uartputc+0x36>
80105149:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010514e:	ec                   	in     (%dx),%al
8010514f:	a8 20                	test   $0x20,%al
80105151:	74 e1                	je     80105134 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105153:	8b 45 08             	mov    0x8(%ebp),%eax
80105156:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010515b:	ee                   	out    %al,(%dx)
}
8010515c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010515f:	c9                   	leave  
80105160:	c3                   	ret    
80105161:	c3                   	ret    

80105162 <uartinit>:
{
80105162:	55                   	push   %ebp
80105163:	89 e5                	mov    %esp,%ebp
80105165:	56                   	push   %esi
80105166:	53                   	push   %ebx
80105167:	b9 00 00 00 00       	mov    $0x0,%ecx
8010516c:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105171:	89 c8                	mov    %ecx,%eax
80105173:	ee                   	out    %al,(%dx)
80105174:	be fb 03 00 00       	mov    $0x3fb,%esi
80105179:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010517e:	89 f2                	mov    %esi,%edx
80105180:	ee                   	out    %al,(%dx)
80105181:	b8 0c 00 00 00       	mov    $0xc,%eax
80105186:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010518b:	ee                   	out    %al,(%dx)
8010518c:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105191:	89 c8                	mov    %ecx,%eax
80105193:	89 da                	mov    %ebx,%edx
80105195:	ee                   	out    %al,(%dx)
80105196:	b8 03 00 00 00       	mov    $0x3,%eax
8010519b:	89 f2                	mov    %esi,%edx
8010519d:	ee                   	out    %al,(%dx)
8010519e:	ba fc 03 00 00       	mov    $0x3fc,%edx
801051a3:	89 c8                	mov    %ecx,%eax
801051a5:	ee                   	out    %al,(%dx)
801051a6:	b8 01 00 00 00       	mov    $0x1,%eax
801051ab:	89 da                	mov    %ebx,%edx
801051ad:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051ae:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051b3:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801051b4:	3c ff                	cmp    $0xff,%al
801051b6:	74 45                	je     801051fd <uartinit+0x9b>
  uart = 1;
801051b8:	c7 05 c0 45 11 80 01 	movl   $0x1,0x801145c0
801051bf:	00 00 00 
801051c2:	ba fa 03 00 00       	mov    $0x3fa,%edx
801051c7:	ec                   	in     (%dx),%al
801051c8:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051cd:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801051ce:	83 ec 08             	sub    $0x8,%esp
801051d1:	6a 00                	push   $0x0
801051d3:	6a 04                	push   $0x4
801051d5:	e8 87 cd ff ff       	call   80101f61 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801051da:	83 c4 10             	add    $0x10,%esp
801051dd:	bb 18 71 10 80       	mov    $0x80107118,%ebx
801051e2:	eb 12                	jmp    801051f6 <uartinit+0x94>
    uartputc(*p);
801051e4:	83 ec 0c             	sub    $0xc,%esp
801051e7:	0f be c0             	movsbl %al,%eax
801051ea:	50                   	push   %eax
801051eb:	e8 2d ff ff ff       	call   8010511d <uartputc>
  for(p="xv6...\n"; *p; p++)
801051f0:	83 c3 01             	add    $0x1,%ebx
801051f3:	83 c4 10             	add    $0x10,%esp
801051f6:	0f b6 03             	movzbl (%ebx),%eax
801051f9:	84 c0                	test   %al,%al
801051fb:	75 e7                	jne    801051e4 <uartinit+0x82>
}
801051fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105200:	5b                   	pop    %ebx
80105201:	5e                   	pop    %esi
80105202:	5d                   	pop    %ebp
80105203:	c3                   	ret    

80105204 <uartintr>:

void
uartintr(void)
{
80105204:	55                   	push   %ebp
80105205:	89 e5                	mov    %esp,%ebp
80105207:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
8010520a:	68 f4 50 10 80       	push   $0x801050f4
8010520f:	e8 1f b5 ff ff       	call   80100733 <consoleintr>
}
80105214:	83 c4 10             	add    $0x10,%esp
80105217:	c9                   	leave  
80105218:	c3                   	ret    

80105219 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105219:	6a 00                	push   $0x0
  pushl $0
8010521b:	6a 00                	push   $0x0
  jmp alltraps
8010521d:	e9 71 fb ff ff       	jmp    80104d93 <alltraps>

80105222 <vector1>:
.globl vector1
vector1:
  pushl $0
80105222:	6a 00                	push   $0x0
  pushl $1
80105224:	6a 01                	push   $0x1
  jmp alltraps
80105226:	e9 68 fb ff ff       	jmp    80104d93 <alltraps>

8010522b <vector2>:
.globl vector2
vector2:
  pushl $0
8010522b:	6a 00                	push   $0x0
  pushl $2
8010522d:	6a 02                	push   $0x2
  jmp alltraps
8010522f:	e9 5f fb ff ff       	jmp    80104d93 <alltraps>

80105234 <vector3>:
.globl vector3
vector3:
  pushl $0
80105234:	6a 00                	push   $0x0
  pushl $3
80105236:	6a 03                	push   $0x3
  jmp alltraps
80105238:	e9 56 fb ff ff       	jmp    80104d93 <alltraps>

8010523d <vector4>:
.globl vector4
vector4:
  pushl $0
8010523d:	6a 00                	push   $0x0
  pushl $4
8010523f:	6a 04                	push   $0x4
  jmp alltraps
80105241:	e9 4d fb ff ff       	jmp    80104d93 <alltraps>

80105246 <vector5>:
.globl vector5
vector5:
  pushl $0
80105246:	6a 00                	push   $0x0
  pushl $5
80105248:	6a 05                	push   $0x5
  jmp alltraps
8010524a:	e9 44 fb ff ff       	jmp    80104d93 <alltraps>

8010524f <vector6>:
.globl vector6
vector6:
  pushl $0
8010524f:	6a 00                	push   $0x0
  pushl $6
80105251:	6a 06                	push   $0x6
  jmp alltraps
80105253:	e9 3b fb ff ff       	jmp    80104d93 <alltraps>

80105258 <vector7>:
.globl vector7
vector7:
  pushl $0
80105258:	6a 00                	push   $0x0
  pushl $7
8010525a:	6a 07                	push   $0x7
  jmp alltraps
8010525c:	e9 32 fb ff ff       	jmp    80104d93 <alltraps>

80105261 <vector8>:
.globl vector8
vector8:
  pushl $8
80105261:	6a 08                	push   $0x8
  jmp alltraps
80105263:	e9 2b fb ff ff       	jmp    80104d93 <alltraps>

80105268 <vector9>:
.globl vector9
vector9:
  pushl $0
80105268:	6a 00                	push   $0x0
  pushl $9
8010526a:	6a 09                	push   $0x9
  jmp alltraps
8010526c:	e9 22 fb ff ff       	jmp    80104d93 <alltraps>

80105271 <vector10>:
.globl vector10
vector10:
  pushl $10
80105271:	6a 0a                	push   $0xa
  jmp alltraps
80105273:	e9 1b fb ff ff       	jmp    80104d93 <alltraps>

80105278 <vector11>:
.globl vector11
vector11:
  pushl $11
80105278:	6a 0b                	push   $0xb
  jmp alltraps
8010527a:	e9 14 fb ff ff       	jmp    80104d93 <alltraps>

8010527f <vector12>:
.globl vector12
vector12:
  pushl $12
8010527f:	6a 0c                	push   $0xc
  jmp alltraps
80105281:	e9 0d fb ff ff       	jmp    80104d93 <alltraps>

80105286 <vector13>:
.globl vector13
vector13:
  pushl $13
80105286:	6a 0d                	push   $0xd
  jmp alltraps
80105288:	e9 06 fb ff ff       	jmp    80104d93 <alltraps>

8010528d <vector14>:
.globl vector14
vector14:
  pushl $14
8010528d:	6a 0e                	push   $0xe
  jmp alltraps
8010528f:	e9 ff fa ff ff       	jmp    80104d93 <alltraps>

80105294 <vector15>:
.globl vector15
vector15:
  pushl $0
80105294:	6a 00                	push   $0x0
  pushl $15
80105296:	6a 0f                	push   $0xf
  jmp alltraps
80105298:	e9 f6 fa ff ff       	jmp    80104d93 <alltraps>

8010529d <vector16>:
.globl vector16
vector16:
  pushl $0
8010529d:	6a 00                	push   $0x0
  pushl $16
8010529f:	6a 10                	push   $0x10
  jmp alltraps
801052a1:	e9 ed fa ff ff       	jmp    80104d93 <alltraps>

801052a6 <vector17>:
.globl vector17
vector17:
  pushl $17
801052a6:	6a 11                	push   $0x11
  jmp alltraps
801052a8:	e9 e6 fa ff ff       	jmp    80104d93 <alltraps>

801052ad <vector18>:
.globl vector18
vector18:
  pushl $0
801052ad:	6a 00                	push   $0x0
  pushl $18
801052af:	6a 12                	push   $0x12
  jmp alltraps
801052b1:	e9 dd fa ff ff       	jmp    80104d93 <alltraps>

801052b6 <vector19>:
.globl vector19
vector19:
  pushl $0
801052b6:	6a 00                	push   $0x0
  pushl $19
801052b8:	6a 13                	push   $0x13
  jmp alltraps
801052ba:	e9 d4 fa ff ff       	jmp    80104d93 <alltraps>

801052bf <vector20>:
.globl vector20
vector20:
  pushl $0
801052bf:	6a 00                	push   $0x0
  pushl $20
801052c1:	6a 14                	push   $0x14
  jmp alltraps
801052c3:	e9 cb fa ff ff       	jmp    80104d93 <alltraps>

801052c8 <vector21>:
.globl vector21
vector21:
  pushl $0
801052c8:	6a 00                	push   $0x0
  pushl $21
801052ca:	6a 15                	push   $0x15
  jmp alltraps
801052cc:	e9 c2 fa ff ff       	jmp    80104d93 <alltraps>

801052d1 <vector22>:
.globl vector22
vector22:
  pushl $0
801052d1:	6a 00                	push   $0x0
  pushl $22
801052d3:	6a 16                	push   $0x16
  jmp alltraps
801052d5:	e9 b9 fa ff ff       	jmp    80104d93 <alltraps>

801052da <vector23>:
.globl vector23
vector23:
  pushl $0
801052da:	6a 00                	push   $0x0
  pushl $23
801052dc:	6a 17                	push   $0x17
  jmp alltraps
801052de:	e9 b0 fa ff ff       	jmp    80104d93 <alltraps>

801052e3 <vector24>:
.globl vector24
vector24:
  pushl $0
801052e3:	6a 00                	push   $0x0
  pushl $24
801052e5:	6a 18                	push   $0x18
  jmp alltraps
801052e7:	e9 a7 fa ff ff       	jmp    80104d93 <alltraps>

801052ec <vector25>:
.globl vector25
vector25:
  pushl $0
801052ec:	6a 00                	push   $0x0
  pushl $25
801052ee:	6a 19                	push   $0x19
  jmp alltraps
801052f0:	e9 9e fa ff ff       	jmp    80104d93 <alltraps>

801052f5 <vector26>:
.globl vector26
vector26:
  pushl $0
801052f5:	6a 00                	push   $0x0
  pushl $26
801052f7:	6a 1a                	push   $0x1a
  jmp alltraps
801052f9:	e9 95 fa ff ff       	jmp    80104d93 <alltraps>

801052fe <vector27>:
.globl vector27
vector27:
  pushl $0
801052fe:	6a 00                	push   $0x0
  pushl $27
80105300:	6a 1b                	push   $0x1b
  jmp alltraps
80105302:	e9 8c fa ff ff       	jmp    80104d93 <alltraps>

80105307 <vector28>:
.globl vector28
vector28:
  pushl $0
80105307:	6a 00                	push   $0x0
  pushl $28
80105309:	6a 1c                	push   $0x1c
  jmp alltraps
8010530b:	e9 83 fa ff ff       	jmp    80104d93 <alltraps>

80105310 <vector29>:
.globl vector29
vector29:
  pushl $0
80105310:	6a 00                	push   $0x0
  pushl $29
80105312:	6a 1d                	push   $0x1d
  jmp alltraps
80105314:	e9 7a fa ff ff       	jmp    80104d93 <alltraps>

80105319 <vector30>:
.globl vector30
vector30:
  pushl $0
80105319:	6a 00                	push   $0x0
  pushl $30
8010531b:	6a 1e                	push   $0x1e
  jmp alltraps
8010531d:	e9 71 fa ff ff       	jmp    80104d93 <alltraps>

80105322 <vector31>:
.globl vector31
vector31:
  pushl $0
80105322:	6a 00                	push   $0x0
  pushl $31
80105324:	6a 1f                	push   $0x1f
  jmp alltraps
80105326:	e9 68 fa ff ff       	jmp    80104d93 <alltraps>

8010532b <vector32>:
.globl vector32
vector32:
  pushl $0
8010532b:	6a 00                	push   $0x0
  pushl $32
8010532d:	6a 20                	push   $0x20
  jmp alltraps
8010532f:	e9 5f fa ff ff       	jmp    80104d93 <alltraps>

80105334 <vector33>:
.globl vector33
vector33:
  pushl $0
80105334:	6a 00                	push   $0x0
  pushl $33
80105336:	6a 21                	push   $0x21
  jmp alltraps
80105338:	e9 56 fa ff ff       	jmp    80104d93 <alltraps>

8010533d <vector34>:
.globl vector34
vector34:
  pushl $0
8010533d:	6a 00                	push   $0x0
  pushl $34
8010533f:	6a 22                	push   $0x22
  jmp alltraps
80105341:	e9 4d fa ff ff       	jmp    80104d93 <alltraps>

80105346 <vector35>:
.globl vector35
vector35:
  pushl $0
80105346:	6a 00                	push   $0x0
  pushl $35
80105348:	6a 23                	push   $0x23
  jmp alltraps
8010534a:	e9 44 fa ff ff       	jmp    80104d93 <alltraps>

8010534f <vector36>:
.globl vector36
vector36:
  pushl $0
8010534f:	6a 00                	push   $0x0
  pushl $36
80105351:	6a 24                	push   $0x24
  jmp alltraps
80105353:	e9 3b fa ff ff       	jmp    80104d93 <alltraps>

80105358 <vector37>:
.globl vector37
vector37:
  pushl $0
80105358:	6a 00                	push   $0x0
  pushl $37
8010535a:	6a 25                	push   $0x25
  jmp alltraps
8010535c:	e9 32 fa ff ff       	jmp    80104d93 <alltraps>

80105361 <vector38>:
.globl vector38
vector38:
  pushl $0
80105361:	6a 00                	push   $0x0
  pushl $38
80105363:	6a 26                	push   $0x26
  jmp alltraps
80105365:	e9 29 fa ff ff       	jmp    80104d93 <alltraps>

8010536a <vector39>:
.globl vector39
vector39:
  pushl $0
8010536a:	6a 00                	push   $0x0
  pushl $39
8010536c:	6a 27                	push   $0x27
  jmp alltraps
8010536e:	e9 20 fa ff ff       	jmp    80104d93 <alltraps>

80105373 <vector40>:
.globl vector40
vector40:
  pushl $0
80105373:	6a 00                	push   $0x0
  pushl $40
80105375:	6a 28                	push   $0x28
  jmp alltraps
80105377:	e9 17 fa ff ff       	jmp    80104d93 <alltraps>

8010537c <vector41>:
.globl vector41
vector41:
  pushl $0
8010537c:	6a 00                	push   $0x0
  pushl $41
8010537e:	6a 29                	push   $0x29
  jmp alltraps
80105380:	e9 0e fa ff ff       	jmp    80104d93 <alltraps>

80105385 <vector42>:
.globl vector42
vector42:
  pushl $0
80105385:	6a 00                	push   $0x0
  pushl $42
80105387:	6a 2a                	push   $0x2a
  jmp alltraps
80105389:	e9 05 fa ff ff       	jmp    80104d93 <alltraps>

8010538e <vector43>:
.globl vector43
vector43:
  pushl $0
8010538e:	6a 00                	push   $0x0
  pushl $43
80105390:	6a 2b                	push   $0x2b
  jmp alltraps
80105392:	e9 fc f9 ff ff       	jmp    80104d93 <alltraps>

80105397 <vector44>:
.globl vector44
vector44:
  pushl $0
80105397:	6a 00                	push   $0x0
  pushl $44
80105399:	6a 2c                	push   $0x2c
  jmp alltraps
8010539b:	e9 f3 f9 ff ff       	jmp    80104d93 <alltraps>

801053a0 <vector45>:
.globl vector45
vector45:
  pushl $0
801053a0:	6a 00                	push   $0x0
  pushl $45
801053a2:	6a 2d                	push   $0x2d
  jmp alltraps
801053a4:	e9 ea f9 ff ff       	jmp    80104d93 <alltraps>

801053a9 <vector46>:
.globl vector46
vector46:
  pushl $0
801053a9:	6a 00                	push   $0x0
  pushl $46
801053ab:	6a 2e                	push   $0x2e
  jmp alltraps
801053ad:	e9 e1 f9 ff ff       	jmp    80104d93 <alltraps>

801053b2 <vector47>:
.globl vector47
vector47:
  pushl $0
801053b2:	6a 00                	push   $0x0
  pushl $47
801053b4:	6a 2f                	push   $0x2f
  jmp alltraps
801053b6:	e9 d8 f9 ff ff       	jmp    80104d93 <alltraps>

801053bb <vector48>:
.globl vector48
vector48:
  pushl $0
801053bb:	6a 00                	push   $0x0
  pushl $48
801053bd:	6a 30                	push   $0x30
  jmp alltraps
801053bf:	e9 cf f9 ff ff       	jmp    80104d93 <alltraps>

801053c4 <vector49>:
.globl vector49
vector49:
  pushl $0
801053c4:	6a 00                	push   $0x0
  pushl $49
801053c6:	6a 31                	push   $0x31
  jmp alltraps
801053c8:	e9 c6 f9 ff ff       	jmp    80104d93 <alltraps>

801053cd <vector50>:
.globl vector50
vector50:
  pushl $0
801053cd:	6a 00                	push   $0x0
  pushl $50
801053cf:	6a 32                	push   $0x32
  jmp alltraps
801053d1:	e9 bd f9 ff ff       	jmp    80104d93 <alltraps>

801053d6 <vector51>:
.globl vector51
vector51:
  pushl $0
801053d6:	6a 00                	push   $0x0
  pushl $51
801053d8:	6a 33                	push   $0x33
  jmp alltraps
801053da:	e9 b4 f9 ff ff       	jmp    80104d93 <alltraps>

801053df <vector52>:
.globl vector52
vector52:
  pushl $0
801053df:	6a 00                	push   $0x0
  pushl $52
801053e1:	6a 34                	push   $0x34
  jmp alltraps
801053e3:	e9 ab f9 ff ff       	jmp    80104d93 <alltraps>

801053e8 <vector53>:
.globl vector53
vector53:
  pushl $0
801053e8:	6a 00                	push   $0x0
  pushl $53
801053ea:	6a 35                	push   $0x35
  jmp alltraps
801053ec:	e9 a2 f9 ff ff       	jmp    80104d93 <alltraps>

801053f1 <vector54>:
.globl vector54
vector54:
  pushl $0
801053f1:	6a 00                	push   $0x0
  pushl $54
801053f3:	6a 36                	push   $0x36
  jmp alltraps
801053f5:	e9 99 f9 ff ff       	jmp    80104d93 <alltraps>

801053fa <vector55>:
.globl vector55
vector55:
  pushl $0
801053fa:	6a 00                	push   $0x0
  pushl $55
801053fc:	6a 37                	push   $0x37
  jmp alltraps
801053fe:	e9 90 f9 ff ff       	jmp    80104d93 <alltraps>

80105403 <vector56>:
.globl vector56
vector56:
  pushl $0
80105403:	6a 00                	push   $0x0
  pushl $56
80105405:	6a 38                	push   $0x38
  jmp alltraps
80105407:	e9 87 f9 ff ff       	jmp    80104d93 <alltraps>

8010540c <vector57>:
.globl vector57
vector57:
  pushl $0
8010540c:	6a 00                	push   $0x0
  pushl $57
8010540e:	6a 39                	push   $0x39
  jmp alltraps
80105410:	e9 7e f9 ff ff       	jmp    80104d93 <alltraps>

80105415 <vector58>:
.globl vector58
vector58:
  pushl $0
80105415:	6a 00                	push   $0x0
  pushl $58
80105417:	6a 3a                	push   $0x3a
  jmp alltraps
80105419:	e9 75 f9 ff ff       	jmp    80104d93 <alltraps>

8010541e <vector59>:
.globl vector59
vector59:
  pushl $0
8010541e:	6a 00                	push   $0x0
  pushl $59
80105420:	6a 3b                	push   $0x3b
  jmp alltraps
80105422:	e9 6c f9 ff ff       	jmp    80104d93 <alltraps>

80105427 <vector60>:
.globl vector60
vector60:
  pushl $0
80105427:	6a 00                	push   $0x0
  pushl $60
80105429:	6a 3c                	push   $0x3c
  jmp alltraps
8010542b:	e9 63 f9 ff ff       	jmp    80104d93 <alltraps>

80105430 <vector61>:
.globl vector61
vector61:
  pushl $0
80105430:	6a 00                	push   $0x0
  pushl $61
80105432:	6a 3d                	push   $0x3d
  jmp alltraps
80105434:	e9 5a f9 ff ff       	jmp    80104d93 <alltraps>

80105439 <vector62>:
.globl vector62
vector62:
  pushl $0
80105439:	6a 00                	push   $0x0
  pushl $62
8010543b:	6a 3e                	push   $0x3e
  jmp alltraps
8010543d:	e9 51 f9 ff ff       	jmp    80104d93 <alltraps>

80105442 <vector63>:
.globl vector63
vector63:
  pushl $0
80105442:	6a 00                	push   $0x0
  pushl $63
80105444:	6a 3f                	push   $0x3f
  jmp alltraps
80105446:	e9 48 f9 ff ff       	jmp    80104d93 <alltraps>

8010544b <vector64>:
.globl vector64
vector64:
  pushl $0
8010544b:	6a 00                	push   $0x0
  pushl $64
8010544d:	6a 40                	push   $0x40
  jmp alltraps
8010544f:	e9 3f f9 ff ff       	jmp    80104d93 <alltraps>

80105454 <vector65>:
.globl vector65
vector65:
  pushl $0
80105454:	6a 00                	push   $0x0
  pushl $65
80105456:	6a 41                	push   $0x41
  jmp alltraps
80105458:	e9 36 f9 ff ff       	jmp    80104d93 <alltraps>

8010545d <vector66>:
.globl vector66
vector66:
  pushl $0
8010545d:	6a 00                	push   $0x0
  pushl $66
8010545f:	6a 42                	push   $0x42
  jmp alltraps
80105461:	e9 2d f9 ff ff       	jmp    80104d93 <alltraps>

80105466 <vector67>:
.globl vector67
vector67:
  pushl $0
80105466:	6a 00                	push   $0x0
  pushl $67
80105468:	6a 43                	push   $0x43
  jmp alltraps
8010546a:	e9 24 f9 ff ff       	jmp    80104d93 <alltraps>

8010546f <vector68>:
.globl vector68
vector68:
  pushl $0
8010546f:	6a 00                	push   $0x0
  pushl $68
80105471:	6a 44                	push   $0x44
  jmp alltraps
80105473:	e9 1b f9 ff ff       	jmp    80104d93 <alltraps>

80105478 <vector69>:
.globl vector69
vector69:
  pushl $0
80105478:	6a 00                	push   $0x0
  pushl $69
8010547a:	6a 45                	push   $0x45
  jmp alltraps
8010547c:	e9 12 f9 ff ff       	jmp    80104d93 <alltraps>

80105481 <vector70>:
.globl vector70
vector70:
  pushl $0
80105481:	6a 00                	push   $0x0
  pushl $70
80105483:	6a 46                	push   $0x46
  jmp alltraps
80105485:	e9 09 f9 ff ff       	jmp    80104d93 <alltraps>

8010548a <vector71>:
.globl vector71
vector71:
  pushl $0
8010548a:	6a 00                	push   $0x0
  pushl $71
8010548c:	6a 47                	push   $0x47
  jmp alltraps
8010548e:	e9 00 f9 ff ff       	jmp    80104d93 <alltraps>

80105493 <vector72>:
.globl vector72
vector72:
  pushl $0
80105493:	6a 00                	push   $0x0
  pushl $72
80105495:	6a 48                	push   $0x48
  jmp alltraps
80105497:	e9 f7 f8 ff ff       	jmp    80104d93 <alltraps>

8010549c <vector73>:
.globl vector73
vector73:
  pushl $0
8010549c:	6a 00                	push   $0x0
  pushl $73
8010549e:	6a 49                	push   $0x49
  jmp alltraps
801054a0:	e9 ee f8 ff ff       	jmp    80104d93 <alltraps>

801054a5 <vector74>:
.globl vector74
vector74:
  pushl $0
801054a5:	6a 00                	push   $0x0
  pushl $74
801054a7:	6a 4a                	push   $0x4a
  jmp alltraps
801054a9:	e9 e5 f8 ff ff       	jmp    80104d93 <alltraps>

801054ae <vector75>:
.globl vector75
vector75:
  pushl $0
801054ae:	6a 00                	push   $0x0
  pushl $75
801054b0:	6a 4b                	push   $0x4b
  jmp alltraps
801054b2:	e9 dc f8 ff ff       	jmp    80104d93 <alltraps>

801054b7 <vector76>:
.globl vector76
vector76:
  pushl $0
801054b7:	6a 00                	push   $0x0
  pushl $76
801054b9:	6a 4c                	push   $0x4c
  jmp alltraps
801054bb:	e9 d3 f8 ff ff       	jmp    80104d93 <alltraps>

801054c0 <vector77>:
.globl vector77
vector77:
  pushl $0
801054c0:	6a 00                	push   $0x0
  pushl $77
801054c2:	6a 4d                	push   $0x4d
  jmp alltraps
801054c4:	e9 ca f8 ff ff       	jmp    80104d93 <alltraps>

801054c9 <vector78>:
.globl vector78
vector78:
  pushl $0
801054c9:	6a 00                	push   $0x0
  pushl $78
801054cb:	6a 4e                	push   $0x4e
  jmp alltraps
801054cd:	e9 c1 f8 ff ff       	jmp    80104d93 <alltraps>

801054d2 <vector79>:
.globl vector79
vector79:
  pushl $0
801054d2:	6a 00                	push   $0x0
  pushl $79
801054d4:	6a 4f                	push   $0x4f
  jmp alltraps
801054d6:	e9 b8 f8 ff ff       	jmp    80104d93 <alltraps>

801054db <vector80>:
.globl vector80
vector80:
  pushl $0
801054db:	6a 00                	push   $0x0
  pushl $80
801054dd:	6a 50                	push   $0x50
  jmp alltraps
801054df:	e9 af f8 ff ff       	jmp    80104d93 <alltraps>

801054e4 <vector81>:
.globl vector81
vector81:
  pushl $0
801054e4:	6a 00                	push   $0x0
  pushl $81
801054e6:	6a 51                	push   $0x51
  jmp alltraps
801054e8:	e9 a6 f8 ff ff       	jmp    80104d93 <alltraps>

801054ed <vector82>:
.globl vector82
vector82:
  pushl $0
801054ed:	6a 00                	push   $0x0
  pushl $82
801054ef:	6a 52                	push   $0x52
  jmp alltraps
801054f1:	e9 9d f8 ff ff       	jmp    80104d93 <alltraps>

801054f6 <vector83>:
.globl vector83
vector83:
  pushl $0
801054f6:	6a 00                	push   $0x0
  pushl $83
801054f8:	6a 53                	push   $0x53
  jmp alltraps
801054fa:	e9 94 f8 ff ff       	jmp    80104d93 <alltraps>

801054ff <vector84>:
.globl vector84
vector84:
  pushl $0
801054ff:	6a 00                	push   $0x0
  pushl $84
80105501:	6a 54                	push   $0x54
  jmp alltraps
80105503:	e9 8b f8 ff ff       	jmp    80104d93 <alltraps>

80105508 <vector85>:
.globl vector85
vector85:
  pushl $0
80105508:	6a 00                	push   $0x0
  pushl $85
8010550a:	6a 55                	push   $0x55
  jmp alltraps
8010550c:	e9 82 f8 ff ff       	jmp    80104d93 <alltraps>

80105511 <vector86>:
.globl vector86
vector86:
  pushl $0
80105511:	6a 00                	push   $0x0
  pushl $86
80105513:	6a 56                	push   $0x56
  jmp alltraps
80105515:	e9 79 f8 ff ff       	jmp    80104d93 <alltraps>

8010551a <vector87>:
.globl vector87
vector87:
  pushl $0
8010551a:	6a 00                	push   $0x0
  pushl $87
8010551c:	6a 57                	push   $0x57
  jmp alltraps
8010551e:	e9 70 f8 ff ff       	jmp    80104d93 <alltraps>

80105523 <vector88>:
.globl vector88
vector88:
  pushl $0
80105523:	6a 00                	push   $0x0
  pushl $88
80105525:	6a 58                	push   $0x58
  jmp alltraps
80105527:	e9 67 f8 ff ff       	jmp    80104d93 <alltraps>

8010552c <vector89>:
.globl vector89
vector89:
  pushl $0
8010552c:	6a 00                	push   $0x0
  pushl $89
8010552e:	6a 59                	push   $0x59
  jmp alltraps
80105530:	e9 5e f8 ff ff       	jmp    80104d93 <alltraps>

80105535 <vector90>:
.globl vector90
vector90:
  pushl $0
80105535:	6a 00                	push   $0x0
  pushl $90
80105537:	6a 5a                	push   $0x5a
  jmp alltraps
80105539:	e9 55 f8 ff ff       	jmp    80104d93 <alltraps>

8010553e <vector91>:
.globl vector91
vector91:
  pushl $0
8010553e:	6a 00                	push   $0x0
  pushl $91
80105540:	6a 5b                	push   $0x5b
  jmp alltraps
80105542:	e9 4c f8 ff ff       	jmp    80104d93 <alltraps>

80105547 <vector92>:
.globl vector92
vector92:
  pushl $0
80105547:	6a 00                	push   $0x0
  pushl $92
80105549:	6a 5c                	push   $0x5c
  jmp alltraps
8010554b:	e9 43 f8 ff ff       	jmp    80104d93 <alltraps>

80105550 <vector93>:
.globl vector93
vector93:
  pushl $0
80105550:	6a 00                	push   $0x0
  pushl $93
80105552:	6a 5d                	push   $0x5d
  jmp alltraps
80105554:	e9 3a f8 ff ff       	jmp    80104d93 <alltraps>

80105559 <vector94>:
.globl vector94
vector94:
  pushl $0
80105559:	6a 00                	push   $0x0
  pushl $94
8010555b:	6a 5e                	push   $0x5e
  jmp alltraps
8010555d:	e9 31 f8 ff ff       	jmp    80104d93 <alltraps>

80105562 <vector95>:
.globl vector95
vector95:
  pushl $0
80105562:	6a 00                	push   $0x0
  pushl $95
80105564:	6a 5f                	push   $0x5f
  jmp alltraps
80105566:	e9 28 f8 ff ff       	jmp    80104d93 <alltraps>

8010556b <vector96>:
.globl vector96
vector96:
  pushl $0
8010556b:	6a 00                	push   $0x0
  pushl $96
8010556d:	6a 60                	push   $0x60
  jmp alltraps
8010556f:	e9 1f f8 ff ff       	jmp    80104d93 <alltraps>

80105574 <vector97>:
.globl vector97
vector97:
  pushl $0
80105574:	6a 00                	push   $0x0
  pushl $97
80105576:	6a 61                	push   $0x61
  jmp alltraps
80105578:	e9 16 f8 ff ff       	jmp    80104d93 <alltraps>

8010557d <vector98>:
.globl vector98
vector98:
  pushl $0
8010557d:	6a 00                	push   $0x0
  pushl $98
8010557f:	6a 62                	push   $0x62
  jmp alltraps
80105581:	e9 0d f8 ff ff       	jmp    80104d93 <alltraps>

80105586 <vector99>:
.globl vector99
vector99:
  pushl $0
80105586:	6a 00                	push   $0x0
  pushl $99
80105588:	6a 63                	push   $0x63
  jmp alltraps
8010558a:	e9 04 f8 ff ff       	jmp    80104d93 <alltraps>

8010558f <vector100>:
.globl vector100
vector100:
  pushl $0
8010558f:	6a 00                	push   $0x0
  pushl $100
80105591:	6a 64                	push   $0x64
  jmp alltraps
80105593:	e9 fb f7 ff ff       	jmp    80104d93 <alltraps>

80105598 <vector101>:
.globl vector101
vector101:
  pushl $0
80105598:	6a 00                	push   $0x0
  pushl $101
8010559a:	6a 65                	push   $0x65
  jmp alltraps
8010559c:	e9 f2 f7 ff ff       	jmp    80104d93 <alltraps>

801055a1 <vector102>:
.globl vector102
vector102:
  pushl $0
801055a1:	6a 00                	push   $0x0
  pushl $102
801055a3:	6a 66                	push   $0x66
  jmp alltraps
801055a5:	e9 e9 f7 ff ff       	jmp    80104d93 <alltraps>

801055aa <vector103>:
.globl vector103
vector103:
  pushl $0
801055aa:	6a 00                	push   $0x0
  pushl $103
801055ac:	6a 67                	push   $0x67
  jmp alltraps
801055ae:	e9 e0 f7 ff ff       	jmp    80104d93 <alltraps>

801055b3 <vector104>:
.globl vector104
vector104:
  pushl $0
801055b3:	6a 00                	push   $0x0
  pushl $104
801055b5:	6a 68                	push   $0x68
  jmp alltraps
801055b7:	e9 d7 f7 ff ff       	jmp    80104d93 <alltraps>

801055bc <vector105>:
.globl vector105
vector105:
  pushl $0
801055bc:	6a 00                	push   $0x0
  pushl $105
801055be:	6a 69                	push   $0x69
  jmp alltraps
801055c0:	e9 ce f7 ff ff       	jmp    80104d93 <alltraps>

801055c5 <vector106>:
.globl vector106
vector106:
  pushl $0
801055c5:	6a 00                	push   $0x0
  pushl $106
801055c7:	6a 6a                	push   $0x6a
  jmp alltraps
801055c9:	e9 c5 f7 ff ff       	jmp    80104d93 <alltraps>

801055ce <vector107>:
.globl vector107
vector107:
  pushl $0
801055ce:	6a 00                	push   $0x0
  pushl $107
801055d0:	6a 6b                	push   $0x6b
  jmp alltraps
801055d2:	e9 bc f7 ff ff       	jmp    80104d93 <alltraps>

801055d7 <vector108>:
.globl vector108
vector108:
  pushl $0
801055d7:	6a 00                	push   $0x0
  pushl $108
801055d9:	6a 6c                	push   $0x6c
  jmp alltraps
801055db:	e9 b3 f7 ff ff       	jmp    80104d93 <alltraps>

801055e0 <vector109>:
.globl vector109
vector109:
  pushl $0
801055e0:	6a 00                	push   $0x0
  pushl $109
801055e2:	6a 6d                	push   $0x6d
  jmp alltraps
801055e4:	e9 aa f7 ff ff       	jmp    80104d93 <alltraps>

801055e9 <vector110>:
.globl vector110
vector110:
  pushl $0
801055e9:	6a 00                	push   $0x0
  pushl $110
801055eb:	6a 6e                	push   $0x6e
  jmp alltraps
801055ed:	e9 a1 f7 ff ff       	jmp    80104d93 <alltraps>

801055f2 <vector111>:
.globl vector111
vector111:
  pushl $0
801055f2:	6a 00                	push   $0x0
  pushl $111
801055f4:	6a 6f                	push   $0x6f
  jmp alltraps
801055f6:	e9 98 f7 ff ff       	jmp    80104d93 <alltraps>

801055fb <vector112>:
.globl vector112
vector112:
  pushl $0
801055fb:	6a 00                	push   $0x0
  pushl $112
801055fd:	6a 70                	push   $0x70
  jmp alltraps
801055ff:	e9 8f f7 ff ff       	jmp    80104d93 <alltraps>

80105604 <vector113>:
.globl vector113
vector113:
  pushl $0
80105604:	6a 00                	push   $0x0
  pushl $113
80105606:	6a 71                	push   $0x71
  jmp alltraps
80105608:	e9 86 f7 ff ff       	jmp    80104d93 <alltraps>

8010560d <vector114>:
.globl vector114
vector114:
  pushl $0
8010560d:	6a 00                	push   $0x0
  pushl $114
8010560f:	6a 72                	push   $0x72
  jmp alltraps
80105611:	e9 7d f7 ff ff       	jmp    80104d93 <alltraps>

80105616 <vector115>:
.globl vector115
vector115:
  pushl $0
80105616:	6a 00                	push   $0x0
  pushl $115
80105618:	6a 73                	push   $0x73
  jmp alltraps
8010561a:	e9 74 f7 ff ff       	jmp    80104d93 <alltraps>

8010561f <vector116>:
.globl vector116
vector116:
  pushl $0
8010561f:	6a 00                	push   $0x0
  pushl $116
80105621:	6a 74                	push   $0x74
  jmp alltraps
80105623:	e9 6b f7 ff ff       	jmp    80104d93 <alltraps>

80105628 <vector117>:
.globl vector117
vector117:
  pushl $0
80105628:	6a 00                	push   $0x0
  pushl $117
8010562a:	6a 75                	push   $0x75
  jmp alltraps
8010562c:	e9 62 f7 ff ff       	jmp    80104d93 <alltraps>

80105631 <vector118>:
.globl vector118
vector118:
  pushl $0
80105631:	6a 00                	push   $0x0
  pushl $118
80105633:	6a 76                	push   $0x76
  jmp alltraps
80105635:	e9 59 f7 ff ff       	jmp    80104d93 <alltraps>

8010563a <vector119>:
.globl vector119
vector119:
  pushl $0
8010563a:	6a 00                	push   $0x0
  pushl $119
8010563c:	6a 77                	push   $0x77
  jmp alltraps
8010563e:	e9 50 f7 ff ff       	jmp    80104d93 <alltraps>

80105643 <vector120>:
.globl vector120
vector120:
  pushl $0
80105643:	6a 00                	push   $0x0
  pushl $120
80105645:	6a 78                	push   $0x78
  jmp alltraps
80105647:	e9 47 f7 ff ff       	jmp    80104d93 <alltraps>

8010564c <vector121>:
.globl vector121
vector121:
  pushl $0
8010564c:	6a 00                	push   $0x0
  pushl $121
8010564e:	6a 79                	push   $0x79
  jmp alltraps
80105650:	e9 3e f7 ff ff       	jmp    80104d93 <alltraps>

80105655 <vector122>:
.globl vector122
vector122:
  pushl $0
80105655:	6a 00                	push   $0x0
  pushl $122
80105657:	6a 7a                	push   $0x7a
  jmp alltraps
80105659:	e9 35 f7 ff ff       	jmp    80104d93 <alltraps>

8010565e <vector123>:
.globl vector123
vector123:
  pushl $0
8010565e:	6a 00                	push   $0x0
  pushl $123
80105660:	6a 7b                	push   $0x7b
  jmp alltraps
80105662:	e9 2c f7 ff ff       	jmp    80104d93 <alltraps>

80105667 <vector124>:
.globl vector124
vector124:
  pushl $0
80105667:	6a 00                	push   $0x0
  pushl $124
80105669:	6a 7c                	push   $0x7c
  jmp alltraps
8010566b:	e9 23 f7 ff ff       	jmp    80104d93 <alltraps>

80105670 <vector125>:
.globl vector125
vector125:
  pushl $0
80105670:	6a 00                	push   $0x0
  pushl $125
80105672:	6a 7d                	push   $0x7d
  jmp alltraps
80105674:	e9 1a f7 ff ff       	jmp    80104d93 <alltraps>

80105679 <vector126>:
.globl vector126
vector126:
  pushl $0
80105679:	6a 00                	push   $0x0
  pushl $126
8010567b:	6a 7e                	push   $0x7e
  jmp alltraps
8010567d:	e9 11 f7 ff ff       	jmp    80104d93 <alltraps>

80105682 <vector127>:
.globl vector127
vector127:
  pushl $0
80105682:	6a 00                	push   $0x0
  pushl $127
80105684:	6a 7f                	push   $0x7f
  jmp alltraps
80105686:	e9 08 f7 ff ff       	jmp    80104d93 <alltraps>

8010568b <vector128>:
.globl vector128
vector128:
  pushl $0
8010568b:	6a 00                	push   $0x0
  pushl $128
8010568d:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105692:	e9 fc f6 ff ff       	jmp    80104d93 <alltraps>

80105697 <vector129>:
.globl vector129
vector129:
  pushl $0
80105697:	6a 00                	push   $0x0
  pushl $129
80105699:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010569e:	e9 f0 f6 ff ff       	jmp    80104d93 <alltraps>

801056a3 <vector130>:
.globl vector130
vector130:
  pushl $0
801056a3:	6a 00                	push   $0x0
  pushl $130
801056a5:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801056aa:	e9 e4 f6 ff ff       	jmp    80104d93 <alltraps>

801056af <vector131>:
.globl vector131
vector131:
  pushl $0
801056af:	6a 00                	push   $0x0
  pushl $131
801056b1:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801056b6:	e9 d8 f6 ff ff       	jmp    80104d93 <alltraps>

801056bb <vector132>:
.globl vector132
vector132:
  pushl $0
801056bb:	6a 00                	push   $0x0
  pushl $132
801056bd:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801056c2:	e9 cc f6 ff ff       	jmp    80104d93 <alltraps>

801056c7 <vector133>:
.globl vector133
vector133:
  pushl $0
801056c7:	6a 00                	push   $0x0
  pushl $133
801056c9:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801056ce:	e9 c0 f6 ff ff       	jmp    80104d93 <alltraps>

801056d3 <vector134>:
.globl vector134
vector134:
  pushl $0
801056d3:	6a 00                	push   $0x0
  pushl $134
801056d5:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801056da:	e9 b4 f6 ff ff       	jmp    80104d93 <alltraps>

801056df <vector135>:
.globl vector135
vector135:
  pushl $0
801056df:	6a 00                	push   $0x0
  pushl $135
801056e1:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801056e6:	e9 a8 f6 ff ff       	jmp    80104d93 <alltraps>

801056eb <vector136>:
.globl vector136
vector136:
  pushl $0
801056eb:	6a 00                	push   $0x0
  pushl $136
801056ed:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801056f2:	e9 9c f6 ff ff       	jmp    80104d93 <alltraps>

801056f7 <vector137>:
.globl vector137
vector137:
  pushl $0
801056f7:	6a 00                	push   $0x0
  pushl $137
801056f9:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801056fe:	e9 90 f6 ff ff       	jmp    80104d93 <alltraps>

80105703 <vector138>:
.globl vector138
vector138:
  pushl $0
80105703:	6a 00                	push   $0x0
  pushl $138
80105705:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010570a:	e9 84 f6 ff ff       	jmp    80104d93 <alltraps>

8010570f <vector139>:
.globl vector139
vector139:
  pushl $0
8010570f:	6a 00                	push   $0x0
  pushl $139
80105711:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105716:	e9 78 f6 ff ff       	jmp    80104d93 <alltraps>

8010571b <vector140>:
.globl vector140
vector140:
  pushl $0
8010571b:	6a 00                	push   $0x0
  pushl $140
8010571d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105722:	e9 6c f6 ff ff       	jmp    80104d93 <alltraps>

80105727 <vector141>:
.globl vector141
vector141:
  pushl $0
80105727:	6a 00                	push   $0x0
  pushl $141
80105729:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010572e:	e9 60 f6 ff ff       	jmp    80104d93 <alltraps>

80105733 <vector142>:
.globl vector142
vector142:
  pushl $0
80105733:	6a 00                	push   $0x0
  pushl $142
80105735:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010573a:	e9 54 f6 ff ff       	jmp    80104d93 <alltraps>

8010573f <vector143>:
.globl vector143
vector143:
  pushl $0
8010573f:	6a 00                	push   $0x0
  pushl $143
80105741:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105746:	e9 48 f6 ff ff       	jmp    80104d93 <alltraps>

8010574b <vector144>:
.globl vector144
vector144:
  pushl $0
8010574b:	6a 00                	push   $0x0
  pushl $144
8010574d:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105752:	e9 3c f6 ff ff       	jmp    80104d93 <alltraps>

80105757 <vector145>:
.globl vector145
vector145:
  pushl $0
80105757:	6a 00                	push   $0x0
  pushl $145
80105759:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010575e:	e9 30 f6 ff ff       	jmp    80104d93 <alltraps>

80105763 <vector146>:
.globl vector146
vector146:
  pushl $0
80105763:	6a 00                	push   $0x0
  pushl $146
80105765:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010576a:	e9 24 f6 ff ff       	jmp    80104d93 <alltraps>

8010576f <vector147>:
.globl vector147
vector147:
  pushl $0
8010576f:	6a 00                	push   $0x0
  pushl $147
80105771:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105776:	e9 18 f6 ff ff       	jmp    80104d93 <alltraps>

8010577b <vector148>:
.globl vector148
vector148:
  pushl $0
8010577b:	6a 00                	push   $0x0
  pushl $148
8010577d:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105782:	e9 0c f6 ff ff       	jmp    80104d93 <alltraps>

80105787 <vector149>:
.globl vector149
vector149:
  pushl $0
80105787:	6a 00                	push   $0x0
  pushl $149
80105789:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010578e:	e9 00 f6 ff ff       	jmp    80104d93 <alltraps>

80105793 <vector150>:
.globl vector150
vector150:
  pushl $0
80105793:	6a 00                	push   $0x0
  pushl $150
80105795:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010579a:	e9 f4 f5 ff ff       	jmp    80104d93 <alltraps>

8010579f <vector151>:
.globl vector151
vector151:
  pushl $0
8010579f:	6a 00                	push   $0x0
  pushl $151
801057a1:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801057a6:	e9 e8 f5 ff ff       	jmp    80104d93 <alltraps>

801057ab <vector152>:
.globl vector152
vector152:
  pushl $0
801057ab:	6a 00                	push   $0x0
  pushl $152
801057ad:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801057b2:	e9 dc f5 ff ff       	jmp    80104d93 <alltraps>

801057b7 <vector153>:
.globl vector153
vector153:
  pushl $0
801057b7:	6a 00                	push   $0x0
  pushl $153
801057b9:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801057be:	e9 d0 f5 ff ff       	jmp    80104d93 <alltraps>

801057c3 <vector154>:
.globl vector154
vector154:
  pushl $0
801057c3:	6a 00                	push   $0x0
  pushl $154
801057c5:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801057ca:	e9 c4 f5 ff ff       	jmp    80104d93 <alltraps>

801057cf <vector155>:
.globl vector155
vector155:
  pushl $0
801057cf:	6a 00                	push   $0x0
  pushl $155
801057d1:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801057d6:	e9 b8 f5 ff ff       	jmp    80104d93 <alltraps>

801057db <vector156>:
.globl vector156
vector156:
  pushl $0
801057db:	6a 00                	push   $0x0
  pushl $156
801057dd:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801057e2:	e9 ac f5 ff ff       	jmp    80104d93 <alltraps>

801057e7 <vector157>:
.globl vector157
vector157:
  pushl $0
801057e7:	6a 00                	push   $0x0
  pushl $157
801057e9:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801057ee:	e9 a0 f5 ff ff       	jmp    80104d93 <alltraps>

801057f3 <vector158>:
.globl vector158
vector158:
  pushl $0
801057f3:	6a 00                	push   $0x0
  pushl $158
801057f5:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801057fa:	e9 94 f5 ff ff       	jmp    80104d93 <alltraps>

801057ff <vector159>:
.globl vector159
vector159:
  pushl $0
801057ff:	6a 00                	push   $0x0
  pushl $159
80105801:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105806:	e9 88 f5 ff ff       	jmp    80104d93 <alltraps>

8010580b <vector160>:
.globl vector160
vector160:
  pushl $0
8010580b:	6a 00                	push   $0x0
  pushl $160
8010580d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105812:	e9 7c f5 ff ff       	jmp    80104d93 <alltraps>

80105817 <vector161>:
.globl vector161
vector161:
  pushl $0
80105817:	6a 00                	push   $0x0
  pushl $161
80105819:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010581e:	e9 70 f5 ff ff       	jmp    80104d93 <alltraps>

80105823 <vector162>:
.globl vector162
vector162:
  pushl $0
80105823:	6a 00                	push   $0x0
  pushl $162
80105825:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010582a:	e9 64 f5 ff ff       	jmp    80104d93 <alltraps>

8010582f <vector163>:
.globl vector163
vector163:
  pushl $0
8010582f:	6a 00                	push   $0x0
  pushl $163
80105831:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105836:	e9 58 f5 ff ff       	jmp    80104d93 <alltraps>

8010583b <vector164>:
.globl vector164
vector164:
  pushl $0
8010583b:	6a 00                	push   $0x0
  pushl $164
8010583d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105842:	e9 4c f5 ff ff       	jmp    80104d93 <alltraps>

80105847 <vector165>:
.globl vector165
vector165:
  pushl $0
80105847:	6a 00                	push   $0x0
  pushl $165
80105849:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010584e:	e9 40 f5 ff ff       	jmp    80104d93 <alltraps>

80105853 <vector166>:
.globl vector166
vector166:
  pushl $0
80105853:	6a 00                	push   $0x0
  pushl $166
80105855:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010585a:	e9 34 f5 ff ff       	jmp    80104d93 <alltraps>

8010585f <vector167>:
.globl vector167
vector167:
  pushl $0
8010585f:	6a 00                	push   $0x0
  pushl $167
80105861:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105866:	e9 28 f5 ff ff       	jmp    80104d93 <alltraps>

8010586b <vector168>:
.globl vector168
vector168:
  pushl $0
8010586b:	6a 00                	push   $0x0
  pushl $168
8010586d:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105872:	e9 1c f5 ff ff       	jmp    80104d93 <alltraps>

80105877 <vector169>:
.globl vector169
vector169:
  pushl $0
80105877:	6a 00                	push   $0x0
  pushl $169
80105879:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010587e:	e9 10 f5 ff ff       	jmp    80104d93 <alltraps>

80105883 <vector170>:
.globl vector170
vector170:
  pushl $0
80105883:	6a 00                	push   $0x0
  pushl $170
80105885:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010588a:	e9 04 f5 ff ff       	jmp    80104d93 <alltraps>

8010588f <vector171>:
.globl vector171
vector171:
  pushl $0
8010588f:	6a 00                	push   $0x0
  pushl $171
80105891:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105896:	e9 f8 f4 ff ff       	jmp    80104d93 <alltraps>

8010589b <vector172>:
.globl vector172
vector172:
  pushl $0
8010589b:	6a 00                	push   $0x0
  pushl $172
8010589d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801058a2:	e9 ec f4 ff ff       	jmp    80104d93 <alltraps>

801058a7 <vector173>:
.globl vector173
vector173:
  pushl $0
801058a7:	6a 00                	push   $0x0
  pushl $173
801058a9:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801058ae:	e9 e0 f4 ff ff       	jmp    80104d93 <alltraps>

801058b3 <vector174>:
.globl vector174
vector174:
  pushl $0
801058b3:	6a 00                	push   $0x0
  pushl $174
801058b5:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801058ba:	e9 d4 f4 ff ff       	jmp    80104d93 <alltraps>

801058bf <vector175>:
.globl vector175
vector175:
  pushl $0
801058bf:	6a 00                	push   $0x0
  pushl $175
801058c1:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801058c6:	e9 c8 f4 ff ff       	jmp    80104d93 <alltraps>

801058cb <vector176>:
.globl vector176
vector176:
  pushl $0
801058cb:	6a 00                	push   $0x0
  pushl $176
801058cd:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801058d2:	e9 bc f4 ff ff       	jmp    80104d93 <alltraps>

801058d7 <vector177>:
.globl vector177
vector177:
  pushl $0
801058d7:	6a 00                	push   $0x0
  pushl $177
801058d9:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801058de:	e9 b0 f4 ff ff       	jmp    80104d93 <alltraps>

801058e3 <vector178>:
.globl vector178
vector178:
  pushl $0
801058e3:	6a 00                	push   $0x0
  pushl $178
801058e5:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801058ea:	e9 a4 f4 ff ff       	jmp    80104d93 <alltraps>

801058ef <vector179>:
.globl vector179
vector179:
  pushl $0
801058ef:	6a 00                	push   $0x0
  pushl $179
801058f1:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801058f6:	e9 98 f4 ff ff       	jmp    80104d93 <alltraps>

801058fb <vector180>:
.globl vector180
vector180:
  pushl $0
801058fb:	6a 00                	push   $0x0
  pushl $180
801058fd:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105902:	e9 8c f4 ff ff       	jmp    80104d93 <alltraps>

80105907 <vector181>:
.globl vector181
vector181:
  pushl $0
80105907:	6a 00                	push   $0x0
  pushl $181
80105909:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010590e:	e9 80 f4 ff ff       	jmp    80104d93 <alltraps>

80105913 <vector182>:
.globl vector182
vector182:
  pushl $0
80105913:	6a 00                	push   $0x0
  pushl $182
80105915:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010591a:	e9 74 f4 ff ff       	jmp    80104d93 <alltraps>

8010591f <vector183>:
.globl vector183
vector183:
  pushl $0
8010591f:	6a 00                	push   $0x0
  pushl $183
80105921:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105926:	e9 68 f4 ff ff       	jmp    80104d93 <alltraps>

8010592b <vector184>:
.globl vector184
vector184:
  pushl $0
8010592b:	6a 00                	push   $0x0
  pushl $184
8010592d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105932:	e9 5c f4 ff ff       	jmp    80104d93 <alltraps>

80105937 <vector185>:
.globl vector185
vector185:
  pushl $0
80105937:	6a 00                	push   $0x0
  pushl $185
80105939:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010593e:	e9 50 f4 ff ff       	jmp    80104d93 <alltraps>

80105943 <vector186>:
.globl vector186
vector186:
  pushl $0
80105943:	6a 00                	push   $0x0
  pushl $186
80105945:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010594a:	e9 44 f4 ff ff       	jmp    80104d93 <alltraps>

8010594f <vector187>:
.globl vector187
vector187:
  pushl $0
8010594f:	6a 00                	push   $0x0
  pushl $187
80105951:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105956:	e9 38 f4 ff ff       	jmp    80104d93 <alltraps>

8010595b <vector188>:
.globl vector188
vector188:
  pushl $0
8010595b:	6a 00                	push   $0x0
  pushl $188
8010595d:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105962:	e9 2c f4 ff ff       	jmp    80104d93 <alltraps>

80105967 <vector189>:
.globl vector189
vector189:
  pushl $0
80105967:	6a 00                	push   $0x0
  pushl $189
80105969:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010596e:	e9 20 f4 ff ff       	jmp    80104d93 <alltraps>

80105973 <vector190>:
.globl vector190
vector190:
  pushl $0
80105973:	6a 00                	push   $0x0
  pushl $190
80105975:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010597a:	e9 14 f4 ff ff       	jmp    80104d93 <alltraps>

8010597f <vector191>:
.globl vector191
vector191:
  pushl $0
8010597f:	6a 00                	push   $0x0
  pushl $191
80105981:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105986:	e9 08 f4 ff ff       	jmp    80104d93 <alltraps>

8010598b <vector192>:
.globl vector192
vector192:
  pushl $0
8010598b:	6a 00                	push   $0x0
  pushl $192
8010598d:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105992:	e9 fc f3 ff ff       	jmp    80104d93 <alltraps>

80105997 <vector193>:
.globl vector193
vector193:
  pushl $0
80105997:	6a 00                	push   $0x0
  pushl $193
80105999:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010599e:	e9 f0 f3 ff ff       	jmp    80104d93 <alltraps>

801059a3 <vector194>:
.globl vector194
vector194:
  pushl $0
801059a3:	6a 00                	push   $0x0
  pushl $194
801059a5:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801059aa:	e9 e4 f3 ff ff       	jmp    80104d93 <alltraps>

801059af <vector195>:
.globl vector195
vector195:
  pushl $0
801059af:	6a 00                	push   $0x0
  pushl $195
801059b1:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801059b6:	e9 d8 f3 ff ff       	jmp    80104d93 <alltraps>

801059bb <vector196>:
.globl vector196
vector196:
  pushl $0
801059bb:	6a 00                	push   $0x0
  pushl $196
801059bd:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801059c2:	e9 cc f3 ff ff       	jmp    80104d93 <alltraps>

801059c7 <vector197>:
.globl vector197
vector197:
  pushl $0
801059c7:	6a 00                	push   $0x0
  pushl $197
801059c9:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801059ce:	e9 c0 f3 ff ff       	jmp    80104d93 <alltraps>

801059d3 <vector198>:
.globl vector198
vector198:
  pushl $0
801059d3:	6a 00                	push   $0x0
  pushl $198
801059d5:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801059da:	e9 b4 f3 ff ff       	jmp    80104d93 <alltraps>

801059df <vector199>:
.globl vector199
vector199:
  pushl $0
801059df:	6a 00                	push   $0x0
  pushl $199
801059e1:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801059e6:	e9 a8 f3 ff ff       	jmp    80104d93 <alltraps>

801059eb <vector200>:
.globl vector200
vector200:
  pushl $0
801059eb:	6a 00                	push   $0x0
  pushl $200
801059ed:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801059f2:	e9 9c f3 ff ff       	jmp    80104d93 <alltraps>

801059f7 <vector201>:
.globl vector201
vector201:
  pushl $0
801059f7:	6a 00                	push   $0x0
  pushl $201
801059f9:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801059fe:	e9 90 f3 ff ff       	jmp    80104d93 <alltraps>

80105a03 <vector202>:
.globl vector202
vector202:
  pushl $0
80105a03:	6a 00                	push   $0x0
  pushl $202
80105a05:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105a0a:	e9 84 f3 ff ff       	jmp    80104d93 <alltraps>

80105a0f <vector203>:
.globl vector203
vector203:
  pushl $0
80105a0f:	6a 00                	push   $0x0
  pushl $203
80105a11:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105a16:	e9 78 f3 ff ff       	jmp    80104d93 <alltraps>

80105a1b <vector204>:
.globl vector204
vector204:
  pushl $0
80105a1b:	6a 00                	push   $0x0
  pushl $204
80105a1d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105a22:	e9 6c f3 ff ff       	jmp    80104d93 <alltraps>

80105a27 <vector205>:
.globl vector205
vector205:
  pushl $0
80105a27:	6a 00                	push   $0x0
  pushl $205
80105a29:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105a2e:	e9 60 f3 ff ff       	jmp    80104d93 <alltraps>

80105a33 <vector206>:
.globl vector206
vector206:
  pushl $0
80105a33:	6a 00                	push   $0x0
  pushl $206
80105a35:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105a3a:	e9 54 f3 ff ff       	jmp    80104d93 <alltraps>

80105a3f <vector207>:
.globl vector207
vector207:
  pushl $0
80105a3f:	6a 00                	push   $0x0
  pushl $207
80105a41:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105a46:	e9 48 f3 ff ff       	jmp    80104d93 <alltraps>

80105a4b <vector208>:
.globl vector208
vector208:
  pushl $0
80105a4b:	6a 00                	push   $0x0
  pushl $208
80105a4d:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105a52:	e9 3c f3 ff ff       	jmp    80104d93 <alltraps>

80105a57 <vector209>:
.globl vector209
vector209:
  pushl $0
80105a57:	6a 00                	push   $0x0
  pushl $209
80105a59:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105a5e:	e9 30 f3 ff ff       	jmp    80104d93 <alltraps>

80105a63 <vector210>:
.globl vector210
vector210:
  pushl $0
80105a63:	6a 00                	push   $0x0
  pushl $210
80105a65:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105a6a:	e9 24 f3 ff ff       	jmp    80104d93 <alltraps>

80105a6f <vector211>:
.globl vector211
vector211:
  pushl $0
80105a6f:	6a 00                	push   $0x0
  pushl $211
80105a71:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105a76:	e9 18 f3 ff ff       	jmp    80104d93 <alltraps>

80105a7b <vector212>:
.globl vector212
vector212:
  pushl $0
80105a7b:	6a 00                	push   $0x0
  pushl $212
80105a7d:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105a82:	e9 0c f3 ff ff       	jmp    80104d93 <alltraps>

80105a87 <vector213>:
.globl vector213
vector213:
  pushl $0
80105a87:	6a 00                	push   $0x0
  pushl $213
80105a89:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105a8e:	e9 00 f3 ff ff       	jmp    80104d93 <alltraps>

80105a93 <vector214>:
.globl vector214
vector214:
  pushl $0
80105a93:	6a 00                	push   $0x0
  pushl $214
80105a95:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105a9a:	e9 f4 f2 ff ff       	jmp    80104d93 <alltraps>

80105a9f <vector215>:
.globl vector215
vector215:
  pushl $0
80105a9f:	6a 00                	push   $0x0
  pushl $215
80105aa1:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105aa6:	e9 e8 f2 ff ff       	jmp    80104d93 <alltraps>

80105aab <vector216>:
.globl vector216
vector216:
  pushl $0
80105aab:	6a 00                	push   $0x0
  pushl $216
80105aad:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105ab2:	e9 dc f2 ff ff       	jmp    80104d93 <alltraps>

80105ab7 <vector217>:
.globl vector217
vector217:
  pushl $0
80105ab7:	6a 00                	push   $0x0
  pushl $217
80105ab9:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105abe:	e9 d0 f2 ff ff       	jmp    80104d93 <alltraps>

80105ac3 <vector218>:
.globl vector218
vector218:
  pushl $0
80105ac3:	6a 00                	push   $0x0
  pushl $218
80105ac5:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105aca:	e9 c4 f2 ff ff       	jmp    80104d93 <alltraps>

80105acf <vector219>:
.globl vector219
vector219:
  pushl $0
80105acf:	6a 00                	push   $0x0
  pushl $219
80105ad1:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105ad6:	e9 b8 f2 ff ff       	jmp    80104d93 <alltraps>

80105adb <vector220>:
.globl vector220
vector220:
  pushl $0
80105adb:	6a 00                	push   $0x0
  pushl $220
80105add:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105ae2:	e9 ac f2 ff ff       	jmp    80104d93 <alltraps>

80105ae7 <vector221>:
.globl vector221
vector221:
  pushl $0
80105ae7:	6a 00                	push   $0x0
  pushl $221
80105ae9:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105aee:	e9 a0 f2 ff ff       	jmp    80104d93 <alltraps>

80105af3 <vector222>:
.globl vector222
vector222:
  pushl $0
80105af3:	6a 00                	push   $0x0
  pushl $222
80105af5:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105afa:	e9 94 f2 ff ff       	jmp    80104d93 <alltraps>

80105aff <vector223>:
.globl vector223
vector223:
  pushl $0
80105aff:	6a 00                	push   $0x0
  pushl $223
80105b01:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105b06:	e9 88 f2 ff ff       	jmp    80104d93 <alltraps>

80105b0b <vector224>:
.globl vector224
vector224:
  pushl $0
80105b0b:	6a 00                	push   $0x0
  pushl $224
80105b0d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105b12:	e9 7c f2 ff ff       	jmp    80104d93 <alltraps>

80105b17 <vector225>:
.globl vector225
vector225:
  pushl $0
80105b17:	6a 00                	push   $0x0
  pushl $225
80105b19:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105b1e:	e9 70 f2 ff ff       	jmp    80104d93 <alltraps>

80105b23 <vector226>:
.globl vector226
vector226:
  pushl $0
80105b23:	6a 00                	push   $0x0
  pushl $226
80105b25:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105b2a:	e9 64 f2 ff ff       	jmp    80104d93 <alltraps>

80105b2f <vector227>:
.globl vector227
vector227:
  pushl $0
80105b2f:	6a 00                	push   $0x0
  pushl $227
80105b31:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105b36:	e9 58 f2 ff ff       	jmp    80104d93 <alltraps>

80105b3b <vector228>:
.globl vector228
vector228:
  pushl $0
80105b3b:	6a 00                	push   $0x0
  pushl $228
80105b3d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105b42:	e9 4c f2 ff ff       	jmp    80104d93 <alltraps>

80105b47 <vector229>:
.globl vector229
vector229:
  pushl $0
80105b47:	6a 00                	push   $0x0
  pushl $229
80105b49:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105b4e:	e9 40 f2 ff ff       	jmp    80104d93 <alltraps>

80105b53 <vector230>:
.globl vector230
vector230:
  pushl $0
80105b53:	6a 00                	push   $0x0
  pushl $230
80105b55:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105b5a:	e9 34 f2 ff ff       	jmp    80104d93 <alltraps>

80105b5f <vector231>:
.globl vector231
vector231:
  pushl $0
80105b5f:	6a 00                	push   $0x0
  pushl $231
80105b61:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105b66:	e9 28 f2 ff ff       	jmp    80104d93 <alltraps>

80105b6b <vector232>:
.globl vector232
vector232:
  pushl $0
80105b6b:	6a 00                	push   $0x0
  pushl $232
80105b6d:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105b72:	e9 1c f2 ff ff       	jmp    80104d93 <alltraps>

80105b77 <vector233>:
.globl vector233
vector233:
  pushl $0
80105b77:	6a 00                	push   $0x0
  pushl $233
80105b79:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105b7e:	e9 10 f2 ff ff       	jmp    80104d93 <alltraps>

80105b83 <vector234>:
.globl vector234
vector234:
  pushl $0
80105b83:	6a 00                	push   $0x0
  pushl $234
80105b85:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105b8a:	e9 04 f2 ff ff       	jmp    80104d93 <alltraps>

80105b8f <vector235>:
.globl vector235
vector235:
  pushl $0
80105b8f:	6a 00                	push   $0x0
  pushl $235
80105b91:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105b96:	e9 f8 f1 ff ff       	jmp    80104d93 <alltraps>

80105b9b <vector236>:
.globl vector236
vector236:
  pushl $0
80105b9b:	6a 00                	push   $0x0
  pushl $236
80105b9d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105ba2:	e9 ec f1 ff ff       	jmp    80104d93 <alltraps>

80105ba7 <vector237>:
.globl vector237
vector237:
  pushl $0
80105ba7:	6a 00                	push   $0x0
  pushl $237
80105ba9:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105bae:	e9 e0 f1 ff ff       	jmp    80104d93 <alltraps>

80105bb3 <vector238>:
.globl vector238
vector238:
  pushl $0
80105bb3:	6a 00                	push   $0x0
  pushl $238
80105bb5:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105bba:	e9 d4 f1 ff ff       	jmp    80104d93 <alltraps>

80105bbf <vector239>:
.globl vector239
vector239:
  pushl $0
80105bbf:	6a 00                	push   $0x0
  pushl $239
80105bc1:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105bc6:	e9 c8 f1 ff ff       	jmp    80104d93 <alltraps>

80105bcb <vector240>:
.globl vector240
vector240:
  pushl $0
80105bcb:	6a 00                	push   $0x0
  pushl $240
80105bcd:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105bd2:	e9 bc f1 ff ff       	jmp    80104d93 <alltraps>

80105bd7 <vector241>:
.globl vector241
vector241:
  pushl $0
80105bd7:	6a 00                	push   $0x0
  pushl $241
80105bd9:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105bde:	e9 b0 f1 ff ff       	jmp    80104d93 <alltraps>

80105be3 <vector242>:
.globl vector242
vector242:
  pushl $0
80105be3:	6a 00                	push   $0x0
  pushl $242
80105be5:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105bea:	e9 a4 f1 ff ff       	jmp    80104d93 <alltraps>

80105bef <vector243>:
.globl vector243
vector243:
  pushl $0
80105bef:	6a 00                	push   $0x0
  pushl $243
80105bf1:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105bf6:	e9 98 f1 ff ff       	jmp    80104d93 <alltraps>

80105bfb <vector244>:
.globl vector244
vector244:
  pushl $0
80105bfb:	6a 00                	push   $0x0
  pushl $244
80105bfd:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105c02:	e9 8c f1 ff ff       	jmp    80104d93 <alltraps>

80105c07 <vector245>:
.globl vector245
vector245:
  pushl $0
80105c07:	6a 00                	push   $0x0
  pushl $245
80105c09:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105c0e:	e9 80 f1 ff ff       	jmp    80104d93 <alltraps>

80105c13 <vector246>:
.globl vector246
vector246:
  pushl $0
80105c13:	6a 00                	push   $0x0
  pushl $246
80105c15:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105c1a:	e9 74 f1 ff ff       	jmp    80104d93 <alltraps>

80105c1f <vector247>:
.globl vector247
vector247:
  pushl $0
80105c1f:	6a 00                	push   $0x0
  pushl $247
80105c21:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105c26:	e9 68 f1 ff ff       	jmp    80104d93 <alltraps>

80105c2b <vector248>:
.globl vector248
vector248:
  pushl $0
80105c2b:	6a 00                	push   $0x0
  pushl $248
80105c2d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105c32:	e9 5c f1 ff ff       	jmp    80104d93 <alltraps>

80105c37 <vector249>:
.globl vector249
vector249:
  pushl $0
80105c37:	6a 00                	push   $0x0
  pushl $249
80105c39:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105c3e:	e9 50 f1 ff ff       	jmp    80104d93 <alltraps>

80105c43 <vector250>:
.globl vector250
vector250:
  pushl $0
80105c43:	6a 00                	push   $0x0
  pushl $250
80105c45:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105c4a:	e9 44 f1 ff ff       	jmp    80104d93 <alltraps>

80105c4f <vector251>:
.globl vector251
vector251:
  pushl $0
80105c4f:	6a 00                	push   $0x0
  pushl $251
80105c51:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105c56:	e9 38 f1 ff ff       	jmp    80104d93 <alltraps>

80105c5b <vector252>:
.globl vector252
vector252:
  pushl $0
80105c5b:	6a 00                	push   $0x0
  pushl $252
80105c5d:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105c62:	e9 2c f1 ff ff       	jmp    80104d93 <alltraps>

80105c67 <vector253>:
.globl vector253
vector253:
  pushl $0
80105c67:	6a 00                	push   $0x0
  pushl $253
80105c69:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105c6e:	e9 20 f1 ff ff       	jmp    80104d93 <alltraps>

80105c73 <vector254>:
.globl vector254
vector254:
  pushl $0
80105c73:	6a 00                	push   $0x0
  pushl $254
80105c75:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105c7a:	e9 14 f1 ff ff       	jmp    80104d93 <alltraps>

80105c7f <vector255>:
.globl vector255
vector255:
  pushl $0
80105c7f:	6a 00                	push   $0x0
  pushl $255
80105c81:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105c86:	e9 08 f1 ff ff       	jmp    80104d93 <alltraps>

80105c8b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105c8b:	55                   	push   %ebp
80105c8c:	89 e5                	mov    %esp,%ebp
80105c8e:	57                   	push   %edi
80105c8f:	56                   	push   %esi
80105c90:	53                   	push   %ebx
80105c91:	83 ec 0c             	sub    $0xc,%esp
80105c94:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105c96:	c1 ea 16             	shr    $0x16,%edx
80105c99:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105c9c:	8b 37                	mov    (%edi),%esi
80105c9e:	f7 c6 01 00 00 00    	test   $0x1,%esi
80105ca4:	74 35                	je     80105cdb <walkpgdir+0x50>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80105ca6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    if (a > KERNBASE)
80105cac:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80105cb2:	77 1a                	ja     80105cce <walkpgdir+0x43>
    return (char*)a + KERNBASE;
80105cb4:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105cba:	c1 eb 0c             	shr    $0xc,%ebx
80105cbd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
80105cc3:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
80105cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105cc9:	5b                   	pop    %ebx
80105cca:	5e                   	pop    %esi
80105ccb:	5f                   	pop    %edi
80105ccc:	5d                   	pop    %ebp
80105ccd:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80105cce:	83 ec 0c             	sub    $0xc,%esp
80105cd1:	68 38 6d 10 80       	push   $0x80106d38
80105cd6:	e8 6d a6 ff ff       	call   80100348 <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105cdb:	85 c9                	test   %ecx,%ecx
80105cdd:	74 33                	je     80105d12 <walkpgdir+0x87>
80105cdf:	e8 e5 c3 ff ff       	call   801020c9 <kalloc>
80105ce4:	89 c6                	mov    %eax,%esi
80105ce6:	85 c0                	test   %eax,%eax
80105ce8:	74 28                	je     80105d12 <walkpgdir+0x87>
    memset(pgtab, 0, PGSIZE);
80105cea:	83 ec 04             	sub    $0x4,%esp
80105ced:	68 00 10 00 00       	push   $0x1000
80105cf2:	6a 00                	push   $0x0
80105cf4:	50                   	push   %eax
80105cf5:	e8 c1 df ff ff       	call   80103cbb <memset>
    if (a < (void*) KERNBASE)
80105cfa:	83 c4 10             	add    $0x10,%esp
80105cfd:	81 fe ff ff ff 7f    	cmp    $0x7fffffff,%esi
80105d03:	76 14                	jbe    80105d19 <walkpgdir+0x8e>
    return (uint)a - KERNBASE;
80105d05:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105d0b:	83 c8 07             	or     $0x7,%eax
80105d0e:	89 07                	mov    %eax,(%edi)
80105d10:	eb a8                	jmp    80105cba <walkpgdir+0x2f>
      return 0;
80105d12:	b8 00 00 00 00       	mov    $0x0,%eax
80105d17:	eb ad                	jmp    80105cc6 <walkpgdir+0x3b>
        panic("V2P on address < KERNBASE "
80105d19:	83 ec 0c             	sub    $0xc,%esp
80105d1c:	68 08 6a 10 80       	push   $0x80106a08
80105d21:	e8 22 a6 ff ff       	call   80100348 <panic>

80105d26 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105d26:	55                   	push   %ebp
80105d27:	89 e5                	mov    %esp,%ebp
80105d29:	57                   	push   %edi
80105d2a:	56                   	push   %esi
80105d2b:	53                   	push   %ebx
80105d2c:	83 ec 1c             	sub    $0x1c,%esp
80105d2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105d32:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105d35:	89 d3                	mov    %edx,%ebx
80105d37:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105d3d:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105d41:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d47:	b9 01 00 00 00       	mov    $0x1,%ecx
80105d4c:	89 da                	mov    %ebx,%edx
80105d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d51:	e8 35 ff ff ff       	call   80105c8b <walkpgdir>
80105d56:	85 c0                	test   %eax,%eax
80105d58:	74 2e                	je     80105d88 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105d5a:	f6 00 01             	testb  $0x1,(%eax)
80105d5d:	75 1c                	jne    80105d7b <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105d5f:	89 f2                	mov    %esi,%edx
80105d61:	0b 55 0c             	or     0xc(%ebp),%edx
80105d64:	83 ca 01             	or     $0x1,%edx
80105d67:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105d69:	39 fb                	cmp    %edi,%ebx
80105d6b:	74 28                	je     80105d95 <mappages+0x6f>
      break;
    a += PGSIZE;
80105d6d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105d73:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d79:	eb cc                	jmp    80105d47 <mappages+0x21>
      panic("remap");
80105d7b:	83 ec 0c             	sub    $0xc,%esp
80105d7e:	68 20 71 10 80       	push   $0x80107120
80105d83:	e8 c0 a5 ff ff       	call   80100348 <panic>
      return -1;
80105d88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d90:	5b                   	pop    %ebx
80105d91:	5e                   	pop    %esi
80105d92:	5f                   	pop    %edi
80105d93:	5d                   	pop    %ebp
80105d94:	c3                   	ret    
  return 0;
80105d95:	b8 00 00 00 00       	mov    $0x0,%eax
80105d9a:	eb f1                	jmp    80105d8d <mappages+0x67>

80105d9c <seginit>:
{
80105d9c:	55                   	push   %ebp
80105d9d:	89 e5                	mov    %esp,%ebp
80105d9f:	57                   	push   %edi
80105da0:	56                   	push   %esi
80105da1:	53                   	push   %ebx
80105da2:	83 ec 1c             	sub    $0x1c,%esp
  c = &cpus[cpuid()];
80105da5:	e8 55 d4 ff ff       	call   801031ff <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105daa:	69 f8 b0 00 00 00    	imul   $0xb0,%eax,%edi
80105db0:	66 c7 87 18 18 11 80 	movw   $0xffff,-0x7feee7e8(%edi)
80105db7:	ff ff 
80105db9:	66 c7 87 1a 18 11 80 	movw   $0x0,-0x7feee7e6(%edi)
80105dc0:	00 00 
80105dc2:	c6 87 1c 18 11 80 00 	movb   $0x0,-0x7feee7e4(%edi)
80105dc9:	0f b6 8f 1d 18 11 80 	movzbl -0x7feee7e3(%edi),%ecx
80105dd0:	83 e1 f0             	and    $0xfffffff0,%ecx
80105dd3:	89 ce                	mov    %ecx,%esi
80105dd5:	83 ce 0a             	or     $0xa,%esi
80105dd8:	89 f2                	mov    %esi,%edx
80105dda:	88 97 1d 18 11 80    	mov    %dl,-0x7feee7e3(%edi)
80105de0:	83 c9 1a             	or     $0x1a,%ecx
80105de3:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105de9:	83 e1 9f             	and    $0xffffff9f,%ecx
80105dec:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105df2:	83 c9 80             	or     $0xffffff80,%ecx
80105df5:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105dfb:	0f b6 8f 1e 18 11 80 	movzbl -0x7feee7e2(%edi),%ecx
80105e02:	83 c9 0f             	or     $0xf,%ecx
80105e05:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105e0b:	89 ce                	mov    %ecx,%esi
80105e0d:	83 e6 ef             	and    $0xffffffef,%esi
80105e10:	89 f2                	mov    %esi,%edx
80105e12:	88 97 1e 18 11 80    	mov    %dl,-0x7feee7e2(%edi)
80105e18:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e1b:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105e21:	89 ce                	mov    %ecx,%esi
80105e23:	83 ce 40             	or     $0x40,%esi
80105e26:	89 f2                	mov    %esi,%edx
80105e28:	88 97 1e 18 11 80    	mov    %dl,-0x7feee7e2(%edi)
80105e2e:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e31:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105e37:	c6 87 1f 18 11 80 00 	movb   $0x0,-0x7feee7e1(%edi)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105e3e:	66 c7 87 20 18 11 80 	movw   $0xffff,-0x7feee7e0(%edi)
80105e45:	ff ff 
80105e47:	66 c7 87 22 18 11 80 	movw   $0x0,-0x7feee7de(%edi)
80105e4e:	00 00 
80105e50:	c6 87 24 18 11 80 00 	movb   $0x0,-0x7feee7dc(%edi)
80105e57:	0f b6 8f 25 18 11 80 	movzbl -0x7feee7db(%edi),%ecx
80105e5e:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e61:	89 ce                	mov    %ecx,%esi
80105e63:	83 ce 02             	or     $0x2,%esi
80105e66:	89 f2                	mov    %esi,%edx
80105e68:	88 97 25 18 11 80    	mov    %dl,-0x7feee7db(%edi)
80105e6e:	83 c9 12             	or     $0x12,%ecx
80105e71:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105e77:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e7a:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105e80:	83 c9 80             	or     $0xffffff80,%ecx
80105e83:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105e89:	0f b6 8f 26 18 11 80 	movzbl -0x7feee7da(%edi),%ecx
80105e90:	83 c9 0f             	or     $0xf,%ecx
80105e93:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80105e99:	89 ce                	mov    %ecx,%esi
80105e9b:	83 e6 ef             	and    $0xffffffef,%esi
80105e9e:	89 f2                	mov    %esi,%edx
80105ea0:	88 97 26 18 11 80    	mov    %dl,-0x7feee7da(%edi)
80105ea6:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ea9:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80105eaf:	89 ce                	mov    %ecx,%esi
80105eb1:	83 ce 40             	or     $0x40,%esi
80105eb4:	89 f2                	mov    %esi,%edx
80105eb6:	88 97 26 18 11 80    	mov    %dl,-0x7feee7da(%edi)
80105ebc:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ebf:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80105ec5:	c6 87 27 18 11 80 00 	movb   $0x0,-0x7feee7d9(%edi)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105ecc:	66 c7 87 28 18 11 80 	movw   $0xffff,-0x7feee7d8(%edi)
80105ed3:	ff ff 
80105ed5:	66 c7 87 2a 18 11 80 	movw   $0x0,-0x7feee7d6(%edi)
80105edc:	00 00 
80105ede:	c6 87 2c 18 11 80 00 	movb   $0x0,-0x7feee7d4(%edi)
80105ee5:	0f b6 9f 2d 18 11 80 	movzbl -0x7feee7d3(%edi),%ebx
80105eec:	83 e3 f0             	and    $0xfffffff0,%ebx
80105eef:	89 de                	mov    %ebx,%esi
80105ef1:	83 ce 0a             	or     $0xa,%esi
80105ef4:	89 f2                	mov    %esi,%edx
80105ef6:	88 97 2d 18 11 80    	mov    %dl,-0x7feee7d3(%edi)
80105efc:	89 de                	mov    %ebx,%esi
80105efe:	83 ce 1a             	or     $0x1a,%esi
80105f01:	89 f2                	mov    %esi,%edx
80105f03:	88 97 2d 18 11 80    	mov    %dl,-0x7feee7d3(%edi)
80105f09:	83 cb 7a             	or     $0x7a,%ebx
80105f0c:	88 9f 2d 18 11 80    	mov    %bl,-0x7feee7d3(%edi)
80105f12:	c6 87 2d 18 11 80 fa 	movb   $0xfa,-0x7feee7d3(%edi)
80105f19:	0f b6 9f 2e 18 11 80 	movzbl -0x7feee7d2(%edi),%ebx
80105f20:	83 cb 0f             	or     $0xf,%ebx
80105f23:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
80105f29:	89 de                	mov    %ebx,%esi
80105f2b:	83 e6 ef             	and    $0xffffffef,%esi
80105f2e:	89 f2                	mov    %esi,%edx
80105f30:	88 97 2e 18 11 80    	mov    %dl,-0x7feee7d2(%edi)
80105f36:	83 e3 cf             	and    $0xffffffcf,%ebx
80105f39:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
80105f3f:	89 de                	mov    %ebx,%esi
80105f41:	83 ce 40             	or     $0x40,%esi
80105f44:	89 f2                	mov    %esi,%edx
80105f46:	88 97 2e 18 11 80    	mov    %dl,-0x7feee7d2(%edi)
80105f4c:	83 cb c0             	or     $0xffffffc0,%ebx
80105f4f:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
80105f55:	c6 87 2f 18 11 80 00 	movb   $0x0,-0x7feee7d1(%edi)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f5c:	66 c7 87 30 18 11 80 	movw   $0xffff,-0x7feee7d0(%edi)
80105f63:	ff ff 
80105f65:	66 c7 87 32 18 11 80 	movw   $0x0,-0x7feee7ce(%edi)
80105f6c:	00 00 
80105f6e:	c6 87 34 18 11 80 00 	movb   $0x0,-0x7feee7cc(%edi)
80105f75:	0f b6 9f 35 18 11 80 	movzbl -0x7feee7cb(%edi),%ebx
80105f7c:	83 e3 f0             	and    $0xfffffff0,%ebx
80105f7f:	89 de                	mov    %ebx,%esi
80105f81:	83 ce 02             	or     $0x2,%esi
80105f84:	89 f2                	mov    %esi,%edx
80105f86:	88 97 35 18 11 80    	mov    %dl,-0x7feee7cb(%edi)
80105f8c:	89 de                	mov    %ebx,%esi
80105f8e:	83 ce 12             	or     $0x12,%esi
80105f91:	89 f2                	mov    %esi,%edx
80105f93:	88 97 35 18 11 80    	mov    %dl,-0x7feee7cb(%edi)
80105f99:	83 cb 72             	or     $0x72,%ebx
80105f9c:	88 9f 35 18 11 80    	mov    %bl,-0x7feee7cb(%edi)
80105fa2:	c6 87 35 18 11 80 f2 	movb   $0xf2,-0x7feee7cb(%edi)
80105fa9:	0f b6 9f 36 18 11 80 	movzbl -0x7feee7ca(%edi),%ebx
80105fb0:	83 cb 0f             	or     $0xf,%ebx
80105fb3:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80105fb9:	89 de                	mov    %ebx,%esi
80105fbb:	83 e6 ef             	and    $0xffffffef,%esi
80105fbe:	89 f2                	mov    %esi,%edx
80105fc0:	88 97 36 18 11 80    	mov    %dl,-0x7feee7ca(%edi)
80105fc6:	83 e3 cf             	and    $0xffffffcf,%ebx
80105fc9:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80105fcf:	89 de                	mov    %ebx,%esi
80105fd1:	83 ce 40             	or     $0x40,%esi
80105fd4:	89 f2                	mov    %esi,%edx
80105fd6:	88 97 36 18 11 80    	mov    %dl,-0x7feee7ca(%edi)
80105fdc:	83 cb c0             	or     $0xffffffc0,%ebx
80105fdf:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80105fe5:	c6 87 37 18 11 80 00 	movb   $0x0,-0x7feee7c9(%edi)
  lgdt(c->gdt, sizeof(c->gdt));
80105fec:	8d 97 10 18 11 80    	lea    -0x7feee7f0(%edi),%edx
  pd[0] = size-1;
80105ff2:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
80105ff8:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
80105ffc:	c1 ea 10             	shr    $0x10,%edx
80105fff:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106003:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106006:	0f 01 10             	lgdtl  (%eax)
}
80106009:	83 c4 1c             	add    $0x1c,%esp
8010600c:	5b                   	pop    %ebx
8010600d:	5e                   	pop    %esi
8010600e:	5f                   	pop    %edi
8010600f:	5d                   	pop    %ebp
80106010:	c3                   	ret    

80106011 <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106011:	a1 c4 45 11 80       	mov    0x801145c4,%eax
    if (a < (void*) KERNBASE)
80106016:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
8010601b:	76 09                	jbe    80106026 <switchkvm+0x15>
    return (uint)a - KERNBASE;
8010601d:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106022:	0f 22 d8             	mov    %eax,%cr3
80106025:	c3                   	ret    
{
80106026:	55                   	push   %ebp
80106027:	89 e5                	mov    %esp,%ebp
80106029:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
8010602c:	68 08 6a 10 80       	push   $0x80106a08
80106031:	e8 12 a3 ff ff       	call   80100348 <panic>

80106036 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80106036:	55                   	push   %ebp
80106037:	89 e5                	mov    %esp,%ebp
80106039:	57                   	push   %edi
8010603a:	56                   	push   %esi
8010603b:	53                   	push   %ebx
8010603c:	83 ec 1c             	sub    $0x1c,%esp
8010603f:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106042:	85 f6                	test   %esi,%esi
80106044:	0f 84 2c 01 00 00    	je     80106176 <switchuvm+0x140>
    panic("switchuvm: no process");
  if(p->kstack == 0)
8010604a:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
8010604e:	0f 84 2f 01 00 00    	je     80106183 <switchuvm+0x14d>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80106054:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80106058:	0f 84 32 01 00 00    	je     80106190 <switchuvm+0x15a>
    panic("switchuvm: no pgdir");

  pushcli();
8010605e:	e8 d1 da ff ff       	call   80103b34 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106063:	e8 3b d1 ff ff       	call   801031a3 <mycpu>
80106068:	89 c3                	mov    %eax,%ebx
8010606a:	e8 34 d1 ff ff       	call   801031a3 <mycpu>
8010606f:	8d 78 08             	lea    0x8(%eax),%edi
80106072:	e8 2c d1 ff ff       	call   801031a3 <mycpu>
80106077:	83 c0 08             	add    $0x8,%eax
8010607a:	c1 e8 10             	shr    $0x10,%eax
8010607d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106080:	e8 1e d1 ff ff       	call   801031a3 <mycpu>
80106085:	83 c0 08             	add    $0x8,%eax
80106088:	c1 e8 18             	shr    $0x18,%eax
8010608b:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106092:	67 00 
80106094:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010609b:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
8010609f:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801060a5:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
801060ac:	83 e2 f0             	and    $0xfffffff0,%edx
801060af:	89 d1                	mov    %edx,%ecx
801060b1:	83 c9 09             	or     $0x9,%ecx
801060b4:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
801060ba:	83 ca 19             	or     $0x19,%edx
801060bd:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801060c3:	83 e2 9f             	and    $0xffffff9f,%edx
801060c6:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801060cc:	83 ca 80             	or     $0xffffff80,%edx
801060cf:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801060d5:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
801060dc:	89 d1                	mov    %edx,%ecx
801060de:	83 e1 f0             	and    $0xfffffff0,%ecx
801060e1:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
801060e7:	89 d1                	mov    %edx,%ecx
801060e9:	83 e1 e0             	and    $0xffffffe0,%ecx
801060ec:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
801060f2:	83 e2 c0             	and    $0xffffffc0,%edx
801060f5:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801060fb:	83 ca 40             	or     $0x40,%edx
801060fe:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106104:	83 e2 7f             	and    $0x7f,%edx
80106107:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010610d:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106113:	e8 8b d0 ff ff       	call   801031a3 <mycpu>
80106118:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010611f:	83 e2 ef             	and    $0xffffffef,%edx
80106122:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106128:	e8 76 d0 ff ff       	call   801031a3 <mycpu>
8010612d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106133:	8b 5e 08             	mov    0x8(%esi),%ebx
80106136:	e8 68 d0 ff ff       	call   801031a3 <mycpu>
8010613b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106141:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106144:	e8 5a d0 ff ff       	call   801031a3 <mycpu>
80106149:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
8010614f:	b8 28 00 00 00       	mov    $0x28,%eax
80106154:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106157:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
8010615a:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
8010615f:	76 3c                	jbe    8010619d <switchuvm+0x167>
    return (uint)a - KERNBASE;
80106161:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106166:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106169:	e8 02 da ff ff       	call   80103b70 <popcli>
}
8010616e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106171:	5b                   	pop    %ebx
80106172:	5e                   	pop    %esi
80106173:	5f                   	pop    %edi
80106174:	5d                   	pop    %ebp
80106175:	c3                   	ret    
    panic("switchuvm: no process");
80106176:	83 ec 0c             	sub    $0xc,%esp
80106179:	68 26 71 10 80       	push   $0x80107126
8010617e:	e8 c5 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80106183:	83 ec 0c             	sub    $0xc,%esp
80106186:	68 3c 71 10 80       	push   $0x8010713c
8010618b:	e8 b8 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80106190:	83 ec 0c             	sub    $0xc,%esp
80106193:	68 51 71 10 80       	push   $0x80107151
80106198:	e8 ab a1 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
8010619d:	83 ec 0c             	sub    $0xc,%esp
801061a0:	68 08 6a 10 80       	push   $0x80106a08
801061a5:	e8 9e a1 ff ff       	call   80100348 <panic>

801061aa <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801061aa:	55                   	push   %ebp
801061ab:	89 e5                	mov    %esp,%ebp
801061ad:	56                   	push   %esi
801061ae:	53                   	push   %ebx
801061af:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801061b2:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061b8:	77 57                	ja     80106211 <inituvm+0x67>
    panic("inituvm: more than a page");
  mem = kalloc();
801061ba:	e8 0a bf ff ff       	call   801020c9 <kalloc>
801061bf:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801061c1:	83 ec 04             	sub    $0x4,%esp
801061c4:	68 00 10 00 00       	push   $0x1000
801061c9:	6a 00                	push   $0x0
801061cb:	50                   	push   %eax
801061cc:	e8 ea da ff ff       	call   80103cbb <memset>
    if (a < (void*) KERNBASE)
801061d1:	83 c4 10             	add    $0x10,%esp
801061d4:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
801061da:	76 42                	jbe    8010621e <inituvm+0x74>
    return (uint)a - KERNBASE;
801061dc:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801061e2:	83 ec 08             	sub    $0x8,%esp
801061e5:	6a 06                	push   $0x6
801061e7:	50                   	push   %eax
801061e8:	b9 00 10 00 00       	mov    $0x1000,%ecx
801061ed:	ba 00 00 00 00       	mov    $0x0,%edx
801061f2:	8b 45 08             	mov    0x8(%ebp),%eax
801061f5:	e8 2c fb ff ff       	call   80105d26 <mappages>
  memmove(mem, init, sz);
801061fa:	83 c4 0c             	add    $0xc,%esp
801061fd:	56                   	push   %esi
801061fe:	ff 75 0c             	push   0xc(%ebp)
80106201:	53                   	push   %ebx
80106202:	e8 2c db ff ff       	call   80103d33 <memmove>
}
80106207:	83 c4 10             	add    $0x10,%esp
8010620a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010620d:	5b                   	pop    %ebx
8010620e:	5e                   	pop    %esi
8010620f:	5d                   	pop    %ebp
80106210:	c3                   	ret    
    panic("inituvm: more than a page");
80106211:	83 ec 0c             	sub    $0xc,%esp
80106214:	68 65 71 10 80       	push   $0x80107165
80106219:	e8 2a a1 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
8010621e:	83 ec 0c             	sub    $0xc,%esp
80106221:	68 08 6a 10 80       	push   $0x80106a08
80106226:	e8 1d a1 ff ff       	call   80100348 <panic>

8010622b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010622b:	55                   	push   %ebp
8010622c:	89 e5                	mov    %esp,%ebp
8010622e:	57                   	push   %edi
8010622f:	56                   	push   %esi
80106230:	53                   	push   %ebx
80106231:	83 ec 0c             	sub    $0xc,%esp
80106234:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106237:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010623a:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
80106240:	74 43                	je     80106285 <loaduvm+0x5a>
    panic("loaduvm: addr must be page aligned");
80106242:	83 ec 0c             	sub    $0xc,%esp
80106245:	68 20 72 10 80       	push   $0x80107220
8010624a:	e8 f9 a0 ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010624f:	83 ec 0c             	sub    $0xc,%esp
80106252:	68 7f 71 10 80       	push   $0x8010717f
80106257:	e8 ec a0 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010625c:	89 da                	mov    %ebx,%edx
8010625e:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
80106261:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106266:	77 51                	ja     801062b9 <loaduvm+0x8e>
    return (char*)a + KERNBASE;
80106268:	05 00 00 00 80       	add    $0x80000000,%eax
8010626d:	56                   	push   %esi
8010626e:	52                   	push   %edx
8010626f:	50                   	push   %eax
80106270:	ff 75 10             	push   0x10(%ebp)
80106273:	e8 e9 b4 ff ff       	call   80101761 <readi>
80106278:	83 c4 10             	add    $0x10,%esp
8010627b:	39 f0                	cmp    %esi,%eax
8010627d:	75 54                	jne    801062d3 <loaduvm+0xa8>
  for(i = 0; i < sz; i += PGSIZE){
8010627f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106285:	39 fb                	cmp    %edi,%ebx
80106287:	73 3d                	jae    801062c6 <loaduvm+0x9b>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106289:	89 da                	mov    %ebx,%edx
8010628b:	03 55 0c             	add    0xc(%ebp),%edx
8010628e:	b9 00 00 00 00       	mov    $0x0,%ecx
80106293:	8b 45 08             	mov    0x8(%ebp),%eax
80106296:	e8 f0 f9 ff ff       	call   80105c8b <walkpgdir>
8010629b:	85 c0                	test   %eax,%eax
8010629d:	74 b0                	je     8010624f <loaduvm+0x24>
    pa = PTE_ADDR(*pte);
8010629f:	8b 00                	mov    (%eax),%eax
801062a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801062a6:	89 fe                	mov    %edi,%esi
801062a8:	29 de                	sub    %ebx,%esi
801062aa:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801062b0:	76 aa                	jbe    8010625c <loaduvm+0x31>
      n = PGSIZE;
801062b2:	be 00 10 00 00       	mov    $0x1000,%esi
801062b7:	eb a3                	jmp    8010625c <loaduvm+0x31>
        panic("P2V on address > KERNBASE");
801062b9:	83 ec 0c             	sub    $0xc,%esp
801062bc:	68 38 6d 10 80       	push   $0x80106d38
801062c1:	e8 82 a0 ff ff       	call   80100348 <panic>
      return -1;
  }
  return 0;
801062c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062ce:	5b                   	pop    %ebx
801062cf:	5e                   	pop    %esi
801062d0:	5f                   	pop    %edi
801062d1:	5d                   	pop    %ebp
801062d2:	c3                   	ret    
      return -1;
801062d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d8:	eb f1                	jmp    801062cb <loaduvm+0xa0>

801062da <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801062da:	55                   	push   %ebp
801062db:	89 e5                	mov    %esp,%ebp
801062dd:	57                   	push   %edi
801062de:	56                   	push   %esi
801062df:	53                   	push   %ebx
801062e0:	83 ec 0c             	sub    $0xc,%esp
801062e3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801062e6:	39 7d 10             	cmp    %edi,0x10(%ebp)
801062e9:	73 11                	jae    801062fc <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801062eb:	8b 45 10             	mov    0x10(%ebp),%eax
801062ee:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062f4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801062fa:	eb 19                	jmp    80106315 <deallocuvm+0x3b>
    return oldsz;
801062fc:	89 f8                	mov    %edi,%eax
801062fe:	eb 78                	jmp    80106378 <deallocuvm+0x9e>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106300:	c1 eb 16             	shr    $0x16,%ebx
80106303:	83 c3 01             	add    $0x1,%ebx
80106306:	c1 e3 16             	shl    $0x16,%ebx
80106309:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010630f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106315:	39 fb                	cmp    %edi,%ebx
80106317:	73 5c                	jae    80106375 <deallocuvm+0x9b>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106319:	b9 00 00 00 00       	mov    $0x0,%ecx
8010631e:	89 da                	mov    %ebx,%edx
80106320:	8b 45 08             	mov    0x8(%ebp),%eax
80106323:	e8 63 f9 ff ff       	call   80105c8b <walkpgdir>
80106328:	89 c6                	mov    %eax,%esi
    if(!pte)
8010632a:	85 c0                	test   %eax,%eax
8010632c:	74 d2                	je     80106300 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010632e:	8b 00                	mov    (%eax),%eax
80106330:	a8 01                	test   $0x1,%al
80106332:	74 db                	je     8010630f <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106334:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106339:	74 20                	je     8010635b <deallocuvm+0x81>
    if (a > KERNBASE)
8010633b:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106340:	77 26                	ja     80106368 <deallocuvm+0x8e>
    return (char*)a + KERNBASE;
80106342:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106347:	83 ec 0c             	sub    $0xc,%esp
8010634a:	50                   	push   %eax
8010634b:	e8 3c bc ff ff       	call   80101f8c <kfree>
      *pte = 0;
80106350:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106356:	83 c4 10             	add    $0x10,%esp
80106359:	eb b4                	jmp    8010630f <deallocuvm+0x35>
        panic("kfree");
8010635b:	83 ec 0c             	sub    $0xc,%esp
8010635e:	68 96 6a 10 80       	push   $0x80106a96
80106363:	e8 e0 9f ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
80106368:	83 ec 0c             	sub    $0xc,%esp
8010636b:	68 38 6d 10 80       	push   $0x80106d38
80106370:	e8 d3 9f ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106375:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106378:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010637b:	5b                   	pop    %ebx
8010637c:	5e                   	pop    %esi
8010637d:	5f                   	pop    %edi
8010637e:	5d                   	pop    %ebp
8010637f:	c3                   	ret    

80106380 <allocuvm>:
{
80106380:	55                   	push   %ebp
80106381:	89 e5                	mov    %esp,%ebp
80106383:	57                   	push   %edi
80106384:	56                   	push   %esi
80106385:	53                   	push   %ebx
80106386:	83 ec 1c             	sub    $0x1c,%esp
80106389:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
8010638c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010638f:	85 ff                	test   %edi,%edi
80106391:	0f 88 d9 00 00 00    	js     80106470 <allocuvm+0xf0>
  if(newsz < oldsz)
80106397:	3b 7d 0c             	cmp    0xc(%ebp),%edi
8010639a:	72 67                	jb     80106403 <allocuvm+0x83>
  a = PGROUNDUP(oldsz);
8010639c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010639f:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801063a5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801063ab:	39 fe                	cmp    %edi,%esi
801063ad:	0f 83 c4 00 00 00    	jae    80106477 <allocuvm+0xf7>
    mem = kalloc();
801063b3:	e8 11 bd ff ff       	call   801020c9 <kalloc>
801063b8:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
801063ba:	85 c0                	test   %eax,%eax
801063bc:	74 4d                	je     8010640b <allocuvm+0x8b>
    memset(mem, 0, PGSIZE);
801063be:	83 ec 04             	sub    $0x4,%esp
801063c1:	68 00 10 00 00       	push   $0x1000
801063c6:	6a 00                	push   $0x0
801063c8:	50                   	push   %eax
801063c9:	e8 ed d8 ff ff       	call   80103cbb <memset>
    if (a < (void*) KERNBASE)
801063ce:	83 c4 10             	add    $0x10,%esp
801063d1:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
801063d7:	76 5a                	jbe    80106433 <allocuvm+0xb3>
    return (uint)a - KERNBASE;
801063d9:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801063df:	83 ec 08             	sub    $0x8,%esp
801063e2:	6a 06                	push   $0x6
801063e4:	50                   	push   %eax
801063e5:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063ea:	89 f2                	mov    %esi,%edx
801063ec:	8b 45 08             	mov    0x8(%ebp),%eax
801063ef:	e8 32 f9 ff ff       	call   80105d26 <mappages>
801063f4:	83 c4 10             	add    $0x10,%esp
801063f7:	85 c0                	test   %eax,%eax
801063f9:	78 45                	js     80106440 <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
801063fb:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106401:	eb a8                	jmp    801063ab <allocuvm+0x2b>
    return oldsz;
80106403:	8b 45 0c             	mov    0xc(%ebp),%eax
80106406:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106409:	eb 6c                	jmp    80106477 <allocuvm+0xf7>
      cprintf("allocuvm out of memory\n");
8010640b:	83 ec 0c             	sub    $0xc,%esp
8010640e:	68 9d 71 10 80       	push   $0x8010719d
80106413:	e8 ef a1 ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106418:	83 c4 0c             	add    $0xc,%esp
8010641b:	ff 75 0c             	push   0xc(%ebp)
8010641e:	57                   	push   %edi
8010641f:	ff 75 08             	push   0x8(%ebp)
80106422:	e8 b3 fe ff ff       	call   801062da <deallocuvm>
      return 0;
80106427:	83 c4 10             	add    $0x10,%esp
8010642a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106431:	eb 44                	jmp    80106477 <allocuvm+0xf7>
        panic("V2P on address < KERNBASE "
80106433:	83 ec 0c             	sub    $0xc,%esp
80106436:	68 08 6a 10 80       	push   $0x80106a08
8010643b:	e8 08 9f ff ff       	call   80100348 <panic>
      cprintf("allocuvm out of memory (2)\n");
80106440:	83 ec 0c             	sub    $0xc,%esp
80106443:	68 b5 71 10 80       	push   $0x801071b5
80106448:	e8 ba a1 ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010644d:	83 c4 0c             	add    $0xc,%esp
80106450:	ff 75 0c             	push   0xc(%ebp)
80106453:	57                   	push   %edi
80106454:	ff 75 08             	push   0x8(%ebp)
80106457:	e8 7e fe ff ff       	call   801062da <deallocuvm>
      kfree(mem);
8010645c:	89 1c 24             	mov    %ebx,(%esp)
8010645f:	e8 28 bb ff ff       	call   80101f8c <kfree>
      return 0;
80106464:	83 c4 10             	add    $0x10,%esp
80106467:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010646e:	eb 07                	jmp    80106477 <allocuvm+0xf7>
    return 0;
80106470:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106477:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010647a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010647d:	5b                   	pop    %ebx
8010647e:	5e                   	pop    %esi
8010647f:	5f                   	pop    %edi
80106480:	5d                   	pop    %ebp
80106481:	c3                   	ret    

80106482 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106482:	55                   	push   %ebp
80106483:	89 e5                	mov    %esp,%ebp
80106485:	56                   	push   %esi
80106486:	53                   	push   %ebx
80106487:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010648a:	85 f6                	test   %esi,%esi
8010648c:	74 1a                	je     801064a8 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010648e:	83 ec 04             	sub    $0x4,%esp
80106491:	6a 00                	push   $0x0
80106493:	68 00 00 00 80       	push   $0x80000000
80106498:	56                   	push   %esi
80106499:	e8 3c fe ff ff       	call   801062da <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010649e:	83 c4 10             	add    $0x10,%esp
801064a1:	bb 00 00 00 00       	mov    $0x0,%ebx
801064a6:	eb 21                	jmp    801064c9 <freevm+0x47>
    panic("freevm: no pgdir");
801064a8:	83 ec 0c             	sub    $0xc,%esp
801064ab:	68 d1 71 10 80       	push   $0x801071d1
801064b0:	e8 93 9e ff ff       	call   80100348 <panic>
    return (char*)a + KERNBASE;
801064b5:	05 00 00 00 80       	add    $0x80000000,%eax
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
801064ba:	83 ec 0c             	sub    $0xc,%esp
801064bd:	50                   	push   %eax
801064be:	e8 c9 ba ff ff       	call   80101f8c <kfree>
801064c3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801064c6:	83 c3 01             	add    $0x1,%ebx
801064c9:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801064cf:	77 20                	ja     801064f1 <freevm+0x6f>
    if(pgdir[i] & PTE_P){
801064d1:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801064d4:	a8 01                	test   $0x1,%al
801064d6:	74 ee                	je     801064c6 <freevm+0x44>
801064d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
801064dd:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801064e2:	76 d1                	jbe    801064b5 <freevm+0x33>
        panic("P2V on address > KERNBASE");
801064e4:	83 ec 0c             	sub    $0xc,%esp
801064e7:	68 38 6d 10 80       	push   $0x80106d38
801064ec:	e8 57 9e ff ff       	call   80100348 <panic>
    }
  }
  kfree((char*)pgdir);
801064f1:	83 ec 0c             	sub    $0xc,%esp
801064f4:	56                   	push   %esi
801064f5:	e8 92 ba ff ff       	call   80101f8c <kfree>
}
801064fa:	83 c4 10             	add    $0x10,%esp
801064fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106500:	5b                   	pop    %ebx
80106501:	5e                   	pop    %esi
80106502:	5d                   	pop    %ebp
80106503:	c3                   	ret    

80106504 <setupkvm>:
{
80106504:	55                   	push   %ebp
80106505:	89 e5                	mov    %esp,%ebp
80106507:	56                   	push   %esi
80106508:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106509:	e8 bb bb ff ff       	call   801020c9 <kalloc>
8010650e:	89 c6                	mov    %eax,%esi
80106510:	85 c0                	test   %eax,%eax
80106512:	74 55                	je     80106569 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
80106514:	83 ec 04             	sub    $0x4,%esp
80106517:	68 00 10 00 00       	push   $0x1000
8010651c:	6a 00                	push   $0x0
8010651e:	50                   	push   %eax
8010651f:	e8 97 d7 ff ff       	call   80103cbb <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106524:	83 c4 10             	add    $0x10,%esp
80106527:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
8010652c:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106532:	73 35                	jae    80106569 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106534:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106537:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010653a:	29 c1                	sub    %eax,%ecx
8010653c:	83 ec 08             	sub    $0x8,%esp
8010653f:	ff 73 0c             	push   0xc(%ebx)
80106542:	50                   	push   %eax
80106543:	8b 13                	mov    (%ebx),%edx
80106545:	89 f0                	mov    %esi,%eax
80106547:	e8 da f7 ff ff       	call   80105d26 <mappages>
8010654c:	83 c4 10             	add    $0x10,%esp
8010654f:	85 c0                	test   %eax,%eax
80106551:	78 05                	js     80106558 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106553:	83 c3 10             	add    $0x10,%ebx
80106556:	eb d4                	jmp    8010652c <setupkvm+0x28>
      freevm(pgdir);
80106558:	83 ec 0c             	sub    $0xc,%esp
8010655b:	56                   	push   %esi
8010655c:	e8 21 ff ff ff       	call   80106482 <freevm>
      return 0;
80106561:	83 c4 10             	add    $0x10,%esp
80106564:	be 00 00 00 00       	mov    $0x0,%esi
}
80106569:	89 f0                	mov    %esi,%eax
8010656b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010656e:	5b                   	pop    %ebx
8010656f:	5e                   	pop    %esi
80106570:	5d                   	pop    %ebp
80106571:	c3                   	ret    

80106572 <kvmalloc>:
{
80106572:	55                   	push   %ebp
80106573:	89 e5                	mov    %esp,%ebp
80106575:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106578:	e8 87 ff ff ff       	call   80106504 <setupkvm>
8010657d:	a3 c4 45 11 80       	mov    %eax,0x801145c4
  switchkvm();
80106582:	e8 8a fa ff ff       	call   80106011 <switchkvm>
}
80106587:	c9                   	leave  
80106588:	c3                   	ret    

80106589 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106589:	55                   	push   %ebp
8010658a:	89 e5                	mov    %esp,%ebp
8010658c:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010658f:	b9 00 00 00 00       	mov    $0x0,%ecx
80106594:	8b 55 0c             	mov    0xc(%ebp),%edx
80106597:	8b 45 08             	mov    0x8(%ebp),%eax
8010659a:	e8 ec f6 ff ff       	call   80105c8b <walkpgdir>
  if(pte == 0)
8010659f:	85 c0                	test   %eax,%eax
801065a1:	74 05                	je     801065a8 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801065a3:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801065a6:	c9                   	leave  
801065a7:	c3                   	ret    
    panic("clearpteu");
801065a8:	83 ec 0c             	sub    $0xc,%esp
801065ab:	68 e2 71 10 80       	push   $0x801071e2
801065b0:	e8 93 9d ff ff       	call   80100348 <panic>

801065b5 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801065b5:	55                   	push   %ebp
801065b6:	89 e5                	mov    %esp,%ebp
801065b8:	57                   	push   %edi
801065b9:	56                   	push   %esi
801065ba:	53                   	push   %ebx
801065bb:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801065be:	e8 41 ff ff ff       	call   80106504 <setupkvm>
801065c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
801065c6:	85 c0                	test   %eax,%eax
801065c8:	0f 84 f2 00 00 00    	je     801066c0 <copyuvm+0x10b>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801065ce:	bf 00 00 00 00       	mov    $0x0,%edi
801065d3:	eb 3a                	jmp    8010660f <copyuvm+0x5a>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
801065d5:	83 ec 0c             	sub    $0xc,%esp
801065d8:	68 ec 71 10 80       	push   $0x801071ec
801065dd:	e8 66 9d ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
801065e2:	83 ec 0c             	sub    $0xc,%esp
801065e5:	68 06 72 10 80       	push   $0x80107206
801065ea:	e8 59 9d ff ff       	call   80100348 <panic>
801065ef:	83 ec 0c             	sub    $0xc,%esp
801065f2:	68 38 6d 10 80       	push   $0x80106d38
801065f7:	e8 4c 9d ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
801065fc:	83 ec 0c             	sub    $0xc,%esp
801065ff:	68 08 6a 10 80       	push   $0x80106a08
80106604:	e8 3f 9d ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80106609:	81 c7 00 10 00 00    	add    $0x1000,%edi
8010660f:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106612:	0f 83 a8 00 00 00    	jae    801066c0 <copyuvm+0x10b>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106618:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010661b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106620:	89 fa                	mov    %edi,%edx
80106622:	8b 45 08             	mov    0x8(%ebp),%eax
80106625:	e8 61 f6 ff ff       	call   80105c8b <walkpgdir>
8010662a:	85 c0                	test   %eax,%eax
8010662c:	74 a7                	je     801065d5 <copyuvm+0x20>
    if(!(*pte & PTE_P))
8010662e:	8b 00                	mov    (%eax),%eax
80106630:	a8 01                	test   $0x1,%al
80106632:	74 ae                	je     801065e2 <copyuvm+0x2d>
80106634:	89 c6                	mov    %eax,%esi
80106636:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
8010663c:	25 ff 0f 00 00       	and    $0xfff,%eax
80106641:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80106644:	e8 80 ba ff ff       	call   801020c9 <kalloc>
80106649:	89 c3                	mov    %eax,%ebx
8010664b:	85 c0                	test   %eax,%eax
8010664d:	74 5c                	je     801066ab <copyuvm+0xf6>
    if (a > KERNBASE)
8010664f:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80106655:	77 98                	ja     801065ef <copyuvm+0x3a>
    return (char*)a + KERNBASE;
80106657:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010665d:	83 ec 04             	sub    $0x4,%esp
80106660:	68 00 10 00 00       	push   $0x1000
80106665:	56                   	push   %esi
80106666:	50                   	push   %eax
80106667:	e8 c7 d6 ff ff       	call   80103d33 <memmove>
    if (a < (void*) KERNBASE)
8010666c:	83 c4 10             	add    $0x10,%esp
8010666f:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106675:	76 85                	jbe    801065fc <copyuvm+0x47>
    return (uint)a - KERNBASE;
80106677:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010667d:	83 ec 08             	sub    $0x8,%esp
80106680:	ff 75 e0             	push   -0x20(%ebp)
80106683:	50                   	push   %eax
80106684:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106689:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010668c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010668f:	e8 92 f6 ff ff       	call   80105d26 <mappages>
80106694:	83 c4 10             	add    $0x10,%esp
80106697:	85 c0                	test   %eax,%eax
80106699:	0f 89 6a ff ff ff    	jns    80106609 <copyuvm+0x54>
      kfree(mem);
8010669f:	83 ec 0c             	sub    $0xc,%esp
801066a2:	53                   	push   %ebx
801066a3:	e8 e4 b8 ff ff       	call   80101f8c <kfree>
      goto bad;
801066a8:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
801066ab:	83 ec 0c             	sub    $0xc,%esp
801066ae:	ff 75 dc             	push   -0x24(%ebp)
801066b1:	e8 cc fd ff ff       	call   80106482 <freevm>
  return 0;
801066b6:	83 c4 10             	add    $0x10,%esp
801066b9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
801066c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801066c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066c6:	5b                   	pop    %ebx
801066c7:	5e                   	pop    %esi
801066c8:	5f                   	pop    %edi
801066c9:	5d                   	pop    %ebp
801066ca:	c3                   	ret    

801066cb <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801066cb:	55                   	push   %ebp
801066cc:	89 e5                	mov    %esp,%ebp
801066ce:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801066d1:	b9 00 00 00 00       	mov    $0x0,%ecx
801066d6:	8b 55 0c             	mov    0xc(%ebp),%edx
801066d9:	8b 45 08             	mov    0x8(%ebp),%eax
801066dc:	e8 aa f5 ff ff       	call   80105c8b <walkpgdir>
  if((*pte & PTE_P) == 0)
801066e1:	8b 00                	mov    (%eax),%eax
801066e3:	a8 01                	test   $0x1,%al
801066e5:	74 24                	je     8010670b <uva2ka+0x40>
    return 0;
  if((*pte & PTE_U) == 0)
801066e7:	a8 04                	test   $0x4,%al
801066e9:	74 27                	je     80106712 <uva2ka+0x47>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
801066eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
801066f0:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801066f5:	77 07                	ja     801066fe <uva2ka+0x33>
    return (char*)a + KERNBASE;
801066f7:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
801066fc:	c9                   	leave  
801066fd:	c3                   	ret    
        panic("P2V on address > KERNBASE");
801066fe:	83 ec 0c             	sub    $0xc,%esp
80106701:	68 38 6d 10 80       	push   $0x80106d38
80106706:	e8 3d 9c ff ff       	call   80100348 <panic>
    return 0;
8010670b:	b8 00 00 00 00       	mov    $0x0,%eax
80106710:	eb ea                	jmp    801066fc <uva2ka+0x31>
    return 0;
80106712:	b8 00 00 00 00       	mov    $0x0,%eax
80106717:	eb e3                	jmp    801066fc <uva2ka+0x31>

80106719 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106719:	55                   	push   %ebp
8010671a:	89 e5                	mov    %esp,%ebp
8010671c:	57                   	push   %edi
8010671d:	56                   	push   %esi
8010671e:	53                   	push   %ebx
8010671f:	83 ec 0c             	sub    $0xc,%esp
80106722:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106725:	eb 25                	jmp    8010674c <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106727:	8b 55 0c             	mov    0xc(%ebp),%edx
8010672a:	29 f2                	sub    %esi,%edx
8010672c:	01 d0                	add    %edx,%eax
8010672e:	83 ec 04             	sub    $0x4,%esp
80106731:	53                   	push   %ebx
80106732:	ff 75 10             	push   0x10(%ebp)
80106735:	50                   	push   %eax
80106736:	e8 f8 d5 ff ff       	call   80103d33 <memmove>
    len -= n;
8010673b:	29 df                	sub    %ebx,%edi
    buf += n;
8010673d:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106740:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106746:	89 45 0c             	mov    %eax,0xc(%ebp)
80106749:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
8010674c:	85 ff                	test   %edi,%edi
8010674e:	74 2f                	je     8010677f <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106750:	8b 75 0c             	mov    0xc(%ebp),%esi
80106753:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106759:	83 ec 08             	sub    $0x8,%esp
8010675c:	56                   	push   %esi
8010675d:	ff 75 08             	push   0x8(%ebp)
80106760:	e8 66 ff ff ff       	call   801066cb <uva2ka>
    if(pa0 == 0)
80106765:	83 c4 10             	add    $0x10,%esp
80106768:	85 c0                	test   %eax,%eax
8010676a:	74 20                	je     8010678c <copyout+0x73>
    n = PGSIZE - (va - va0);
8010676c:	89 f3                	mov    %esi,%ebx
8010676e:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106771:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106777:	39 df                	cmp    %ebx,%edi
80106779:	73 ac                	jae    80106727 <copyout+0xe>
      n = len;
8010677b:	89 fb                	mov    %edi,%ebx
8010677d:	eb a8                	jmp    80106727 <copyout+0xe>
  }
  return 0;
8010677f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106784:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106787:	5b                   	pop    %ebx
80106788:	5e                   	pop    %esi
80106789:	5f                   	pop    %edi
8010678a:	5d                   	pop    %ebp
8010678b:	c3                   	ret    
      return -1;
8010678c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106791:	eb f1                	jmp    80106784 <copyout+0x6b>
