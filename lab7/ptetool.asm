
_ptetool:     file format elf32-i386


Disassembly of section .text:

00000000 <dump_pte>:
#include "types.h"
#include "user.h"
#include "mmu.h"

/* print out the contents of a page table entry (given as an integer) to stdout */
void dump_pte(pte_t pte) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
   6:	8b 45 08             	mov    0x8(%ebp),%eax
    if (pte & PTE_P) {
   9:	a8 01                	test   $0x1,%al
   b:	74 47                	je     54 <dump_pte+0x54>
        printf(1, "P %s %s %x\n",
   d:	89 c1                	mov    %eax,%ecx
   f:	c1 e9 0c             	shr    $0xc,%ecx
  12:	a8 02                	test   $0x2,%al
  14:	74 07                	je     1d <dump_pte+0x1d>
  16:	ba 18 07 00 00       	mov    $0x718,%edx
  1b:	eb 05                	jmp    22 <dump_pte+0x22>
  1d:	ba 1a 07 00 00       	mov    $0x71a,%edx
  22:	a8 04                	test   $0x4,%al
  24:	74 07                	je     2d <dump_pte+0x2d>
  26:	b8 1c 07 00 00       	mov    $0x71c,%eax
  2b:	eb 05                	jmp    32 <dump_pte+0x32>
  2d:	b8 1a 07 00 00       	mov    $0x71a,%eax
  32:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  36:	89 54 24 0c          	mov    %edx,0xc(%esp)
  3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  3e:	c7 44 24 04 1e 07 00 	movl   $0x71e,0x4(%esp)
  45:	00 
  46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  4d:	e8 6a 05 00 00       	call   5bc <printf>
  52:	eb 14                	jmp    68 <dump_pte+0x68>
            pte & PTE_U ? "U" : "-",
            pte & PTE_W ? "W" : "-",
            PTE_ADDR(pte) >> PTXSHIFT
        );
    } else {
        printf(1, "- <not present>\n");
  54:	c7 44 24 04 2a 07 00 	movl   $0x72a,0x4(%esp)
  5b:	00 
  5c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  63:	e8 54 05 00 00       	call   5bc <printf>
    }
}
  68:	c9                   	leave  
  69:	c3                   	ret    

0000006a <usage>:

void usage(const char *argv0) {
  6a:	55                   	push   %ebp
  6b:	89 e5                	mov    %esp,%ebp
  6d:	83 ec 28             	sub    $0x28,%esp
  70:	8b 45 08             	mov    0x8(%ebp),%eax
    printf(1,
  73:	89 44 24 14          	mov    %eax,0x14(%esp)
  77:	89 44 24 10          	mov    %eax,0x10(%esp)
  7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  83:	c7 44 24 04 60 07 00 	movl   $0x760,0x4(%esp)
  8a:	00 
  8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  92:	e8 25 05 00 00       	call   5bc <printf>
        "      call dumppagetable(PID). PID is specified in decimal\n"
        "   %s isfree PPN\n"
        "      call isphysicalpagefree(PPN). PPN is specified in hexadecimal\n",
        argv0, argv0, argv0, argv0
    );
    exit();
  97:	e8 8e 03 00 00       	call   42a <exit>

0000009c <hextoi>:
}

