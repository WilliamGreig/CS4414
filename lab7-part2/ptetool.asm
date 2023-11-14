
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
   3:	83 ec 08             	sub    $0x8,%esp
   6:	8b 45 08             	mov    0x8(%ebp),%eax
    if (pte & PTE_P) {
   9:	a8 01                	test   $0x1,%al
   b:	74 3c                	je     49 <dump_pte+0x49>
        printf(1, "P %s %s %x\n",
   d:	89 c1                	mov    %eax,%ecx
   f:	c1 e9 0c             	shr    $0xc,%ecx
  12:	a8 02                	test   $0x2,%al
  14:	74 25                	je     3b <dump_pte+0x3b>
  16:	ba bc 06 00 00       	mov    $0x6bc,%edx
  1b:	a8 04                	test   $0x4,%al
  1d:	74 23                	je     42 <dump_pte+0x42>
  1f:	b8 c0 06 00 00       	mov    $0x6c0,%eax
  24:	83 ec 0c             	sub    $0xc,%esp
  27:	51                   	push   %ecx
  28:	52                   	push   %edx
  29:	50                   	push   %eax
  2a:	68 c2 06 00 00       	push   $0x6c2
  2f:	6a 01                	push   $0x1
  31:	e8 20 05 00 00       	call   556 <printf>
  36:	83 c4 20             	add    $0x20,%esp
            PTE_ADDR(pte) >> PTXSHIFT
        );
    } else {
        printf(1, "- <not present>\n");
    }
}
  39:	c9                   	leave  
  3a:	c3                   	ret    
        printf(1, "P %s %s %x\n",
  3b:	ba be 06 00 00       	mov    $0x6be,%edx
  40:	eb d9                	jmp    1b <dump_pte+0x1b>
  42:	b8 be 06 00 00       	mov    $0x6be,%eax
  47:	eb db                	jmp    24 <dump_pte+0x24>
        printf(1, "- <not present>\n");
  49:	83 ec 08             	sub    $0x8,%esp
  4c:	68 ce 06 00 00       	push   $0x6ce
  51:	6a 01                	push   $0x1
  53:	e8 fe 04 00 00       	call   556 <printf>
  58:	83 c4 10             	add    $0x10,%esp
}
  5b:	eb dc                	jmp    39 <dump_pte+0x39>

0000005d <usage>:

void usage(const char *argv0) {
  5d:	55                   	push   %ebp
  5e:	89 e5                	mov    %esp,%ebp
  60:	83 ec 10             	sub    $0x10,%esp
  63:	8b 45 08             	mov    0x8(%ebp),%eax
    printf(1,
  66:	50                   	push   %eax
  67:	50                   	push   %eax
  68:	50                   	push   %eax
  69:	50                   	push   %eax
  6a:	68 04 07 00 00       	push   $0x704
  6f:	6a 01                	push   $0x1
  71:	e8 e0 04 00 00       	call   556 <printf>
        "      call dumppagetable(PID). PID is specified in decimal\n"
        "   %s isfree PPN\n"
        "      call isphysicalpagefree(PPN). PPN is specified in hexadecimal\n",
        argv0, argv0, argv0, argv0
    );
    exit();
  76:	83 c4 20             	add    $0x20,%esp
  79:	e8 6b 03 00 00       	call   3e9 <exit>

0000007e <hextoi>:
}