/* convert a hexadecimal number contained in the stirng 'value' to an uint */
uint hextoi(const char *value) {
  9c:	55                   	push   %ebp
  9d:	89 e5                	mov    %esp,%ebp
  9f:	56                   	push   %esi
  a0:	53                   	push   %ebx
  a1:	83 ec 10             	sub    $0x10,%esp
  a4:	8b 75 08             	mov    0x8(%ebp),%esi
    const char *p;
    p = value;
    uint result = 0;
    /* skip any leading 0x or 0X */
    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
  a7:	80 3e 30             	cmpb   $0x30,(%esi)
  aa:	75 17                	jne    c3 <hextoi+0x27>
  ac:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  b0:	3c 78                	cmp    $0x78,%al
  b2:	0f 94 c2             	sete   %dl
  b5:	3c 58                	cmp    $0x58,%al
  b7:	0f 94 c0             	sete   %al
  ba:	08 c2                	or     %al,%dl
  bc:	74 09                	je     c7 <hextoi+0x2b>
        p += 2;
  be:	8d 4e 02             	lea    0x2(%esi),%ecx
  c1:	eb 06                	jmp    c9 <hextoi+0x2d>
    p = value;
  c3:	89 f1                	mov    %esi,%ecx
  c5:	eb 02                	jmp    c9 <hextoi+0x2d>
  c7:	89 f1                	mov    %esi,%ecx
  c9:	b8 00 00 00 00       	mov    $0x0,%eax
  ce:	eb 58                	jmp    128 <hextoi+0x8c>
    }
    while (*p) {
        /* shift previous values over 4 */
        result = result << 4;
  d0:	c1 e0 04             	shl    $0x4,%eax
        /* add next chraacter */
        if (*p >= '0' && *p <= '9') {
  d3:	8d 5a d0             	lea    -0x30(%edx),%ebx
  d6:	80 fb 09             	cmp    $0x9,%bl
  d9:	77 09                	ja     e4 <hextoi+0x48>
            result += *p - '0';
  db:	0f be d2             	movsbl %dl,%edx
  de:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
  e2:	eb 41                	jmp    125 <hextoi+0x89>
        } else if (*p >= 'a' && *p <= 'f') {
  e4:	8d 5a 9f             	lea    -0x61(%edx),%ebx
  e7:	80 fb 05             	cmp    $0x5,%bl
  ea:	77 09                	ja     f5 <hextoi+0x59>
            result += (*p - 'a') + 10;
  ec:	0f be d2             	movsbl %dl,%edx
  ef:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  f3:	eb 30                	jmp    125 <hextoi+0x89>
        } else if (*p >= 'A' && *p <= 'F') {
  f5:	8d 5a bf             	lea    -0x41(%edx),%ebx
  f8:	80 fb 05             	cmp    $0x5,%bl
  fb:	77 09                	ja     106 <hextoi+0x6a>
            result += (*p - 'A') + 10;
  fd:	0f be d2             	movsbl %dl,%edx
 100:	8d 44 10 c9          	lea    -0x37(%eax,%edx,1),%eax
 104:	eb 1f                	jmp    125 <hextoi+0x89>
        } else {
            printf(2, "malformed hexadecimal number '%s'\n", value);
 106:	89 74 24 08          	mov    %esi,0x8(%esp)
 10a:	c7 44 24 04 d4 08 00 	movl   $0x8d4,0x4(%esp)
 111:	00 
 112:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 119:	e8 9e 04 00 00       	call   5bc <printf>
            return 0;
 11e:	b8 00 00 00 00       	mov    $0x0,%eax
 123:	eb 0a                	jmp    12f <hextoi+0x93>
        }
        /* advance to next character */
        p += 1;
 125:	83 c1 01             	add    $0x1,%ecx
    while (*p) {
 128:	0f b6 11             	movzbl (%ecx),%edx
 12b:	84 d2                	test   %dl,%dl
 12d:	75 a1                	jne    d0 <hextoi+0x34>
    }
    return result;
}
 12f:	83 c4 10             	add    $0x10,%esp
 132:	5b                   	pop    %ebx
 133:	5e                   	pop    %esi
 134:	5d                   	pop    %ebp
 135:	c3                   	ret    

00000136 <main>:

int main(int argc, char **argv) {
 136:	55                   	push   %ebp
 137:	89 e5                	mov    %esp,%ebp
 139:	57                   	push   %edi
 13a:	56                   	push   %esi
 13b:	53                   	push   %ebx
 13c:	83 e4 f0             	and    $0xfffffff0,%esp
 13f:	83 ec 10             	sub    $0x10,%esp
 142:	8b 75 08             	mov    0x8(%ebp),%esi
 145:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc < 2) {
 148:	83 fe 01             	cmp    $0x1,%esi
 14b:	7f 0a                	jg     157 <main+0x21>
        usage(argv[0]);
 14d:	8b 03                	mov    (%ebx),%eax
 14f:	89 04 24             	mov    %eax,(%esp)
 152:	e8 13 ff ff ff       	call   6a <usage>
    } else if (0 == strcmp(argv[1], "pte")) {
 157:	c7 44 24 04 3b 07 00 	movl   $0x73b,0x4(%esp)
 15e:	00 
 15f:	8b 43 04             	mov    0x4(%ebx),%eax
 162:	89 04 24             	mov    %eax,(%esp)
 165:	e8 3d 01 00 00       	call   2a7 <strcmp>
 16a:	85 c0                	test   %eax,%eax
 16c:	75 78                	jne    1e6 <main+0xb0>
        if (argc != 4) { usage(argv[0]); }
 16e:	83 fe 04             	cmp    $0x4,%esi
 171:	74 0a                	je     17d <main+0x47>
 173:	8b 03                	mov    (%ebx),%eax
 175:	89 04 24             	mov    %eax,(%esp)
 178:	e8 ed fe ff ff       	call   6a <usage>
        int pid = atoi(argv[2]);
 17d:	8b 43 08             	mov    0x8(%ebx),%eax
 180:	89 04 24             	mov    %eax,(%esp)
 183:	e8 45 02 00 00       	call   3cd <atoi>
 188:	89 c6                	mov    %eax,%esi
        uint va = hextoi(argv[3]);
 18a:	8b 43 0c             	mov    0xc(%ebx),%eax
 18d:	89 04 24             	mov    %eax,(%esp)
 190:	e8 07 ff ff ff       	call   9c <hextoi>
 195:	89 c7                	mov    %eax,%edi
        uint raw_pte = getpagetableentry(pid, va);
 197:	89 44 24 04          	mov    %eax,0x4(%esp)
 19b:	89 34 24             	mov    %esi,(%esp)
 19e:	e8 57 03 00 00       	call   4fa <getpagetableentry>
 1a3:	89 c3                	mov    %eax,%ebx
        printf(1, "PID %d, last-level PTE for %x: ", pid, va);
 1a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
 1a9:	89 74 24 08          	mov    %esi,0x8(%esp)
 1ad:	c7 44 24 04 f8 08 00 	movl   $0x8f8,0x4(%esp)
 1b4:	00 
 1b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bc:	e8 fb 03 00 00       	call   5bc <printf>
        dump_pte(raw_pte);
 1c1:	89 1c 24             	mov    %ebx,(%esp)
 1c4:	e8 37 fe ff ff       	call   0 <dump_pte>
        printf(1, "(raw value 0x%x)\n", raw_pte);
 1c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 1cd:	c7 44 24 04 3f 07 00 	movl   $0x73f,0x4(%esp)
 1d4:	00 
 1d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1dc:	e8 db 03 00 00       	call   5bc <printf>
 1e1:	e9 9e 00 00 00       	jmp    284 <main+0x14e>
    } else if (0 == strcmp(argv[1], "dump")) {
 1e6:	c7 44 24 04 51 07 00 	movl   $0x751,0x4(%esp)
 1ed:	00 
 1ee:	8b 43 04             	mov    0x4(%ebx),%eax
 1f1:	89 04 24             	mov    %eax,(%esp)
 1f4:	e8 ae 00 00 00       	call   2a7 <strcmp>
 1f9:	85 c0                	test   %eax,%eax
 1fb:	75 24                	jne    221 <main+0xeb>
        if (argc != 3) { usage(argv[0]); }
 1fd:	83 fe 03             	cmp    $0x3,%esi
 200:	74 0a                	je     20c <main+0xd6>
 202:	8b 03                	mov    (%ebx),%eax
 204:	89 04 24             	mov    %eax,(%esp)
 207:	e8 5e fe ff ff       	call   6a <usage>
        int pid = atoi(argv[2]);
 20c:	8b 43 08             	mov    0x8(%ebx),%eax
 20f:	89 04 24             	mov    %eax,(%esp)
 212:	e8 b6 01 00 00       	call   3cd <atoi>
        dumppagetable(pid);
 217:	89 04 24             	mov    %eax,(%esp)
 21a:	e8 eb 02 00 00       	call   50a <dumppagetable>
 21f:	eb 63                	jmp    284 <main+0x14e>
    } else if (0 == strcmp(argv[1], "isfree")) {
 221:	c7 44 24 04 56 07 00 	movl   $0x756,0x4(%esp)
 228:	00 
 229:	8b 43 04             	mov    0x4(%ebx),%eax
 22c:	89 04 24             	mov    %eax,(%esp)
 22f:	e8 73 00 00 00       	call   2a7 <strcmp>
 234:	85 c0                	test   %eax,%eax
 236:	75 42                	jne    27a <main+0x144>
        if (argc != 3) { usage(argv[0]); }
 238:	83 fe 03             	cmp    $0x3,%esi
 23b:	74 0a                	je     247 <main+0x111>
 23d:	8b 03                	mov    (%ebx),%eax
 23f:	89 04 24             	mov    %eax,(%esp)
 242:	e8 23 fe ff ff       	call   6a <usage>
        int ppn = hextoi(argv[2]);
 247:	8b 43 08             	mov    0x8(%ebx),%eax
 24a:	89 04 24             	mov    %eax,(%esp)
 24d:	e8 4a fe ff ff       	call   9c <hextoi>
 252:	89 c3                	mov    %eax,%ebx
        printf(1, "isphysicalpagefree(0x%x) = %d\n", ppn, isphysicalpagefree(ppn));
 254:	89 04 24             	mov    %eax,(%esp)
 257:	e8 a6 02 00 00       	call   502 <isphysicalpagefree>
 25c:	89 44 24 0c          	mov    %eax,0xc(%esp)
 260:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 264:	c7 44 24 04 18 09 00 	movl   $0x918,0x4(%esp)
 26b:	00 
 26c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 273:	e8 44 03 00 00       	call   5bc <printf>
 278:	eb 0a                	jmp    284 <main+0x14e>
    } else {
        usage(argv[0]);
 27a:	8b 03                	mov    (%ebx),%eax
 27c:	89 04 24             	mov    %eax,(%esp)
 27f:	e8 e6 fd ff ff       	call   6a <usage>
    }
    exit();
 284:	e8 a1 01 00 00       	call   42a <exit>

00000289 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	53                   	push   %ebx
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
 290:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 293:	89 c2                	mov    %eax,%edx
 295:	0f b6 19             	movzbl (%ecx),%ebx
 298:	88 1a                	mov    %bl,(%edx)
 29a:	8d 52 01             	lea    0x1(%edx),%edx
 29d:	8d 49 01             	lea    0x1(%ecx),%ecx
 2a0:	84 db                	test   %bl,%bl
 2a2:	75 f1                	jne    295 <strcpy+0xc>
    ;
  return os;
}
 2a4:	5b                   	pop    %ebx
 2a5:	5d                   	pop    %ebp
 2a6:	c3                   	ret    

000002a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a7:	55                   	push   %ebp
 2a8:	89 e5                	mov    %esp,%ebp
 2aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 2b0:	eb 06                	jmp    2b8 <strcmp+0x11>
    p++, q++;
 2b2:	83 c1 01             	add    $0x1,%ecx
 2b5:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 2b8:	0f b6 01             	movzbl (%ecx),%eax
 2bb:	84 c0                	test   %al,%al
 2bd:	74 04                	je     2c3 <strcmp+0x1c>
 2bf:	3a 02                	cmp    (%edx),%al
 2c1:	74 ef                	je     2b2 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 2c3:	0f b6 c0             	movzbl %al,%eax
 2c6:	0f b6 12             	movzbl (%edx),%edx
 2c9:	29 d0                	sub    %edx,%eax
}
 2cb:	5d                   	pop    %ebp
 2cc:	c3                   	ret    

000002cd <strlen>:

uint
strlen(const char *s)
{
 2cd:	55                   	push   %ebp
 2ce:	89 e5                	mov    %esp,%ebp
 2d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 2d3:	ba 00 00 00 00       	mov    $0x0,%edx
 2d8:	eb 03                	jmp    2dd <strlen+0x10>
 2da:	83 c2 01             	add    $0x1,%edx
 2dd:	89 d0                	mov    %edx,%eax
 2df:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 2e3:	75 f5                	jne    2da <strlen+0xd>
    ;
  return n;
}
 2e5:	5d                   	pop    %ebp
 2e6:	c3                   	ret    

000002e7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e7:	55                   	push   %ebp
 2e8:	89 e5                	mov    %esp,%ebp
 2ea:	57                   	push   %edi
 2eb:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 2ee:	89 d7                	mov    %edx,%edi
 2f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f6:	fc                   	cld    
 2f7:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 2f9:	89 d0                	mov    %edx,%eax
 2fb:	5f                   	pop    %edi
 2fc:	5d                   	pop    %ebp
 2fd:	c3                   	ret    

000002fe <strchr>:

char*
strchr(const char *s, char c)
{
 2fe:	55                   	push   %ebp
 2ff:	89 e5                	mov    %esp,%ebp
 301:	8b 45 08             	mov    0x8(%ebp),%eax
 304:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 308:	eb 07                	jmp    311 <strchr+0x13>
    if(*s == c)
 30a:	38 ca                	cmp    %cl,%dl
 30c:	74 0f                	je     31d <strchr+0x1f>
  for(; *s; s++)
 30e:	83 c0 01             	add    $0x1,%eax
 311:	0f b6 10             	movzbl (%eax),%edx
 314:	84 d2                	test   %dl,%dl
 316:	75 f2                	jne    30a <strchr+0xc>
      return (char*)s;
  return 0;
 318:	b8 00 00 00 00       	mov    $0x0,%eax
}
 31d:	5d                   	pop    %ebp
 31e:	c3                   	ret    

0000031f <gets>:

char*
gets(char *buf, int max)
{
 31f:	55                   	push   %ebp
 320:	89 e5                	mov    %esp,%ebp
 322:	57                   	push   %edi
 323:	56                   	push   %esi
 324:	53                   	push   %ebx
 325:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 328:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
 32d:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
 330:	eb 36                	jmp    368 <gets+0x49>
    cc = read(0, &c, 1);
 332:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 339:	00 
 33a:	89 7c 24 04          	mov    %edi,0x4(%esp)
 33e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 345:	e8 f8 00 00 00       	call   442 <read>
    if(cc < 1)
 34a:	85 c0                	test   %eax,%eax
 34c:	7e 26                	jle    374 <gets+0x55>
      break;
    buf[i++] = c;
 34e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 352:	8b 4d 08             	mov    0x8(%ebp),%ecx
 355:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
 358:	3c 0a                	cmp    $0xa,%al
 35a:	0f 94 c2             	sete   %dl
 35d:	3c 0d                	cmp    $0xd,%al
 35f:	0f 94 c0             	sete   %al
    buf[i++] = c;
 362:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 364:	08 c2                	or     %al,%dl
 366:	75 0a                	jne    372 <gets+0x53>
  for(i=0; i+1 < max; ){
 368:	8d 73 01             	lea    0x1(%ebx),%esi
 36b:	3b 75 0c             	cmp    0xc(%ebp),%esi
 36e:	7c c2                	jl     332 <gets+0x13>
 370:	eb 02                	jmp    374 <gets+0x55>
    buf[i++] = c;
 372:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
 374:	8b 45 08             	mov    0x8(%ebp),%eax
 377:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 37b:	83 c4 2c             	add    $0x2c,%esp
 37e:	5b                   	pop    %ebx
 37f:	5e                   	pop    %esi
 380:	5f                   	pop    %edi
 381:	5d                   	pop    %ebp
 382:	c3                   	ret    

00000383 <stat>:

int
stat(const char *n, struct stat *st)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	56                   	push   %esi
 387:	53                   	push   %ebx
 388:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 38b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 392:	00 
 393:	8b 45 08             	mov    0x8(%ebp),%eax
 396:	89 04 24             	mov    %eax,(%esp)
 399:	e8 cc 00 00 00       	call   46a <open>
 39e:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 3a0:	85 c0                	test   %eax,%eax
 3a2:	78 1d                	js     3c1 <stat+0x3e>
    return -1;
  r = fstat(fd, st);
 3a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 3ab:	89 1c 24             	mov    %ebx,(%esp)
 3ae:	e8 cf 00 00 00       	call   482 <fstat>
 3b3:	89 c6                	mov    %eax,%esi
  close(fd);
 3b5:	89 1c 24             	mov    %ebx,(%esp)
 3b8:	e8 95 00 00 00       	call   452 <close>
  return r;
 3bd:	89 f0                	mov    %esi,%eax
 3bf:	eb 05                	jmp    3c6 <stat+0x43>
    return -1;
 3c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 3c6:	83 c4 10             	add    $0x10,%esp
 3c9:	5b                   	pop    %ebx
 3ca:	5e                   	pop    %esi
 3cb:	5d                   	pop    %ebp
 3cc:	c3                   	ret    

000003cd <atoi>:

int
atoi(const char *s)
{
 3cd:	55                   	push   %ebp
 3ce:	89 e5                	mov    %esp,%ebp
 3d0:	53                   	push   %ebx
 3d1:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
 3d4:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 3d9:	eb 0f                	jmp    3ea <atoi+0x1d>
    n = n*10 + *s++ - '0';
 3db:	8d 04 80             	lea    (%eax,%eax,4),%eax
 3de:	01 c0                	add    %eax,%eax
 3e0:	83 c2 01             	add    $0x1,%edx
 3e3:	0f be c9             	movsbl %cl,%ecx
 3e6:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
 3ea:	0f b6 0a             	movzbl (%edx),%ecx
 3ed:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 3f0:	80 fb 09             	cmp    $0x9,%bl
 3f3:	76 e6                	jbe    3db <atoi+0xe>
  return n;
}
 3f5:	5b                   	pop    %ebx
 3f6:	5d                   	pop    %ebp
 3f7:	c3                   	ret    

000003f8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3f8:	55                   	push   %ebp
 3f9:	89 e5                	mov    %esp,%ebp
 3fb:	56                   	push   %esi
 3fc:	53                   	push   %ebx
 3fd:	8b 45 08             	mov    0x8(%ebp),%eax
 400:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 403:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 406:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 408:	eb 0d                	jmp    417 <memmove+0x1f>
    *dst++ = *src++;
 40a:	0f b6 13             	movzbl (%ebx),%edx
 40d:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
 40f:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
 411:	8d 5b 01             	lea    0x1(%ebx),%ebx
 414:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 417:	8d 72 ff             	lea    -0x1(%edx),%esi
 41a:	85 d2                	test   %edx,%edx
 41c:	7f ec                	jg     40a <memmove+0x12>
  return vdst;
}
 41e:	5b                   	pop    %ebx
 41f:	5e                   	pop    %esi
 420:	5d                   	pop    %ebp
 421:	c3                   	ret    

00000422 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 422:	b8 01 00 00 00       	mov    $0x1,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <exit>:
SYSCALL(exit)
 42a:	b8 02 00 00 00       	mov    $0x2,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <wait>:
SYSCALL(wait)
 432:	b8 03 00 00 00       	mov    $0x3,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <pipe>:
SYSCALL(pipe)
 43a:	b8 04 00 00 00       	mov    $0x4,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <read>:
SYSCALL(read)
 442:	b8 05 00 00 00       	mov    $0x5,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <write>:
SYSCALL(write)
 44a:	b8 10 00 00 00       	mov    $0x10,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <close>:
SYSCALL(close)
 452:	b8 15 00 00 00       	mov    $0x15,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <kill>:
SYSCALL(kill)
 45a:	b8 06 00 00 00       	mov    $0x6,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <exec>:
SYSCALL(exec)
 462:	b8 07 00 00 00       	mov    $0x7,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <open>:
SYSCALL(open)
 46a:	b8 0f 00 00 00       	mov    $0xf,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <mknod>:
SYSCALL(mknod)
 472:	b8 11 00 00 00       	mov    $0x11,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <unlink>:
SYSCALL(unlink)
 47a:	b8 12 00 00 00       	mov    $0x12,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <fstat>:
SYSCALL(fstat)
 482:	b8 08 00 00 00       	mov    $0x8,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <link>:
SYSCALL(link)
 48a:	b8 13 00 00 00       	mov    $0x13,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <mkdir>:
SYSCALL(mkdir)
 492:	b8 14 00 00 00       	mov    $0x14,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    

0000049a <chdir>:
SYSCALL(chdir)
 49a:	b8 09 00 00 00       	mov    $0x9,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret    

000004a2 <dup>:
SYSCALL(dup)
 4a2:	b8 0a 00 00 00       	mov    $0xa,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret    

000004aa <getpid>:
SYSCALL(getpid)
 4aa:	b8 0b 00 00 00       	mov    $0xb,%eax
 4af:	cd 40                	int    $0x40
 4b1:	c3                   	ret    

000004b2 <sbrk>:
SYSCALL(sbrk)
 4b2:	b8 0c 00 00 00       	mov    $0xc,%eax
 4b7:	cd 40                	int    $0x40
 4b9:	c3                   	ret    

000004ba <sleep>:
SYSCALL(sleep)
 4ba:	b8 0d 00 00 00       	mov    $0xd,%eax
 4bf:	cd 40                	int    $0x40
 4c1:	c3                   	ret    

000004c2 <uptime>:
SYSCALL(uptime)
 4c2:	b8 0e 00 00 00       	mov    $0xe,%eax
 4c7:	cd 40                	int    $0x40
 4c9:	c3                   	ret    

000004ca <yield>:
SYSCALL(yield)
 4ca:	b8 16 00 00 00       	mov    $0x16,%eax
 4cf:	cd 40                	int    $0x40
 4d1:	c3                   	ret    

000004d2 <shutdown>:
SYSCALL(shutdown)
 4d2:	b8 17 00 00 00       	mov    $0x17,%eax
 4d7:	cd 40                	int    $0x40
 4d9:	c3                   	ret    

000004da <writecount>:
SYSCALL(writecount)
 4da:	b8 18 00 00 00       	mov    $0x18,%eax
 4df:	cd 40                	int    $0x40
 4e1:	c3                   	ret    

000004e2 <setwritecount>:
SYSCALL(setwritecount)
 4e2:	b8 19 00 00 00       	mov    $0x19,%eax
 4e7:	cd 40                	int    $0x40
 4e9:	c3                   	ret    

000004ea <settickets>:
SYSCALL(settickets)
 4ea:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ef:	cd 40                	int    $0x40
 4f1:	c3                   	ret    

000004f2 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 4f2:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4f7:	cd 40                	int    $0x40
 4f9:	c3                   	ret    

000004fa <getpagetableentry>:
SYSCALL(getpagetableentry)
 4fa:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4ff:	cd 40                	int    $0x40
 501:	c3                   	ret    

00000502 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 502:	b8 1d 00 00 00       	mov    $0x1d,%eax
 507:	cd 40                	int    $0x40
 509:	c3                   	ret    

0000050a <dumppagetable>:
 50a:	b8 1e 00 00 00       	mov    $0x1e,%eax
 50f:	cd 40                	int    $0x40
 511:	c3                   	ret    
 512:	66 90                	xchg   %ax,%ax
 514:	66 90                	xchg   %ax,%ax
 516:	66 90                	xchg   %ax,%ax
 518:	66 90                	xchg   %ax,%ax
 51a:	66 90                	xchg   %ax,%ax
 51c:	66 90                	xchg   %ax,%ax
 51e:	66 90                	xchg   %ax,%ax

00000520 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 520:	55                   	push   %ebp
 521:	89 e5                	mov    %esp,%ebp
 523:	83 ec 18             	sub    $0x18,%esp
 526:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 529:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 530:	00 
 531:	8d 55 f4             	lea    -0xc(%ebp),%edx
 534:	89 54 24 04          	mov    %edx,0x4(%esp)
 538:	89 04 24             	mov    %eax,(%esp)
 53b:	e8 0a ff ff ff       	call   44a <write>
}
 540:	c9                   	leave  
 541:	c3                   	ret    