/* convert a hexadecimal number contained in the stirng 'value' to an uint */
uint hextoi(const char *value) {
  7e:	55                   	push   %ebp
  7f:	89 e5                	mov    %esp,%ebp
  81:	56                   	push   %esi
  82:	53                   	push   %ebx
  83:	8b 75 08             	mov    0x8(%ebp),%esi
    const char *p;
    p = value;
    uint result = 0;
    /* skip any leading 0x or 0X */
    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
  86:	80 3e 30             	cmpb   $0x30,(%esi)
  89:	74 09                	je     94 <hextoi+0x16>
    p = value;
  8b:	89 f1                	mov    %esi,%ecx
  8d:	b8 00 00 00 00       	mov    $0x0,%eax
  92:	eb 2f                	jmp    c3 <hextoi+0x45>
    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
  94:	0f b6 56 01          	movzbl 0x1(%esi),%edx
  98:	80 fa 78             	cmp    $0x78,%dl
  9b:	0f 94 c0             	sete   %al
  9e:	80 fa 58             	cmp    $0x58,%dl
  a1:	0f 94 c2             	sete   %dl
  a4:	08 d0                	or     %dl,%al
  a6:	74 05                	je     ad <hextoi+0x2f>
        p += 2;
  a8:	8d 4e 02             	lea    0x2(%esi),%ecx
  ab:	eb e0                	jmp    8d <hextoi+0xf>
    p = value;
  ad:	89 f1                	mov    %esi,%ecx
  af:	eb dc                	jmp    8d <hextoi+0xf>
        /* shift previous values over 4 */
        result = result << 4;
        /* add next chraacter */
        if (*p >= '0' && *p <= '9') {
            result += *p - '0';
        } else if (*p >= 'a' && *p <= 'f') {
  b1:	8d 5a 9f             	lea    -0x61(%edx),%ebx
  b4:	80 fb 05             	cmp    $0x5,%bl
  b7:	77 25                	ja     de <hextoi+0x60>
            result += (*p - 'a') + 10;
  b9:	0f be d2             	movsbl %dl,%edx
  bc:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
        } else {
            printf(2, "malformed hexadecimal number '%s'\n", value);
            return 0;
        }
        /* advance to next character */
        p += 1;
  c0:	83 c1 01             	add    $0x1,%ecx
    while (*p) {
  c3:	0f b6 11             	movzbl (%ecx),%edx
  c6:	84 d2                	test   %dl,%dl
  c8:	74 3d                	je     107 <hextoi+0x89>
        result = result << 4;
  ca:	c1 e0 04             	shl    $0x4,%eax
        if (*p >= '0' && *p <= '9') {
  cd:	8d 5a d0             	lea    -0x30(%edx),%ebx
  d0:	80 fb 09             	cmp    $0x9,%bl
  d3:	77 dc                	ja     b1 <hextoi+0x33>
            result += *p - '0';
  d5:	0f be d2             	movsbl %dl,%edx
  d8:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
  dc:	eb e2                	jmp    c0 <hextoi+0x42>
        } else if (*p >= 'A' && *p <= 'F') {
  de:	8d 5a bf             	lea    -0x41(%edx),%ebx
  e1:	80 fb 05             	cmp    $0x5,%bl
  e4:	77 09                	ja     ef <hextoi+0x71>
            result += (*p - 'A') + 10;
  e6:	0f be d2             	movsbl %dl,%edx
  e9:	8d 44 10 c9          	lea    -0x37(%eax,%edx,1),%eax
  ed:	eb d1                	jmp    c0 <hextoi+0x42>
            printf(2, "malformed hexadecimal number '%s'\n", value);
  ef:	83 ec 04             	sub    $0x4,%esp
  f2:	56                   	push   %esi
  f3:	68 78 08 00 00       	push   $0x878
  f8:	6a 02                	push   $0x2
  fa:	e8 57 04 00 00       	call   556 <printf>
            return 0;
  ff:	83 c4 10             	add    $0x10,%esp
 102:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    return result;
}
 107:	8d 65 f8             	lea    -0x8(%ebp),%esp
 10a:	5b                   	pop    %ebx
 10b:	5e                   	pop    %esi
 10c:	5d                   	pop    %ebp
 10d:	c3                   	ret    

0000010e <main>:

int main(int argc, char **argv) {
 10e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 112:	83 e4 f0             	and    $0xfffffff0,%esp
 115:	ff 71 fc             	push   -0x4(%ecx)
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	57                   	push   %edi
 11c:	56                   	push   %esi
 11d:	53                   	push   %ebx
 11e:	51                   	push   %ecx
 11f:	83 ec 08             	sub    $0x8,%esp
 122:	8b 31                	mov    (%ecx),%esi
 124:	8b 59 04             	mov    0x4(%ecx),%ebx
    if (argc < 2) {
 127:	83 fe 01             	cmp    $0x1,%esi
 12a:	7e 26                	jle    152 <main+0x44>
        usage(argv[0]);
    } else if (0 == strcmp(argv[1], "pte")) {
 12c:	83 ec 08             	sub    $0x8,%esp
 12f:	68 df 06 00 00       	push   $0x6df
 134:	ff 73 04             	push   0x4(%ebx)
 137:	e8 34 01 00 00       	call   270 <strcmp>
 13c:	83 c4 10             	add    $0x10,%esp
 13f:	85 c0                	test   %eax,%eax
 141:	75 6e                	jne    1b1 <main+0xa3>
        if (argc != 4) { usage(argv[0]); }
 143:	83 fe 04             	cmp    $0x4,%esi
 146:	74 14                	je     15c <main+0x4e>
 148:	83 ec 0c             	sub    $0xc,%esp
 14b:	ff 33                	push   (%ebx)
 14d:	e8 0b ff ff ff       	call   5d <usage>
        usage(argv[0]);
 152:	83 ec 0c             	sub    $0xc,%esp
 155:	ff 33                	push   (%ebx)
 157:	e8 01 ff ff ff       	call   5d <usage>
        int pid = atoi(argv[2]);
 15c:	83 ec 0c             	sub    $0xc,%esp
 15f:	ff 73 08             	push   0x8(%ebx)
 162:	e8 1e 02 00 00       	call   385 <atoi>
 167:	89 c6                	mov    %eax,%esi
        uint va = hextoi(argv[3]);
 169:	83 c4 04             	add    $0x4,%esp
 16c:	ff 73 0c             	push   0xc(%ebx)
 16f:	e8 0a ff ff ff       	call   7e <hextoi>
 174:	89 c7                	mov    %eax,%edi
        uint raw_pte = getpagetableentry(pid, va);
 176:	83 c4 08             	add    $0x8,%esp
 179:	50                   	push   %eax
 17a:	56                   	push   %esi
 17b:	e8 19 03 00 00       	call   499 <getpagetableentry>
 180:	89 c3                	mov    %eax,%ebx
        printf(1, "PID %d, last-level PTE for %x: ", pid, va);
 182:	57                   	push   %edi
 183:	56                   	push   %esi
 184:	68 9c 08 00 00       	push   $0x89c
 189:	6a 01                	push   $0x1
 18b:	e8 c6 03 00 00       	call   556 <printf>
        dump_pte(raw_pte);
 190:	83 c4 14             	add    $0x14,%esp
 193:	53                   	push   %ebx
 194:	e8 67 fe ff ff       	call   0 <dump_pte>
        printf(1, "(raw value 0x%x)\n", raw_pte);
 199:	83 c4 0c             	add    $0xc,%esp
 19c:	53                   	push   %ebx
 19d:	68 e3 06 00 00       	push   $0x6e3
 1a2:	6a 01                	push   $0x1
 1a4:	e8 ad 03 00 00       	call   556 <printf>
 1a9:	83 c4 10             	add    $0x10,%esp
        int ppn = hextoi(argv[2]);
        printf(1, "isphysicalpagefree(0x%x) = %d\n", ppn, isphysicalpagefree(ppn));
    } else {
        usage(argv[0]);
    }
    exit();
 1ac:	e8 38 02 00 00       	call   3e9 <exit>
    } else if (0 == strcmp(argv[1], "dump")) {
 1b1:	83 ec 08             	sub    $0x8,%esp
 1b4:	68 f5 06 00 00       	push   $0x6f5
 1b9:	ff 73 04             	push   0x4(%ebx)
 1bc:	e8 af 00 00 00       	call   270 <strcmp>
 1c1:	83 c4 10             	add    $0x10,%esp
 1c4:	85 c0                	test   %eax,%eax
 1c6:	75 27                	jne    1ef <main+0xe1>
        if (argc != 3) { usage(argv[0]); }
 1c8:	83 fe 03             	cmp    $0x3,%esi
 1cb:	74 0a                	je     1d7 <main+0xc9>
 1cd:	83 ec 0c             	sub    $0xc,%esp
 1d0:	ff 33                	push   (%ebx)
 1d2:	e8 86 fe ff ff       	call   5d <usage>
        int pid = atoi(argv[2]);
 1d7:	83 ec 0c             	sub    $0xc,%esp
 1da:	ff 73 08             	push   0x8(%ebx)
 1dd:	e8 a3 01 00 00       	call   385 <atoi>
        dumppagetable(pid);
 1e2:	89 04 24             	mov    %eax,(%esp)
 1e5:	e8 bf 02 00 00       	call   4a9 <dumppagetable>
 1ea:	83 c4 10             	add    $0x10,%esp
 1ed:	eb bd                	jmp    1ac <main+0x9e>
    } else if (0 == strcmp(argv[1], "isfree")) {
 1ef:	83 ec 08             	sub    $0x8,%esp
 1f2:	68 fa 06 00 00       	push   $0x6fa
 1f7:	ff 73 04             	push   0x4(%ebx)
 1fa:	e8 71 00 00 00       	call   270 <strcmp>
 1ff:	83 c4 10             	add    $0x10,%esp
 202:	85 c0                	test   %eax,%eax
 204:	75 3a                	jne    240 <main+0x132>
        if (argc != 3) { usage(argv[0]); }
 206:	83 fe 03             	cmp    $0x3,%esi
 209:	74 0a                	je     215 <main+0x107>
 20b:	83 ec 0c             	sub    $0xc,%esp
 20e:	ff 33                	push   (%ebx)
 210:	e8 48 fe ff ff       	call   5d <usage>
        int ppn = hextoi(argv[2]);
 215:	83 ec 0c             	sub    $0xc,%esp
 218:	ff 73 08             	push   0x8(%ebx)
 21b:	e8 5e fe ff ff       	call   7e <hextoi>
 220:	89 c3                	mov    %eax,%ebx
        printf(1, "isphysicalpagefree(0x%x) = %d\n", ppn, isphysicalpagefree(ppn));
 222:	89 04 24             	mov    %eax,(%esp)
 225:	e8 77 02 00 00       	call   4a1 <isphysicalpagefree>
 22a:	50                   	push   %eax
 22b:	53                   	push   %ebx
 22c:	68 bc 08 00 00       	push   $0x8bc
 231:	6a 01                	push   $0x1
 233:	e8 1e 03 00 00       	call   556 <printf>
 238:	83 c4 20             	add    $0x20,%esp
 23b:	e9 6c ff ff ff       	jmp    1ac <main+0x9e>
        usage(argv[0]);
 240:	83 ec 0c             	sub    $0xc,%esp
 243:	ff 33                	push   (%ebx)
 245:	e8 13 fe ff ff       	call   5d <usage>

0000024a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 24a:	55                   	push   %ebp
 24b:	89 e5                	mov    %esp,%ebp
 24d:	56                   	push   %esi
 24e:	53                   	push   %ebx
 24f:	8b 75 08             	mov    0x8(%ebp),%esi
 252:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 255:	89 f0                	mov    %esi,%eax
 257:	89 d1                	mov    %edx,%ecx
 259:	83 c2 01             	add    $0x1,%edx
 25c:	89 c3                	mov    %eax,%ebx
 25e:	83 c0 01             	add    $0x1,%eax
 261:	0f b6 09             	movzbl (%ecx),%ecx
 264:	88 0b                	mov    %cl,(%ebx)
 266:	84 c9                	test   %cl,%cl
 268:	75 ed                	jne    257 <strcpy+0xd>
    ;
  return os;
}
 26a:	89 f0                	mov    %esi,%eax
 26c:	5b                   	pop    %ebx
 26d:	5e                   	pop    %esi
 26e:	5d                   	pop    %ebp
 26f:	c3                   	ret    

00000270 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 270:	55                   	push   %ebp
 271:	89 e5                	mov    %esp,%ebp
 273:	8b 4d 08             	mov    0x8(%ebp),%ecx
 276:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 279:	eb 06                	jmp    281 <strcmp+0x11>
    p++, q++;
 27b:	83 c1 01             	add    $0x1,%ecx
 27e:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 281:	0f b6 01             	movzbl (%ecx),%eax
 284:	84 c0                	test   %al,%al
 286:	74 04                	je     28c <strcmp+0x1c>
 288:	3a 02                	cmp    (%edx),%al
 28a:	74 ef                	je     27b <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 28c:	0f b6 c0             	movzbl %al,%eax
 28f:	0f b6 12             	movzbl (%edx),%edx
 292:	29 d0                	sub    %edx,%eax
}
 294:	5d                   	pop    %ebp
 295:	c3                   	ret    

00000296 <strlen>:

uint
strlen(const char *s)
{
 296:	55                   	push   %ebp
 297:	89 e5                	mov    %esp,%ebp
 299:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 29c:	b8 00 00 00 00       	mov    $0x0,%eax
 2a1:	eb 03                	jmp    2a6 <strlen+0x10>
 2a3:	83 c0 01             	add    $0x1,%eax
 2a6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
 2aa:	75 f7                	jne    2a3 <strlen+0xd>
    ;
  return n;
}
 2ac:	5d                   	pop    %ebp
 2ad:	c3                   	ret    

000002ae <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ae:	55                   	push   %ebp
 2af:	89 e5                	mov    %esp,%ebp
 2b1:	57                   	push   %edi
 2b2:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 2b5:	89 d7                	mov    %edx,%edi
 2b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bd:	fc                   	cld    
 2be:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 2c0:	89 d0                	mov    %edx,%eax
 2c2:	8b 7d fc             	mov    -0x4(%ebp),%edi
 2c5:	c9                   	leave  
 2c6:	c3                   	ret    

000002c7 <strchr>:

char*
strchr(const char *s, char c)
{
 2c7:	55                   	push   %ebp
 2c8:	89 e5                	mov    %esp,%ebp
 2ca:	8b 45 08             	mov    0x8(%ebp),%eax
 2cd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 2d1:	eb 03                	jmp    2d6 <strchr+0xf>
 2d3:	83 c0 01             	add    $0x1,%eax
 2d6:	0f b6 10             	movzbl (%eax),%edx
 2d9:	84 d2                	test   %dl,%dl
 2db:	74 06                	je     2e3 <strchr+0x1c>
    if(*s == c)
 2dd:	38 ca                	cmp    %cl,%dl
 2df:	75 f2                	jne    2d3 <strchr+0xc>
 2e1:	eb 05                	jmp    2e8 <strchr+0x21>
      return (char*)s;
  return 0;
 2e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2e8:	5d                   	pop    %ebp
 2e9:	c3                   	ret    

000002ea <gets>:

char*
gets(char *buf, int max)
{
 2ea:	55                   	push   %ebp
 2eb:	89 e5                	mov    %esp,%ebp
 2ed:	57                   	push   %edi
 2ee:	56                   	push   %esi
 2ef:	53                   	push   %ebx
 2f0:	83 ec 1c             	sub    $0x1c,%esp
 2f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2f6:	bb 00 00 00 00       	mov    $0x0,%ebx
 2fb:	89 de                	mov    %ebx,%esi
 2fd:	83 c3 01             	add    $0x1,%ebx
 300:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 303:	7d 2e                	jge    333 <gets+0x49>
    cc = read(0, &c, 1);
 305:	83 ec 04             	sub    $0x4,%esp
 308:	6a 01                	push   $0x1
 30a:	8d 45 e7             	lea    -0x19(%ebp),%eax
 30d:	50                   	push   %eax
 30e:	6a 00                	push   $0x0
 310:	e8 ec 00 00 00       	call   401 <read>
    if(cc < 1)
 315:	83 c4 10             	add    $0x10,%esp
 318:	85 c0                	test   %eax,%eax
 31a:	7e 17                	jle    333 <gets+0x49>
      break;
    buf[i++] = c;
 31c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 320:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
 323:	3c 0a                	cmp    $0xa,%al
 325:	0f 94 c2             	sete   %dl
 328:	3c 0d                	cmp    $0xd,%al
 32a:	0f 94 c0             	sete   %al
 32d:	08 c2                	or     %al,%dl
 32f:	74 ca                	je     2fb <gets+0x11>
    buf[i++] = c;
 331:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 333:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 337:	89 f8                	mov    %edi,%eax
 339:	8d 65 f4             	lea    -0xc(%ebp),%esp
 33c:	5b                   	pop    %ebx
 33d:	5e                   	pop    %esi
 33e:	5f                   	pop    %edi
 33f:	5d                   	pop    %ebp
 340:	c3                   	ret    

00000341 <stat>:

int
stat(const char *n, struct stat *st)
{
 341:	55                   	push   %ebp
 342:	89 e5                	mov    %esp,%ebp
 344:	56                   	push   %esi
 345:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 346:	83 ec 08             	sub    $0x8,%esp
 349:	6a 00                	push   $0x0
 34b:	ff 75 08             	push   0x8(%ebp)
 34e:	e8 d6 00 00 00       	call   429 <open>
  if(fd < 0)
 353:	83 c4 10             	add    $0x10,%esp
 356:	85 c0                	test   %eax,%eax
 358:	78 24                	js     37e <stat+0x3d>
 35a:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 35c:	83 ec 08             	sub    $0x8,%esp
 35f:	ff 75 0c             	push   0xc(%ebp)
 362:	50                   	push   %eax
 363:	e8 d9 00 00 00       	call   441 <fstat>
 368:	89 c6                	mov    %eax,%esi
  close(fd);
 36a:	89 1c 24             	mov    %ebx,(%esp)
 36d:	e8 9f 00 00 00       	call   411 <close>
  return r;
 372:	83 c4 10             	add    $0x10,%esp
}
 375:	89 f0                	mov    %esi,%eax
 377:	8d 65 f8             	lea    -0x8(%ebp),%esp
 37a:	5b                   	pop    %ebx
 37b:	5e                   	pop    %esi
 37c:	5d                   	pop    %ebp
 37d:	c3                   	ret    
    return -1;
 37e:	be ff ff ff ff       	mov    $0xffffffff,%esi
 383:	eb f0                	jmp    375 <stat+0x34>

00000385 <atoi>:

int
atoi(const char *s)
{
 385:	55                   	push   %ebp
 386:	89 e5                	mov    %esp,%ebp
 388:	53                   	push   %ebx
 389:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 38c:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 391:	eb 10                	jmp    3a3 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 393:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
 396:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
 399:	83 c1 01             	add    $0x1,%ecx
 39c:	0f be c0             	movsbl %al,%eax
 39f:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
  while('0' <= *s && *s <= '9')
 3a3:	0f b6 01             	movzbl (%ecx),%eax
 3a6:	8d 58 d0             	lea    -0x30(%eax),%ebx
 3a9:	80 fb 09             	cmp    $0x9,%bl
 3ac:	76 e5                	jbe    393 <atoi+0xe>
  return n;
}
 3ae:	89 d0                	mov    %edx,%eax
 3b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 3b3:	c9                   	leave  
 3b4:	c3                   	ret    

000003b5 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b5:	55                   	push   %ebp
 3b6:	89 e5                	mov    %esp,%ebp
 3b8:	56                   	push   %esi
 3b9:	53                   	push   %ebx
 3ba:	8b 75 08             	mov    0x8(%ebp),%esi
 3bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 3c0:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
 3c3:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
 3c5:	eb 0d                	jmp    3d4 <memmove+0x1f>
    *dst++ = *src++;
 3c7:	0f b6 01             	movzbl (%ecx),%eax
 3ca:	88 02                	mov    %al,(%edx)
 3cc:	8d 49 01             	lea    0x1(%ecx),%ecx
 3cf:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
 3d2:	89 d8                	mov    %ebx,%eax
 3d4:	8d 58 ff             	lea    -0x1(%eax),%ebx
 3d7:	85 c0                	test   %eax,%eax
 3d9:	7f ec                	jg     3c7 <memmove+0x12>
  return vdst;
}
 3db:	89 f0                	mov    %esi,%eax
 3dd:	5b                   	pop    %ebx
 3de:	5e                   	pop    %esi
 3df:	5d                   	pop    %ebp
 3e0:	c3                   	ret    

000003e1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3e1:	b8 01 00 00 00       	mov    $0x1,%eax
 3e6:	cd 40                	int    $0x40
 3e8:	c3                   	ret    

000003e9 <exit>:
SYSCALL(exit)
 3e9:	b8 02 00 00 00       	mov    $0x2,%eax
 3ee:	cd 40                	int    $0x40
 3f0:	c3                   	ret    

000003f1 <wait>:
SYSCALL(wait)
 3f1:	b8 03 00 00 00       	mov    $0x3,%eax
 3f6:	cd 40                	int    $0x40
 3f8:	c3                   	ret    

000003f9 <pipe>:
SYSCALL(pipe)
 3f9:	b8 04 00 00 00       	mov    $0x4,%eax
 3fe:	cd 40                	int    $0x40
 400:	c3                   	ret    

00000401 <read>:
SYSCALL(read)
 401:	b8 05 00 00 00       	mov    $0x5,%eax
 406:	cd 40                	int    $0x40
 408:	c3                   	ret    

00000409 <write>:
SYSCALL(write)
 409:	b8 10 00 00 00       	mov    $0x10,%eax
 40e:	cd 40                	int    $0x40
 410:	c3                   	ret    

00000411 <close>:
SYSCALL(close)
 411:	b8 15 00 00 00       	mov    $0x15,%eax
 416:	cd 40                	int    $0x40
 418:	c3                   	ret    

00000419 <kill>:
SYSCALL(kill)
 419:	b8 06 00 00 00       	mov    $0x6,%eax
 41e:	cd 40                	int    $0x40
 420:	c3                   	ret    

00000421 <exec>:
SYSCALL(exec)
 421:	b8 07 00 00 00       	mov    $0x7,%eax
 426:	cd 40                	int    $0x40
 428:	c3                   	ret    

00000429 <open>:
SYSCALL(open)
 429:	b8 0f 00 00 00       	mov    $0xf,%eax
 42e:	cd 40                	int    $0x40
 430:	c3                   	ret    

00000431 <mknod>:
SYSCALL(mknod)
 431:	b8 11 00 00 00       	mov    $0x11,%eax
 436:	cd 40                	int    $0x40
 438:	c3                   	ret    

00000439 <unlink>:
SYSCALL(unlink)
 439:	b8 12 00 00 00       	mov    $0x12,%eax
 43e:	cd 40                	int    $0x40
 440:	c3                   	ret    

00000441 <fstat>:
SYSCALL(fstat)
 441:	b8 08 00 00 00       	mov    $0x8,%eax
 446:	cd 40                	int    $0x40
 448:	c3                   	ret    

00000449 <link>:
SYSCALL(link)
 449:	b8 13 00 00 00       	mov    $0x13,%eax
 44e:	cd 40                	int    $0x40
 450:	c3                   	ret    

00000451 <mkdir>:
SYSCALL(mkdir)
 451:	b8 14 00 00 00       	mov    $0x14,%eax
 456:	cd 40                	int    $0x40
 458:	c3                   	ret    

00000459 <chdir>:
SYSCALL(chdir)
 459:	b8 09 00 00 00       	mov    $0x9,%eax
 45e:	cd 40                	int    $0x40
 460:	c3                   	ret    

00000461 <dup>:
SYSCALL(dup)
 461:	b8 0a 00 00 00       	mov    $0xa,%eax
 466:	cd 40                	int    $0x40
 468:	c3                   	ret    

00000469 <getpid>:
SYSCALL(getpid)
 469:	b8 0b 00 00 00       	mov    $0xb,%eax
 46e:	cd 40                	int    $0x40
 470:	c3                   	ret    

00000471 <sbrk>:
SYSCALL(sbrk)
 471:	b8 0c 00 00 00       	mov    $0xc,%eax
 476:	cd 40                	int    $0x40
 478:	c3                   	ret    

00000479 <sleep>:
SYSCALL(sleep)
 479:	b8 0d 00 00 00       	mov    $0xd,%eax
 47e:	cd 40                	int    $0x40
 480:	c3                   	ret    

00000481 <uptime>:
SYSCALL(uptime)
 481:	b8 0e 00 00 00       	mov    $0xe,%eax
 486:	cd 40                	int    $0x40
 488:	c3                   	ret    

00000489 <yield>:
SYSCALL(yield)
 489:	b8 16 00 00 00       	mov    $0x16,%eax
 48e:	cd 40                	int    $0x40
 490:	c3                   	ret    

00000491 <shutdown>:
SYSCALL(shutdown)
 491:	b8 17 00 00 00       	mov    $0x17,%eax
 496:	cd 40                	int    $0x40
 498:	c3                   	ret    

00000499 <getpagetableentry>:
SYSCALL(getpagetableentry)
 499:	b8 18 00 00 00       	mov    $0x18,%eax
 49e:	cd 40                	int    $0x40
 4a0:	c3                   	ret    

000004a1 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 4a1:	b8 19 00 00 00       	mov    $0x19,%eax
 4a6:	cd 40                	int    $0x40
 4a8:	c3                   	ret    

000004a9 <dumppagetable>:
 4a9:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ae:	cd 40                	int    $0x40
 4b0:	c3                   	ret    

000004b1 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4b1:	55                   	push   %ebp
 4b2:	89 e5                	mov    %esp,%ebp
 4b4:	83 ec 1c             	sub    $0x1c,%esp
 4b7:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 4ba:	6a 01                	push   $0x1
 4bc:	8d 55 f4             	lea    -0xc(%ebp),%edx
 4bf:	52                   	push   %edx
 4c0:	50                   	push   %eax
 4c1:	e8 43 ff ff ff       	call   409 <write>
}
 4c6:	83 c4 10             	add    $0x10,%esp
 4c9:	c9                   	leave  
 4ca:	c3                   	ret    

000004cb <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4cb:	55                   	push   %ebp
 4cc:	89 e5                	mov    %esp,%ebp
 4ce:	57                   	push   %edi
 4cf:	56                   	push   %esi
 4d0:	53                   	push   %ebx
 4d1:	83 ec 2c             	sub    $0x2c,%esp
 4d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
 4d7:	89 d0                	mov    %edx,%eax
 4d9:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 4df:	0f 95 c1             	setne  %cl
 4e2:	c1 ea 1f             	shr    $0x1f,%edx
 4e5:	84 d1                	test   %dl,%cl
 4e7:	74 44                	je     52d <printint+0x62>
    neg = 1;
    x = -xx;
 4e9:	f7 d8                	neg    %eax
 4eb:	89 c1                	mov    %eax,%ecx
    neg = 1;
 4ed:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 4f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 4f9:	89 c8                	mov    %ecx,%eax
 4fb:	ba 00 00 00 00       	mov    $0x0,%edx
 500:	f7 f6                	div    %esi
 502:	89 df                	mov    %ebx,%edi
 504:	83 c3 01             	add    $0x1,%ebx
 507:	0f b6 92 3c 09 00 00 	movzbl 0x93c(%edx),%edx
 50e:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 512:	89 ca                	mov    %ecx,%edx
 514:	89 c1                	mov    %eax,%ecx
 516:	39 d6                	cmp    %edx,%esi
 518:	76 df                	jbe    4f9 <printint+0x2e>
  if(neg)
 51a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 51e:	74 31                	je     551 <printint+0x86>
    buf[i++] = '-';
 520:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 525:	8d 5f 02             	lea    0x2(%edi),%ebx
 528:	8b 75 d0             	mov    -0x30(%ebp),%esi
 52b:	eb 17                	jmp    544 <printint+0x79>
    x = xx;
 52d:	89 c1                	mov    %eax,%ecx
  neg = 0;
 52f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 536:	eb bc                	jmp    4f4 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 538:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 53d:	89 f0                	mov    %esi,%eax
 53f:	e8 6d ff ff ff       	call   4b1 <putc>
  while(--i >= 0)
 544:	83 eb 01             	sub    $0x1,%ebx
 547:	79 ef                	jns    538 <printint+0x6d>
}
 549:	83 c4 2c             	add    $0x2c,%esp
 54c:	5b                   	pop    %ebx
 54d:	5e                   	pop    %esi
 54e:	5f                   	pop    %edi
 54f:	5d                   	pop    %ebp
 550:	c3                   	ret    
 551:	8b 75 d0             	mov    -0x30(%ebp),%esi
 554:	eb ee                	jmp    544 <printint+0x79>