00000542 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 542:	55                   	push   %ebp
 543:	89 e5                	mov    %esp,%ebp
 545:	57                   	push   %edi
 546:	56                   	push   %esi
 547:	53                   	push   %ebx
 548:	83 ec 2c             	sub    $0x2c,%esp
 54b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 54d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 551:	0f 95 c3             	setne  %bl
 554:	89 d0                	mov    %edx,%eax
 556:	c1 e8 1f             	shr    $0x1f,%eax
 559:	84 c3                	test   %al,%bl
 55b:	74 0b                	je     568 <printint+0x26>
    neg = 1;
    x = -xx;
 55d:	f7 da                	neg    %edx
    neg = 1;
 55f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 566:	eb 07                	jmp    56f <printint+0x2d>
  neg = 0;
 568:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 56f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 574:	8d 5e 01             	lea    0x1(%esi),%ebx
 577:	89 d0                	mov    %edx,%eax
 579:	ba 00 00 00 00       	mov    $0x0,%edx
 57e:	f7 f1                	div    %ecx
 580:	0f b6 92 3f 09 00 00 	movzbl 0x93f(%edx),%edx
 587:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 58b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 58d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 58f:	85 c0                	test   %eax,%eax
 591:	75 e1                	jne    574 <printint+0x32>
  if(neg)
 593:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 597:	74 16                	je     5af <printint+0x6d>
    buf[i++] = '-';
 599:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 59e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 5a1:	eb 0c                	jmp    5af <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 5a3:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 5a8:	89 f8                	mov    %edi,%eax
 5aa:	e8 71 ff ff ff       	call   520 <putc>
  while(--i >= 0)
 5af:	83 eb 01             	sub    $0x1,%ebx
 5b2:	79 ef                	jns    5a3 <printint+0x61>
}
 5b4:	83 c4 2c             	add    $0x2c,%esp
 5b7:	5b                   	pop    %ebx
 5b8:	5e                   	pop    %esi
 5b9:	5f                   	pop    %edi
 5ba:	5d                   	pop    %ebp
 5bb:	c3                   	ret    