00000556 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 556:	55                   	push   %ebp
 557:	89 e5                	mov    %esp,%ebp
 559:	57                   	push   %edi
 55a:	56                   	push   %esi
 55b:	53                   	push   %ebx
 55c:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 55f:	8d 45 10             	lea    0x10(%ebp),%eax
 562:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 565:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 56a:	bb 00 00 00 00       	mov    $0x0,%ebx
 56f:	eb 14                	jmp    585 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 571:	89 fa                	mov    %edi,%edx
 573:	8b 45 08             	mov    0x8(%ebp),%eax
 576:	e8 36 ff ff ff       	call   4b1 <putc>
 57b:	eb 05                	jmp    582 <printf+0x2c>
      }
    } else if(state == '%'){
 57d:	83 fe 25             	cmp    $0x25,%esi
 580:	74 25                	je     5a7 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 582:	83 c3 01             	add    $0x1,%ebx
 585:	8b 45 0c             	mov    0xc(%ebp),%eax
 588:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 58c:	84 c0                	test   %al,%al
 58e:	0f 84 20 01 00 00    	je     6b4 <printf+0x15e>
    c = fmt[i] & 0xff;
 594:	0f be f8             	movsbl %al,%edi
 597:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 59a:	85 f6                	test   %esi,%esi
 59c:	75 df                	jne    57d <printf+0x27>
      if(c == '%'){
 59e:	83 f8 25             	cmp    $0x25,%eax
 5a1:	75 ce                	jne    571 <printf+0x1b>
        state = '%';
 5a3:	89 c6                	mov    %eax,%esi
 5a5:	eb db                	jmp    582 <printf+0x2c>
      if(c == 'd'){
 5a7:	83 f8 25             	cmp    $0x25,%eax
 5aa:	0f 84 cf 00 00 00    	je     67f <printf+0x129>
 5b0:	0f 8c dd 00 00 00    	jl     693 <printf+0x13d>
 5b6:	83 f8 78             	cmp    $0x78,%eax
 5b9:	0f 8f d4 00 00 00    	jg     693 <printf+0x13d>
 5bf:	83 f8 63             	cmp    $0x63,%eax
 5c2:	0f 8c cb 00 00 00    	jl     693 <printf+0x13d>
 5c8:	83 e8 63             	sub    $0x63,%eax
 5cb:	83 f8 15             	cmp    $0x15,%eax
 5ce:	0f 87 bf 00 00 00    	ja     693 <printf+0x13d>
 5d4:	ff 24 85 e4 08 00 00 	jmp    *0x8e4(,%eax,4)
        printint(fd, *ap, 10, 1);
 5db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5de:	8b 17                	mov    (%edi),%edx
 5e0:	83 ec 0c             	sub    $0xc,%esp
 5e3:	6a 01                	push   $0x1
 5e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
 5ea:	8b 45 08             	mov    0x8(%ebp),%eax
 5ed:	e8 d9 fe ff ff       	call   4cb <printint>
        ap++;
 5f2:	83 c7 04             	add    $0x4,%edi
 5f5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5f8:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5fb:	be 00 00 00 00       	mov    $0x0,%esi
 600:	eb 80                	jmp    582 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 602:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 605:	8b 17                	mov    (%edi),%edx
 607:	83 ec 0c             	sub    $0xc,%esp
 60a:	6a 00                	push   $0x0
 60c:	b9 10 00 00 00       	mov    $0x10,%ecx
 611:	8b 45 08             	mov    0x8(%ebp),%eax
 614:	e8 b2 fe ff ff       	call   4cb <printint>
        ap++;
 619:	83 c7 04             	add    $0x4,%edi
 61c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 61f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 622:	be 00 00 00 00       	mov    $0x0,%esi
 627:	e9 56 ff ff ff       	jmp    582 <printf+0x2c>
        s = (char*)*ap;
 62c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 62f:	8b 30                	mov    (%eax),%esi
        ap++;
 631:	83 c0 04             	add    $0x4,%eax
 634:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 637:	85 f6                	test   %esi,%esi
 639:	75 15                	jne    650 <printf+0xfa>
          s = "(null)";
 63b:	be db 08 00 00       	mov    $0x8db,%esi
 640:	eb 0e                	jmp    650 <printf+0xfa>
          putc(fd, *s);
 642:	0f be d2             	movsbl %dl,%edx
 645:	8b 45 08             	mov    0x8(%ebp),%eax
 648:	e8 64 fe ff ff       	call   4b1 <putc>
          s++;
 64d:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 650:	0f b6 16             	movzbl (%esi),%edx
 653:	84 d2                	test   %dl,%dl
 655:	75 eb                	jne    642 <printf+0xec>
      state = 0;
 657:	be 00 00 00 00       	mov    $0x0,%esi
 65c:	e9 21 ff ff ff       	jmp    582 <printf+0x2c>
        putc(fd, *ap);
 661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 664:	0f be 17             	movsbl (%edi),%edx
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	e8 42 fe ff ff       	call   4b1 <putc>
        ap++;
 66f:	83 c7 04             	add    $0x4,%edi
 672:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 675:	be 00 00 00 00       	mov    $0x0,%esi
 67a:	e9 03 ff ff ff       	jmp    582 <printf+0x2c>
        putc(fd, c);
 67f:	89 fa                	mov    %edi,%edx
 681:	8b 45 08             	mov    0x8(%ebp),%eax
 684:	e8 28 fe ff ff       	call   4b1 <putc>
      state = 0;
 689:	be 00 00 00 00       	mov    $0x0,%esi
 68e:	e9 ef fe ff ff       	jmp    582 <printf+0x2c>
        putc(fd, '%');
 693:	ba 25 00 00 00       	mov    $0x25,%edx
 698:	8b 45 08             	mov    0x8(%ebp),%eax
 69b:	e8 11 fe ff ff       	call   4b1 <putc>
        putc(fd, c);
 6a0:	89 fa                	mov    %edi,%edx
 6a2:	8b 45 08             	mov    0x8(%ebp),%eax
 6a5:	e8 07 fe ff ff       	call   4b1 <putc>
      state = 0;
 6aa:	be 00 00 00 00       	mov    $0x0,%esi
 6af:	e9 ce fe ff ff       	jmp    582 <printf+0x2c>
    }
  }
}
 6b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
 6b7:	5b                   	pop    %ebx
 6b8:	5e                   	pop    %esi
 6b9:	5f                   	pop    %edi
 6ba:	5d                   	pop    %ebp
 6bb:	c3                   	ret    