000005bc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5bc:	55                   	push   %ebp
 5bd:	89 e5                	mov    %esp,%ebp
 5bf:	57                   	push   %edi
 5c0:	56                   	push   %esi
 5c1:	53                   	push   %ebx
 5c2:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 5c5:	8d 45 10             	lea    0x10(%ebp),%eax
 5c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 5cb:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 5d0:	be 00 00 00 00       	mov    $0x0,%esi
 5d5:	e9 23 01 00 00       	jmp    6fd <printf+0x141>
    c = fmt[i] & 0xff;
 5da:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 5dd:	85 ff                	test   %edi,%edi
 5df:	75 19                	jne    5fa <printf+0x3e>
      if(c == '%'){
 5e1:	83 f8 25             	cmp    $0x25,%eax
 5e4:	0f 84 0b 01 00 00    	je     6f5 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 5ea:	0f be d3             	movsbl %bl,%edx
 5ed:	8b 45 08             	mov    0x8(%ebp),%eax
 5f0:	e8 2b ff ff ff       	call   520 <putc>
 5f5:	e9 00 01 00 00       	jmp    6fa <printf+0x13e>
      }
    } else if(state == '%'){
 5fa:	83 ff 25             	cmp    $0x25,%edi
 5fd:	0f 85 f7 00 00 00    	jne    6fa <printf+0x13e>
      if(c == 'd'){
 603:	83 f8 64             	cmp    $0x64,%eax
 606:	75 26                	jne    62e <printf+0x72>
        printint(fd, *ap, 10, 1);
 608:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 60b:	8b 10                	mov    (%eax),%edx
 60d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 614:	b9 0a 00 00 00       	mov    $0xa,%ecx
 619:	8b 45 08             	mov    0x8(%ebp),%eax
 61c:	e8 21 ff ff ff       	call   542 <printint>
        ap++;
 621:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 625:	66 bf 00 00          	mov    $0x0,%di
 629:	e9 cc 00 00 00       	jmp    6fa <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 62e:	83 f8 78             	cmp    $0x78,%eax
 631:	0f 94 c1             	sete   %cl
 634:	83 f8 70             	cmp    $0x70,%eax
 637:	0f 94 c2             	sete   %dl
 63a:	08 d1                	or     %dl,%cl
 63c:	74 27                	je     665 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 63e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 641:	8b 10                	mov    (%eax),%edx
 643:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 64a:	b9 10 00 00 00       	mov    $0x10,%ecx
 64f:	8b 45 08             	mov    0x8(%ebp),%eax
 652:	e8 eb fe ff ff       	call   542 <printint>
        ap++;
 657:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 65b:	bf 00 00 00 00       	mov    $0x0,%edi
 660:	e9 95 00 00 00       	jmp    6fa <printf+0x13e>
      } else if(c == 's'){
 665:	83 f8 73             	cmp    $0x73,%eax
 668:	75 37                	jne    6a1 <printf+0xe5>
        s = (char*)*ap;
 66a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66d:	8b 18                	mov    (%eax),%ebx
        ap++;
 66f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 673:	85 db                	test   %ebx,%ebx
 675:	75 19                	jne    690 <printf+0xd4>
          s = "(null)";
 677:	bb 38 09 00 00       	mov    $0x938,%ebx
 67c:	8b 7d 08             	mov    0x8(%ebp),%edi
 67f:	eb 12                	jmp    693 <printf+0xd7>
          putc(fd, *s);
 681:	0f be d2             	movsbl %dl,%edx
 684:	89 f8                	mov    %edi,%eax
 686:	e8 95 fe ff ff       	call   520 <putc>
          s++;
 68b:	83 c3 01             	add    $0x1,%ebx
 68e:	eb 03                	jmp    693 <printf+0xd7>
 690:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 693:	0f b6 13             	movzbl (%ebx),%edx
 696:	84 d2                	test   %dl,%dl
 698:	75 e7                	jne    681 <printf+0xc5>
      state = 0;
 69a:	bf 00 00 00 00       	mov    $0x0,%edi
 69f:	eb 59                	jmp    6fa <printf+0x13e>
      } else if(c == 'c'){
 6a1:	83 f8 63             	cmp    $0x63,%eax
 6a4:	75 19                	jne    6bf <printf+0x103>
        putc(fd, *ap);
 6a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a9:	0f be 10             	movsbl (%eax),%edx
 6ac:	8b 45 08             	mov    0x8(%ebp),%eax
 6af:	e8 6c fe ff ff       	call   520 <putc>
        ap++;
 6b4:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 6b8:	bf 00 00 00 00       	mov    $0x0,%edi
 6bd:	eb 3b                	jmp    6fa <printf+0x13e>
      } else if(c == '%'){
 6bf:	83 f8 25             	cmp    $0x25,%eax
 6c2:	75 12                	jne    6d6 <printf+0x11a>
        putc(fd, c);
 6c4:	0f be d3             	movsbl %bl,%edx
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	e8 51 fe ff ff       	call   520 <putc>
      state = 0;
 6cf:	bf 00 00 00 00       	mov    $0x0,%edi
 6d4:	eb 24                	jmp    6fa <printf+0x13e>
        putc(fd, '%');
 6d6:	ba 25 00 00 00       	mov    $0x25,%edx
 6db:	8b 45 08             	mov    0x8(%ebp),%eax
 6de:	e8 3d fe ff ff       	call   520 <putc>
        putc(fd, c);
 6e3:	0f be d3             	movsbl %bl,%edx
 6e6:	8b 45 08             	mov    0x8(%ebp),%eax
 6e9:	e8 32 fe ff ff       	call   520 <putc>
      state = 0;
 6ee:	bf 00 00 00 00       	mov    $0x0,%edi
 6f3:	eb 05                	jmp    6fa <printf+0x13e>
        state = '%';
 6f5:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 6fa:	83 c6 01             	add    $0x1,%esi
 6fd:	89 f0                	mov    %esi,%eax
 6ff:	03 45 0c             	add    0xc(%ebp),%eax
 702:	0f b6 18             	movzbl (%eax),%ebx
 705:	84 db                	test   %bl,%bl
 707:	0f 85 cd fe ff ff    	jne    5da <printf+0x1e>
    }
  }
}
 70d:	83 c4 1c             	add    $0x1c,%esp
 710:	5b                   	pop    %ebx
 711:	5e                   	pop    %esi
 712:	5f                   	pop    %edi
 713:	5d                   	pop    %ebp
 714:	c3                   	ret    
