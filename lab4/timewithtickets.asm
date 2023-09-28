
_timewithtickets:     file format elf32-i386


Disassembly of section .text:

00000000 <yield_forever>:
#define MAX_CHILDREN 32
#define LARGE_TICKET_COUNT 100000
#define MAX_YIELDS_FOR_SETUP 100

__attribute__((noreturn))
void yield_forever() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        yield();
   6:	e8 53 06 00 00       	call   65e <yield>
    while (1) {
   b:	eb f9                	jmp    6 <yield_forever+0x6>

0000000d <run_forever>:
    }
}

__attribute__((noreturn))
void run_forever() {
    while (1) {
   d:	eb fe                	jmp    d <run_forever>

0000000f <spawn>:
        __asm__("");
    }
}

int spawn(int tickets) {
   f:	55                   	push   %ebp
  10:	89 e5                	mov    %esp,%ebp
  12:	53                   	push   %ebx
  13:	83 ec 04             	sub    $0x4,%esp
    int pid = fork();
  16:	e8 9b 05 00 00       	call   5b6 <fork>
    if (pid == 0) {
  1b:	85 c0                	test   %eax,%eax
  1d:	74 0e                	je     2d <spawn+0x1e>
  1f:	89 c3                	mov    %eax,%ebx
#ifdef USE_YIELD
        yield_forever();
#else
        run_forever();
#endif
    } else if (pid != -1) {
  21:	83 f8 ff             	cmp    $0xffffffff,%eax
  24:	74 1c                	je     42 <spawn+0x33>
        return pid;
    } else {
        printf(2, "error in fork\n");
        return -1;
    }
}
  26:	89 d8                	mov    %ebx,%eax
  28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  2b:	c9                   	leave  
  2c:	c3                   	ret    
        settickets(tickets);
  2d:	83 ec 0c             	sub    $0xc,%esp
  30:	ff 75 08             	push   0x8(%ebp)
  33:	e8 46 06 00 00       	call   67e <settickets>
        yield();
  38:	e8 21 06 00 00       	call   65e <yield>
        run_forever();
  3d:	e8 cb ff ff ff       	call   d <run_forever>
        printf(2, "error in fork\n");
  42:	83 ec 08             	sub    $0x8,%esp
  45:	68 9c 08 00 00       	push   $0x89c
  4a:	6a 02                	push   $0x2
  4c:	e8 e2 06 00 00       	call   733 <printf>
        return -1;
  51:	83 c4 10             	add    $0x10,%esp
  54:	eb d0                	jmp    26 <spawn+0x17>

00000056 <find_index_of_pid>:

int find_index_of_pid(int *list, int list_size, int pid) {
  56:	55                   	push   %ebp
  57:	89 e5                	mov    %esp,%ebp
  59:	53                   	push   %ebx
  5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  60:	8b 4d 10             	mov    0x10(%ebp),%ecx
    for (int i = 0; i < list_size; ++i) {
  63:	b8 00 00 00 00       	mov    $0x0,%eax
  68:	eb 03                	jmp    6d <find_index_of_pid+0x17>
  6a:	83 c0 01             	add    $0x1,%eax
  6d:	39 d0                	cmp    %edx,%eax
  6f:	7d 07                	jge    78 <find_index_of_pid+0x22>
        if (list[i] == pid)
  71:	39 0c 83             	cmp    %ecx,(%ebx,%eax,4)
  74:	75 f4                	jne    6a <find_index_of_pid+0x14>
  76:	eb 05                	jmp    7d <find_index_of_pid+0x27>
            return i;
    }
    return -1;
  78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80:	c9                   	leave  
  81:	c3                   	ret    

00000082 <wait_for_ticket_counts>:

void wait_for_ticket_counts(int num_children, int *pids, int *tickets) {
  82:	55                   	push   %ebp
  83:	89 e5                	mov    %esp,%ebp
  85:	57                   	push   %edi
  86:	56                   	push   %esi
  87:	53                   	push   %ebx
  88:	81 ec 2c 03 00 00    	sub    $0x32c,%esp
  8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  91:	8b 7d 10             	mov    0x10(%ebp),%edi
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
  94:	c7 85 d0 fc ff ff 00 	movl   $0x0,-0x330(%ebp)
  9b:	00 00 00 
  9e:	83 bd d0 fc ff ff 63 	cmpl   $0x63,-0x330(%ebp)
  a5:	7f 6c                	jg     113 <wait_for_ticket_counts+0x91>
        yield();
  a7:	e8 b2 05 00 00       	call   65e <yield>
        int done = 1;
        struct processes_info info;
        getprocessesinfo(&info);
  ac:	83 ec 0c             	sub    $0xc,%esp
  af:	8d 85 e4 fc ff ff    	lea    -0x31c(%ebp),%eax
  b5:	50                   	push   %eax
  b6:	e8 cb 05 00 00       	call   686 <getprocessesinfo>
        for (int i = 0; i < num_children; ++i) {
  bb:	83 c4 10             	add    $0x10,%esp
  be:	bb 00 00 00 00       	mov    $0x0,%ebx
        int done = 1;
  c3:	c7 85 d4 fc ff ff 01 	movl   $0x1,-0x32c(%ebp)
  ca:	00 00 00 
        for (int i = 0; i < num_children; ++i) {
  cd:	eb 03                	jmp    d2 <wait_for_ticket_counts+0x50>
  cf:	83 c3 01             	add    $0x1,%ebx
  d2:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  d5:	7d 33                	jge    10a <wait_for_ticket_counts+0x88>
            int index = find_index_of_pid(info.pids, info.num_processes, pids[i]);
  d7:	83 ec 04             	sub    $0x4,%esp
  da:	ff 34 9e             	push   (%esi,%ebx,4)
  dd:	ff b5 e4 fc ff ff    	push   -0x31c(%ebp)
  e3:	8d 85 e8 fc ff ff    	lea    -0x318(%ebp),%eax
  e9:	50                   	push   %eax
  ea:	e8 67 ff ff ff       	call   56 <find_index_of_pid>
  ef:	83 c4 10             	add    $0x10,%esp
            if (info.tickets[index] != tickets[i]) done = 0;
  f2:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
  f5:	39 94 85 e8 fe ff ff 	cmp    %edx,-0x118(%ebp,%eax,4)
  fc:	74 d1                	je     cf <wait_for_ticket_counts+0x4d>
  fe:	c7 85 d4 fc ff ff 00 	movl   $0x0,-0x32c(%ebp)
 105:	00 00 00 
 108:	eb c5                	jmp    cf <wait_for_ticket_counts+0x4d>
        }
        if (done)
 10a:	83 bd d4 fc ff ff 00 	cmpl   $0x0,-0x32c(%ebp)
 111:	74 08                	je     11b <wait_for_ticket_counts+0x99>
            break;
    }
}
 113:	8d 65 f4             	lea    -0xc(%ebp),%esp
 116:	5b                   	pop    %ebx
 117:	5e                   	pop    %esi
 118:	5f                   	pop    %edi
 119:	5d                   	pop    %ebp
 11a:	c3                   	ret    
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
 11b:	83 85 d0 fc ff ff 01 	addl   $0x1,-0x330(%ebp)
 122:	e9 77 ff ff ff       	jmp    9e <wait_for_ticket_counts+0x1c>

00000127 <main>:

int main(int argc, char *argv[])
{
 127:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 12b:	83 e4 f0             	and    $0xfffffff0,%esp
 12e:	ff 71 fc             	push   -0x4(%ecx)
 131:	55                   	push   %ebp
 132:	89 e5                	mov    %esp,%ebp
 134:	57                   	push   %edi
 135:	56                   	push   %esi
 136:	53                   	push   %ebx
 137:	51                   	push   %ecx
 138:	81 ec 28 07 00 00    	sub    $0x728,%esp
 13e:	8b 31                	mov    (%ecx),%esi
 140:	8b 79 04             	mov    0x4(%ecx),%edi
    if (argc < 3) {
 143:	83 fe 02             	cmp    $0x2,%esi
 146:	7e 33                	jle    17b <main+0x54>
                  argv[0]);
        exit();
    }
    int tickets_for[MAX_CHILDREN];
    int active_pids[MAX_CHILDREN];
    int num_seconds = atoi(argv[1]);
 148:	83 ec 0c             	sub    $0xc,%esp
 14b:	ff 77 04             	push   0x4(%edi)
 14e:	e8 07 04 00 00       	call   55a <atoi>
 153:	89 85 d4 f8 ff ff    	mov    %eax,-0x72c(%ebp)
    int num_children = argc - 2;
 159:	83 ee 02             	sub    $0x2,%esi
    if (num_children > MAX_CHILDREN) {
 15c:	83 c4 10             	add    $0x10,%esp
 15f:	83 fe 20             	cmp    $0x20,%esi
 162:	7f 2d                	jg     191 <main+0x6a>
        printf(2, "only up to %d supported\n", MAX_CHILDREN);
        exit();
    }
    /* give us a lot of ticket so we don't get starved */
    settickets(LARGE_TICKET_COUNT);
 164:	83 ec 0c             	sub    $0xc,%esp
 167:	68 a0 86 01 00       	push   $0x186a0
 16c:	e8 0d 05 00 00       	call   67e <settickets>
    for (int i = 0; i < num_children; ++i) {
 171:	83 c4 10             	add    $0x10,%esp
 174:	bb 00 00 00 00       	mov    $0x0,%ebx
 179:	eb 54                	jmp    1cf <main+0xa8>
        printf(2, "usage: %s seconds tickets1 tickets2 ... ticketsN\n"
 17b:	83 ec 04             	sub    $0x4,%esp
 17e:	ff 37                	push   (%edi)
 180:	68 f4 08 00 00       	push   $0x8f4
 185:	6a 02                	push   $0x2
 187:	e8 a7 05 00 00       	call   733 <printf>
        exit();
 18c:	e8 2d 04 00 00       	call   5be <exit>
        printf(2, "only up to %d supported\n", MAX_CHILDREN);
 191:	83 ec 04             	sub    $0x4,%esp
 194:	6a 20                	push   $0x20
 196:	68 ab 08 00 00       	push   $0x8ab
 19b:	6a 02                	push   $0x2
 19d:	e8 91 05 00 00       	call   733 <printf>
        exit();
 1a2:	e8 17 04 00 00       	call   5be <exit>
        int tickets = atoi(argv[i + 2]);
 1a7:	83 ec 0c             	sub    $0xc,%esp
 1aa:	ff 74 9f 08          	push   0x8(%edi,%ebx,4)
 1ae:	e8 a7 03 00 00       	call   55a <atoi>
        tickets_for[i] = tickets;
 1b3:	89 84 9d 68 ff ff ff 	mov    %eax,-0x98(%ebp,%ebx,4)
        active_pids[i] = spawn(tickets);
 1ba:	89 04 24             	mov    %eax,(%esp)
 1bd:	e8 4d fe ff ff       	call   f <spawn>
 1c2:	89 84 9d e8 fe ff ff 	mov    %eax,-0x118(%ebp,%ebx,4)
    for (int i = 0; i < num_children; ++i) {
 1c9:	83 c3 01             	add    $0x1,%ebx
 1cc:	83 c4 10             	add    $0x10,%esp
 1cf:	39 f3                	cmp    %esi,%ebx
 1d1:	7c d4                	jl     1a7 <main+0x80>
    }
    wait_for_ticket_counts(num_children, active_pids, tickets_for);
 1d3:	83 ec 04             	sub    $0x4,%esp
 1d6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
 1dc:	50                   	push   %eax
 1dd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
 1e3:	50                   	push   %eax
 1e4:	56                   	push   %esi
 1e5:	e8 98 fe ff ff       	call   82 <wait_for_ticket_counts>
    struct processes_info before, after;
    before.num_processes = after.num_processes = -1;
 1ea:	c7 85 e0 f8 ff ff ff 	movl   $0xffffffff,-0x720(%ebp)
 1f1:	ff ff ff 
 1f4:	c7 85 e4 fb ff ff ff 	movl   $0xffffffff,-0x41c(%ebp)
 1fb:	ff ff ff 
    getprocessesinfo(&before);
 1fe:	8d 85 e4 fb ff ff    	lea    -0x41c(%ebp),%eax
 204:	89 04 24             	mov    %eax,(%esp)
 207:	e8 7a 04 00 00       	call   686 <getprocessesinfo>
    sleep(num_seconds);
 20c:	83 c4 04             	add    $0x4,%esp
 20f:	ff b5 d4 f8 ff ff    	push   -0x72c(%ebp)
 215:	e8 34 04 00 00       	call   64e <sleep>
    getprocessesinfo(&after);
 21a:	8d 85 e0 f8 ff ff    	lea    -0x720(%ebp),%eax
 220:	89 04 24             	mov    %eax,(%esp)
 223:	e8 5e 04 00 00       	call   686 <getprocessesinfo>
    for (int i = 0; i < num_children; ++i) {
 228:	83 c4 10             	add    $0x10,%esp
 22b:	bb 00 00 00 00       	mov    $0x0,%ebx
 230:	eb 15                	jmp    247 <main+0x120>
        kill(active_pids[i]);
 232:	83 ec 0c             	sub    $0xc,%esp
 235:	ff b4 9d e8 fe ff ff 	push   -0x118(%ebp,%ebx,4)
 23c:	e8 ad 03 00 00       	call   5ee <kill>
    for (int i = 0; i < num_children; ++i) {
 241:	83 c3 01             	add    $0x1,%ebx
 244:	83 c4 10             	add    $0x10,%esp
 247:	39 f3                	cmp    %esi,%ebx
 249:	7c e7                	jl     232 <main+0x10b>
    }
    for (int i = 0; i < num_children; ++i) {
 24b:	bb 00 00 00 00       	mov    $0x0,%ebx
 250:	eb 08                	jmp    25a <main+0x133>
        wait();
 252:	e8 6f 03 00 00       	call   5c6 <wait>
    for (int i = 0; i < num_children; ++i) {
 257:	83 c3 01             	add    $0x1,%ebx
 25a:	39 f3                	cmp    %esi,%ebx
 25c:	7c f4                	jl     252 <main+0x12b>
    }
    if (before.num_processes >= NPROC || after.num_processes >= NPROC) {
 25e:	8b 85 e4 fb ff ff    	mov    -0x41c(%ebp),%eax
 264:	83 f8 3f             	cmp    $0x3f,%eax
 267:	7f 36                	jg     29f <main+0x178>
 269:	8b 95 e0 f8 ff ff    	mov    -0x720(%ebp),%edx
 26f:	83 fa 3f             	cmp    $0x3f,%edx
 272:	7f 2b                	jg     29f <main+0x178>
        printf(2, "getprocessesinfo's num_processes is greater than NPROC before parent slept\n");
        return 1;
    }
    if (before.num_processes < 0 || after.num_processes < 0) {
 274:	85 c0                	test   %eax,%eax
 276:	78 04                	js     27c <main+0x155>
 278:	85 d2                	test   %edx,%edx
 27a:	79 37                	jns    2b3 <main+0x18c>
        printf(2, "getprocessesinfo's num_processes is negative -- not changed by syscall?\n");
 27c:	83 ec 08             	sub    $0x8,%esp
 27f:	68 ec 09 00 00       	push   $0x9ec
 284:	6a 02                	push   $0x2
 286:	e8 a8 04 00 00       	call   733 <printf>
        return 1;
 28b:	83 c4 10             	add    $0x10,%esp
            }
            printf(1, "%d\t%d\n", tickets_for[i], after.times_scheduled[after_index] - before.times_scheduled[before_index]);
        }
    }
    exit();
 28e:	b8 01 00 00 00       	mov    $0x1,%eax
 293:	8d 65 f0             	lea    -0x10(%ebp),%esp
 296:	59                   	pop    %ecx
 297:	5b                   	pop    %ebx
 298:	5e                   	pop    %esi
 299:	5f                   	pop    %edi
 29a:	5d                   	pop    %ebp
 29b:	8d 61 fc             	lea    -0x4(%ecx),%esp
 29e:	c3                   	ret    
        printf(2, "getprocessesinfo's num_processes is greater than NPROC before parent slept\n");
 29f:	83 ec 08             	sub    $0x8,%esp
 2a2:	68 a0 09 00 00       	push   $0x9a0
 2a7:	6a 02                	push   $0x2
 2a9:	e8 85 04 00 00       	call   733 <printf>
        return 1;
 2ae:	83 c4 10             	add    $0x10,%esp
 2b1:	eb db                	jmp    28e <main+0x167>
    printf(1, "TICKETS\tTIMES SCHEDULED\n");
 2b3:	83 ec 08             	sub    $0x8,%esp
 2b6:	68 c4 08 00 00       	push   $0x8c4
 2bb:	6a 01                	push   $0x1
 2bd:	e8 71 04 00 00       	call   733 <printf>
    for (int i = 0; i < num_children; ++i) {
 2c2:	83 c4 10             	add    $0x10,%esp
 2c5:	bb 00 00 00 00       	mov    $0x0,%ebx
 2ca:	e9 91 00 00 00       	jmp    360 <main+0x239>
            printf(2, "child %d did not exist for getprocessesinfo before parent slept\n", i);
 2cf:	83 ec 04             	sub    $0x4,%esp
 2d2:	53                   	push   %ebx
 2d3:	68 38 0a 00 00       	push   $0xa38
 2d8:	6a 02                	push   $0x2
 2da:	e8 54 04 00 00       	call   733 <printf>
 2df:	83 c4 10             	add    $0x10,%esp
 2e2:	e9 cc 00 00 00       	jmp    3b3 <main+0x28c>
            printf(2, "child %d did not exist for getprocessesinfo after parent slept\n", i);
 2e7:	83 ec 04             	sub    $0x4,%esp
 2ea:	53                   	push   %ebx
 2eb:	68 7c 0a 00 00       	push   $0xa7c
 2f0:	6a 02                	push   $0x2
 2f2:	e8 3c 04 00 00       	call   733 <printf>
 2f7:	83 c4 10             	add    $0x10,%esp
 2fa:	e9 bd 00 00 00       	jmp    3bc <main+0x295>
            printf(1, "%d\t--unknown--\n", tickets_for[i]);
 2ff:	83 ec 04             	sub    $0x4,%esp
 302:	ff b4 9d 68 ff ff ff 	push   -0x98(%ebp,%ebx,4)
 309:	68 dd 08 00 00       	push   $0x8dd
 30e:	6a 01                	push   $0x1
 310:	e8 1e 04 00 00       	call   733 <printf>
 315:	83 c4 10             	add    $0x10,%esp
 318:	eb 43                	jmp    35d <main+0x236>
                printf(2, "child %d had wrong number of tickets in getprocessinfo before parent slept\n", i);
 31a:	83 ec 04             	sub    $0x4,%esp
 31d:	53                   	push   %ebx
 31e:	68 bc 0a 00 00       	push   $0xabc
 323:	6a 02                	push   $0x2
 325:	e8 09 04 00 00       	call   733 <printf>
 32a:	83 c4 10             	add    $0x10,%esp
 32d:	e9 bc 00 00 00       	jmp    3ee <main+0x2c7>
            printf(1, "%d\t%d\n", tickets_for[i], after.times_scheduled[after_index] - before.times_scheduled[before_index]);
 332:	8b 84 bd e4 f9 ff ff 	mov    -0x61c(%ebp,%edi,4),%eax
 339:	8b 95 d4 f8 ff ff    	mov    -0x72c(%ebp),%edx
 33f:	2b 84 95 e8 fc ff ff 	sub    -0x318(%ebp,%edx,4),%eax
 346:	50                   	push   %eax
 347:	ff b4 9d 68 ff ff ff 	push   -0x98(%ebp,%ebx,4)
 34e:	68 ed 08 00 00       	push   $0x8ed
 353:	6a 01                	push   $0x1
 355:	e8 d9 03 00 00       	call   733 <printf>
 35a:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < num_children; ++i) {
 35d:	83 c3 01             	add    $0x1,%ebx
 360:	39 f3                	cmp    %esi,%ebx
 362:	0f 8d b2 00 00 00    	jge    41a <main+0x2f3>
        int before_index = find_index_of_pid(before.pids, before.num_processes, active_pids[i]);
 368:	8b bc 9d e8 fe ff ff 	mov    -0x118(%ebp,%ebx,4),%edi
 36f:	83 ec 04             	sub    $0x4,%esp
 372:	57                   	push   %edi
 373:	ff b5 e4 fb ff ff    	push   -0x41c(%ebp)
 379:	8d 85 e8 fb ff ff    	lea    -0x418(%ebp),%eax
 37f:	50                   	push   %eax
 380:	e8 d1 fc ff ff       	call   56 <find_index_of_pid>
 385:	83 c4 0c             	add    $0xc,%esp
 388:	89 85 d4 f8 ff ff    	mov    %eax,-0x72c(%ebp)
        int after_index = find_index_of_pid(after.pids, after.num_processes, active_pids[i]);
 38e:	57                   	push   %edi
 38f:	ff b5 e0 f8 ff ff    	push   -0x720(%ebp)
 395:	8d 85 e4 f8 ff ff    	lea    -0x71c(%ebp),%eax
 39b:	50                   	push   %eax
 39c:	e8 b5 fc ff ff       	call   56 <find_index_of_pid>
 3a1:	83 c4 10             	add    $0x10,%esp
 3a4:	89 c7                	mov    %eax,%edi
        if (before_index == -1)
 3a6:	83 bd d4 f8 ff ff ff 	cmpl   $0xffffffff,-0x72c(%ebp)
 3ad:	0f 84 1c ff ff ff    	je     2cf <main+0x1a8>
        if (after_index == -1)
 3b3:	83 ff ff             	cmp    $0xffffffff,%edi
 3b6:	0f 84 2b ff ff ff    	je     2e7 <main+0x1c0>
        if (before_index == -1 || after_index == -1) {
 3bc:	83 bd d4 f8 ff ff ff 	cmpl   $0xffffffff,-0x72c(%ebp)
 3c3:	0f 94 c0             	sete   %al
 3c6:	83 ff ff             	cmp    $0xffffffff,%edi
 3c9:	0f 94 c2             	sete   %dl
 3cc:	08 d0                	or     %dl,%al
 3ce:	0f 85 2b ff ff ff    	jne    2ff <main+0x1d8>
            if (before.tickets[before_index] != tickets_for[i]) {
 3d4:	8b 85 d4 f8 ff ff    	mov    -0x72c(%ebp),%eax
 3da:	8b 94 9d 68 ff ff ff 	mov    -0x98(%ebp,%ebx,4),%edx
 3e1:	39 94 85 e8 fd ff ff 	cmp    %edx,-0x218(%ebp,%eax,4)
 3e8:	0f 85 2c ff ff ff    	jne    31a <main+0x1f3>
            if (after.tickets[after_index] != tickets_for[i]) {
 3ee:	8b 84 9d 68 ff ff ff 	mov    -0x98(%ebp,%ebx,4),%eax
 3f5:	39 84 bd e4 fa ff ff 	cmp    %eax,-0x51c(%ebp,%edi,4)
 3fc:	0f 84 30 ff ff ff    	je     332 <main+0x20b>
                printf(2, "child %d had wrong number of tickets in getprocessinfo after parent slept\n", i);
 402:	83 ec 04             	sub    $0x4,%esp
 405:	53                   	push   %ebx
 406:	68 08 0b 00 00       	push   $0xb08
 40b:	6a 02                	push   $0x2
 40d:	e8 21 03 00 00       	call   733 <printf>
 412:	83 c4 10             	add    $0x10,%esp
 415:	e9 18 ff ff ff       	jmp    332 <main+0x20b>
    exit();
 41a:	e8 9f 01 00 00       	call   5be <exit>

0000041f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 41f:	55                   	push   %ebp
 420:	89 e5                	mov    %esp,%ebp
 422:	56                   	push   %esi
 423:	53                   	push   %ebx
 424:	8b 75 08             	mov    0x8(%ebp),%esi
 427:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 42a:	89 f0                	mov    %esi,%eax
 42c:	89 d1                	mov    %edx,%ecx
 42e:	83 c2 01             	add    $0x1,%edx
 431:	89 c3                	mov    %eax,%ebx
 433:	83 c0 01             	add    $0x1,%eax
 436:	0f b6 09             	movzbl (%ecx),%ecx
 439:	88 0b                	mov    %cl,(%ebx)
 43b:	84 c9                	test   %cl,%cl
 43d:	75 ed                	jne    42c <strcpy+0xd>
    ;
  return os;
}
 43f:	89 f0                	mov    %esi,%eax
 441:	5b                   	pop    %ebx
 442:	5e                   	pop    %esi
 443:	5d                   	pop    %ebp
 444:	c3                   	ret    

00000445 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 445:	55                   	push   %ebp
 446:	89 e5                	mov    %esp,%ebp
 448:	8b 4d 08             	mov    0x8(%ebp),%ecx
 44b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 44e:	eb 06                	jmp    456 <strcmp+0x11>
    p++, q++;
 450:	83 c1 01             	add    $0x1,%ecx
 453:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 456:	0f b6 01             	movzbl (%ecx),%eax
 459:	84 c0                	test   %al,%al
 45b:	74 04                	je     461 <strcmp+0x1c>
 45d:	3a 02                	cmp    (%edx),%al
 45f:	74 ef                	je     450 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 461:	0f b6 c0             	movzbl %al,%eax
 464:	0f b6 12             	movzbl (%edx),%edx
 467:	29 d0                	sub    %edx,%eax
}
 469:	5d                   	pop    %ebp
 46a:	c3                   	ret    

0000046b <strlen>:

uint
strlen(const char *s)
{
 46b:	55                   	push   %ebp
 46c:	89 e5                	mov    %esp,%ebp
 46e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 471:	b8 00 00 00 00       	mov    $0x0,%eax
 476:	eb 03                	jmp    47b <strlen+0x10>
 478:	83 c0 01             	add    $0x1,%eax
 47b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
 47f:	75 f7                	jne    478 <strlen+0xd>
    ;
  return n;
}
 481:	5d                   	pop    %ebp
 482:	c3                   	ret    

00000483 <memset>:

void*
memset(void *dst, int c, uint n)
{
 483:	55                   	push   %ebp
 484:	89 e5                	mov    %esp,%ebp
 486:	57                   	push   %edi
 487:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 48a:	89 d7                	mov    %edx,%edi
 48c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 48f:	8b 45 0c             	mov    0xc(%ebp),%eax
 492:	fc                   	cld    
 493:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 495:	89 d0                	mov    %edx,%eax
 497:	8b 7d fc             	mov    -0x4(%ebp),%edi
 49a:	c9                   	leave  
 49b:	c3                   	ret    

0000049c <strchr>:

char*
strchr(const char *s, char c)
{
 49c:	55                   	push   %ebp
 49d:	89 e5                	mov    %esp,%ebp
 49f:	8b 45 08             	mov    0x8(%ebp),%eax
 4a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 4a6:	eb 03                	jmp    4ab <strchr+0xf>
 4a8:	83 c0 01             	add    $0x1,%eax
 4ab:	0f b6 10             	movzbl (%eax),%edx
 4ae:	84 d2                	test   %dl,%dl
 4b0:	74 06                	je     4b8 <strchr+0x1c>
    if(*s == c)
 4b2:	38 ca                	cmp    %cl,%dl
 4b4:	75 f2                	jne    4a8 <strchr+0xc>
 4b6:	eb 05                	jmp    4bd <strchr+0x21>
      return (char*)s;
  return 0;
 4b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4bd:	5d                   	pop    %ebp
 4be:	c3                   	ret    

000004bf <gets>:

char*
gets(char *buf, int max)
{
 4bf:	55                   	push   %ebp
 4c0:	89 e5                	mov    %esp,%ebp
 4c2:	57                   	push   %edi
 4c3:	56                   	push   %esi
 4c4:	53                   	push   %ebx
 4c5:	83 ec 1c             	sub    $0x1c,%esp
 4c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4cb:	bb 00 00 00 00       	mov    $0x0,%ebx
 4d0:	89 de                	mov    %ebx,%esi
 4d2:	83 c3 01             	add    $0x1,%ebx
 4d5:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 4d8:	7d 2e                	jge    508 <gets+0x49>
    cc = read(0, &c, 1);
 4da:	83 ec 04             	sub    $0x4,%esp
 4dd:	6a 01                	push   $0x1
 4df:	8d 45 e7             	lea    -0x19(%ebp),%eax
 4e2:	50                   	push   %eax
 4e3:	6a 00                	push   $0x0
 4e5:	e8 ec 00 00 00       	call   5d6 <read>
    if(cc < 1)
 4ea:	83 c4 10             	add    $0x10,%esp
 4ed:	85 c0                	test   %eax,%eax
 4ef:	7e 17                	jle    508 <gets+0x49>
      break;
    buf[i++] = c;
 4f1:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 4f5:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
 4f8:	3c 0a                	cmp    $0xa,%al
 4fa:	0f 94 c2             	sete   %dl
 4fd:	3c 0d                	cmp    $0xd,%al
 4ff:	0f 94 c0             	sete   %al
 502:	08 c2                	or     %al,%dl
 504:	74 ca                	je     4d0 <gets+0x11>
    buf[i++] = c;
 506:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 508:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 50c:	89 f8                	mov    %edi,%eax
 50e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 511:	5b                   	pop    %ebx
 512:	5e                   	pop    %esi
 513:	5f                   	pop    %edi
 514:	5d                   	pop    %ebp
 515:	c3                   	ret    

00000516 <stat>:

int
stat(const char *n, struct stat *st)
{
 516:	55                   	push   %ebp
 517:	89 e5                	mov    %esp,%ebp
 519:	56                   	push   %esi
 51a:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 51b:	83 ec 08             	sub    $0x8,%esp
 51e:	6a 00                	push   $0x0
 520:	ff 75 08             	push   0x8(%ebp)
 523:	e8 d6 00 00 00       	call   5fe <open>
  if(fd < 0)
 528:	83 c4 10             	add    $0x10,%esp
 52b:	85 c0                	test   %eax,%eax
 52d:	78 24                	js     553 <stat+0x3d>
 52f:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 531:	83 ec 08             	sub    $0x8,%esp
 534:	ff 75 0c             	push   0xc(%ebp)
 537:	50                   	push   %eax
 538:	e8 d9 00 00 00       	call   616 <fstat>
 53d:	89 c6                	mov    %eax,%esi
  close(fd);
 53f:	89 1c 24             	mov    %ebx,(%esp)
 542:	e8 9f 00 00 00       	call   5e6 <close>
  return r;
 547:	83 c4 10             	add    $0x10,%esp
}
 54a:	89 f0                	mov    %esi,%eax
 54c:	8d 65 f8             	lea    -0x8(%ebp),%esp
 54f:	5b                   	pop    %ebx
 550:	5e                   	pop    %esi
 551:	5d                   	pop    %ebp
 552:	c3                   	ret    
    return -1;
 553:	be ff ff ff ff       	mov    $0xffffffff,%esi
 558:	eb f0                	jmp    54a <stat+0x34>

0000055a <atoi>:

int
atoi(const char *s)
{
 55a:	55                   	push   %ebp
 55b:	89 e5                	mov    %esp,%ebp
 55d:	53                   	push   %ebx
 55e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 561:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 566:	eb 10                	jmp    578 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 568:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
 56b:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
 56e:	83 c1 01             	add    $0x1,%ecx
 571:	0f be c0             	movsbl %al,%eax
 574:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
  while('0' <= *s && *s <= '9')
 578:	0f b6 01             	movzbl (%ecx),%eax
 57b:	8d 58 d0             	lea    -0x30(%eax),%ebx
 57e:	80 fb 09             	cmp    $0x9,%bl
 581:	76 e5                	jbe    568 <atoi+0xe>
  return n;
}
 583:	89 d0                	mov    %edx,%eax
 585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 588:	c9                   	leave  
 589:	c3                   	ret    

0000058a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 58a:	55                   	push   %ebp
 58b:	89 e5                	mov    %esp,%ebp
 58d:	56                   	push   %esi
 58e:	53                   	push   %ebx
 58f:	8b 75 08             	mov    0x8(%ebp),%esi
 592:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 595:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
 598:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
 59a:	eb 0d                	jmp    5a9 <memmove+0x1f>
    *dst++ = *src++;
 59c:	0f b6 01             	movzbl (%ecx),%eax
 59f:	88 02                	mov    %al,(%edx)
 5a1:	8d 49 01             	lea    0x1(%ecx),%ecx
 5a4:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
 5a7:	89 d8                	mov    %ebx,%eax
 5a9:	8d 58 ff             	lea    -0x1(%eax),%ebx
 5ac:	85 c0                	test   %eax,%eax
 5ae:	7f ec                	jg     59c <memmove+0x12>
  return vdst;
}
 5b0:	89 f0                	mov    %esi,%eax
 5b2:	5b                   	pop    %ebx
 5b3:	5e                   	pop    %esi
 5b4:	5d                   	pop    %ebp
 5b5:	c3                   	ret    

000005b6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5b6:	b8 01 00 00 00       	mov    $0x1,%eax
 5bb:	cd 40                	int    $0x40
 5bd:	c3                   	ret    

000005be <exit>:
SYSCALL(exit)
 5be:	b8 02 00 00 00       	mov    $0x2,%eax
 5c3:	cd 40                	int    $0x40
 5c5:	c3                   	ret    

000005c6 <wait>:
SYSCALL(wait)
 5c6:	b8 03 00 00 00       	mov    $0x3,%eax
 5cb:	cd 40                	int    $0x40
 5cd:	c3                   	ret    

000005ce <pipe>:
SYSCALL(pipe)
 5ce:	b8 04 00 00 00       	mov    $0x4,%eax
 5d3:	cd 40                	int    $0x40
 5d5:	c3                   	ret    

000005d6 <read>:
SYSCALL(read)
 5d6:	b8 05 00 00 00       	mov    $0x5,%eax
 5db:	cd 40                	int    $0x40
 5dd:	c3                   	ret    

000005de <write>:
SYSCALL(write)
 5de:	b8 10 00 00 00       	mov    $0x10,%eax
 5e3:	cd 40                	int    $0x40
 5e5:	c3                   	ret    

000005e6 <close>:
SYSCALL(close)
 5e6:	b8 15 00 00 00       	mov    $0x15,%eax
 5eb:	cd 40                	int    $0x40
 5ed:	c3                   	ret    

000005ee <kill>:
SYSCALL(kill)
 5ee:	b8 06 00 00 00       	mov    $0x6,%eax
 5f3:	cd 40                	int    $0x40
 5f5:	c3                   	ret    

000005f6 <exec>:
SYSCALL(exec)
 5f6:	b8 07 00 00 00       	mov    $0x7,%eax
 5fb:	cd 40                	int    $0x40
 5fd:	c3                   	ret    

000005fe <open>:
SYSCALL(open)
 5fe:	b8 0f 00 00 00       	mov    $0xf,%eax
 603:	cd 40                	int    $0x40
 605:	c3                   	ret    

00000606 <mknod>:
SYSCALL(mknod)
 606:	b8 11 00 00 00       	mov    $0x11,%eax
 60b:	cd 40                	int    $0x40
 60d:	c3                   	ret    

0000060e <unlink>:
SYSCALL(unlink)
 60e:	b8 12 00 00 00       	mov    $0x12,%eax
 613:	cd 40                	int    $0x40
 615:	c3                   	ret    

00000616 <fstat>:
SYSCALL(fstat)
 616:	b8 08 00 00 00       	mov    $0x8,%eax
 61b:	cd 40                	int    $0x40
 61d:	c3                   	ret    

0000061e <link>:
SYSCALL(link)
 61e:	b8 13 00 00 00       	mov    $0x13,%eax
 623:	cd 40                	int    $0x40
 625:	c3                   	ret    

00000626 <mkdir>:
SYSCALL(mkdir)
 626:	b8 14 00 00 00       	mov    $0x14,%eax
 62b:	cd 40                	int    $0x40
 62d:	c3                   	ret    

0000062e <chdir>:
SYSCALL(chdir)
 62e:	b8 09 00 00 00       	mov    $0x9,%eax
 633:	cd 40                	int    $0x40
 635:	c3                   	ret    

00000636 <dup>:
SYSCALL(dup)
 636:	b8 0a 00 00 00       	mov    $0xa,%eax
 63b:	cd 40                	int    $0x40
 63d:	c3                   	ret    

0000063e <getpid>:
SYSCALL(getpid)
 63e:	b8 0b 00 00 00       	mov    $0xb,%eax
 643:	cd 40                	int    $0x40
 645:	c3                   	ret    

00000646 <sbrk>:
SYSCALL(sbrk)
 646:	b8 0c 00 00 00       	mov    $0xc,%eax
 64b:	cd 40                	int    $0x40
 64d:	c3                   	ret    

0000064e <sleep>:
SYSCALL(sleep)
 64e:	b8 0d 00 00 00       	mov    $0xd,%eax
 653:	cd 40                	int    $0x40
 655:	c3                   	ret    

00000656 <uptime>:
SYSCALL(uptime)
 656:	b8 0e 00 00 00       	mov    $0xe,%eax
 65b:	cd 40                	int    $0x40
 65d:	c3                   	ret    

0000065e <yield>:
SYSCALL(yield)
 65e:	b8 16 00 00 00       	mov    $0x16,%eax
 663:	cd 40                	int    $0x40
 665:	c3                   	ret    

00000666 <shutdown>:
SYSCALL(shutdown)
 666:	b8 17 00 00 00       	mov    $0x17,%eax
 66b:	cd 40                	int    $0x40
 66d:	c3                   	ret    

0000066e <writecount>:
SYSCALL(writecount)
 66e:	b8 18 00 00 00       	mov    $0x18,%eax
 673:	cd 40                	int    $0x40
 675:	c3                   	ret    

00000676 <setwritecount>:
SYSCALL(setwritecount)
 676:	b8 19 00 00 00       	mov    $0x19,%eax
 67b:	cd 40                	int    $0x40
 67d:	c3                   	ret    

0000067e <settickets>:
SYSCALL(settickets)
 67e:	b8 1a 00 00 00       	mov    $0x1a,%eax
 683:	cd 40                	int    $0x40
 685:	c3                   	ret    

00000686 <getprocessesinfo>:
 686:	b8 1b 00 00 00       	mov    $0x1b,%eax
 68b:	cd 40                	int    $0x40
 68d:	c3                   	ret    

0000068e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 68e:	55                   	push   %ebp
 68f:	89 e5                	mov    %esp,%ebp
 691:	83 ec 1c             	sub    $0x1c,%esp
 694:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 697:	6a 01                	push   $0x1
 699:	8d 55 f4             	lea    -0xc(%ebp),%edx
 69c:	52                   	push   %edx
 69d:	50                   	push   %eax
 69e:	e8 3b ff ff ff       	call   5de <write>
}
 6a3:	83 c4 10             	add    $0x10,%esp
 6a6:	c9                   	leave  
 6a7:	c3                   	ret    

000006a8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6a8:	55                   	push   %ebp
 6a9:	89 e5                	mov    %esp,%ebp
 6ab:	57                   	push   %edi
 6ac:	56                   	push   %esi
 6ad:	53                   	push   %ebx
 6ae:	83 ec 2c             	sub    $0x2c,%esp
 6b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
 6b4:	89 d0                	mov    %edx,%eax
 6b6:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 6bc:	0f 95 c1             	setne  %cl
 6bf:	c1 ea 1f             	shr    $0x1f,%edx
 6c2:	84 d1                	test   %dl,%cl
 6c4:	74 44                	je     70a <printint+0x62>
    neg = 1;
    x = -xx;
 6c6:	f7 d8                	neg    %eax
 6c8:	89 c1                	mov    %eax,%ecx
    neg = 1;
 6ca:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 6d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 6d6:	89 c8                	mov    %ecx,%eax
 6d8:	ba 00 00 00 00       	mov    $0x0,%edx
 6dd:	f7 f6                	div    %esi
 6df:	89 df                	mov    %ebx,%edi
 6e1:	83 c3 01             	add    $0x1,%ebx
 6e4:	0f b6 92 b4 0b 00 00 	movzbl 0xbb4(%edx),%edx
 6eb:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 6ef:	89 ca                	mov    %ecx,%edx
 6f1:	89 c1                	mov    %eax,%ecx
 6f3:	39 d6                	cmp    %edx,%esi
 6f5:	76 df                	jbe    6d6 <printint+0x2e>
  if(neg)
 6f7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 6fb:	74 31                	je     72e <printint+0x86>
    buf[i++] = '-';
 6fd:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 702:	8d 5f 02             	lea    0x2(%edi),%ebx
 705:	8b 75 d0             	mov    -0x30(%ebp),%esi
 708:	eb 17                	jmp    721 <printint+0x79>
    x = xx;
 70a:	89 c1                	mov    %eax,%ecx
  neg = 0;
 70c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 713:	eb bc                	jmp    6d1 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 715:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 71a:	89 f0                	mov    %esi,%eax
 71c:	e8 6d ff ff ff       	call   68e <putc>
  while(--i >= 0)
 721:	83 eb 01             	sub    $0x1,%ebx
 724:	79 ef                	jns    715 <printint+0x6d>
}
 726:	83 c4 2c             	add    $0x2c,%esp
 729:	5b                   	pop    %ebx
 72a:	5e                   	pop    %esi
 72b:	5f                   	pop    %edi
 72c:	5d                   	pop    %ebp
 72d:	c3                   	ret    
 72e:	8b 75 d0             	mov    -0x30(%ebp),%esi
 731:	eb ee                	jmp    721 <printint+0x79>

00000733 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 733:	55                   	push   %ebp
 734:	89 e5                	mov    %esp,%ebp
 736:	57                   	push   %edi
 737:	56                   	push   %esi
 738:	53                   	push   %ebx
 739:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 73c:	8d 45 10             	lea    0x10(%ebp),%eax
 73f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 742:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 747:	bb 00 00 00 00       	mov    $0x0,%ebx
 74c:	eb 14                	jmp    762 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 74e:	89 fa                	mov    %edi,%edx
 750:	8b 45 08             	mov    0x8(%ebp),%eax
 753:	e8 36 ff ff ff       	call   68e <putc>
 758:	eb 05                	jmp    75f <printf+0x2c>
      }
    } else if(state == '%'){
 75a:	83 fe 25             	cmp    $0x25,%esi
 75d:	74 25                	je     784 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 75f:	83 c3 01             	add    $0x1,%ebx
 762:	8b 45 0c             	mov    0xc(%ebp),%eax
 765:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 769:	84 c0                	test   %al,%al
 76b:	0f 84 20 01 00 00    	je     891 <printf+0x15e>
    c = fmt[i] & 0xff;
 771:	0f be f8             	movsbl %al,%edi
 774:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 777:	85 f6                	test   %esi,%esi
 779:	75 df                	jne    75a <printf+0x27>
      if(c == '%'){
 77b:	83 f8 25             	cmp    $0x25,%eax
 77e:	75 ce                	jne    74e <printf+0x1b>
        state = '%';
 780:	89 c6                	mov    %eax,%esi
 782:	eb db                	jmp    75f <printf+0x2c>
      if(c == 'd'){
 784:	83 f8 25             	cmp    $0x25,%eax
 787:	0f 84 cf 00 00 00    	je     85c <printf+0x129>
 78d:	0f 8c dd 00 00 00    	jl     870 <printf+0x13d>
 793:	83 f8 78             	cmp    $0x78,%eax
 796:	0f 8f d4 00 00 00    	jg     870 <printf+0x13d>
 79c:	83 f8 63             	cmp    $0x63,%eax
 79f:	0f 8c cb 00 00 00    	jl     870 <printf+0x13d>
 7a5:	83 e8 63             	sub    $0x63,%eax
 7a8:	83 f8 15             	cmp    $0x15,%eax
 7ab:	0f 87 bf 00 00 00    	ja     870 <printf+0x13d>
 7b1:	ff 24 85 5c 0b 00 00 	jmp    *0xb5c(,%eax,4)
        printint(fd, *ap, 10, 1);
 7b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 7bb:	8b 17                	mov    (%edi),%edx
 7bd:	83 ec 0c             	sub    $0xc,%esp
 7c0:	6a 01                	push   $0x1
 7c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
 7c7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ca:	e8 d9 fe ff ff       	call   6a8 <printint>
        ap++;
 7cf:	83 c7 04             	add    $0x4,%edi
 7d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 7d5:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 7d8:	be 00 00 00 00       	mov    $0x0,%esi
 7dd:	eb 80                	jmp    75f <printf+0x2c>
        printint(fd, *ap, 16, 0);
 7df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 7e2:	8b 17                	mov    (%edi),%edx
 7e4:	83 ec 0c             	sub    $0xc,%esp
 7e7:	6a 00                	push   $0x0
 7e9:	b9 10 00 00 00       	mov    $0x10,%ecx
 7ee:	8b 45 08             	mov    0x8(%ebp),%eax
 7f1:	e8 b2 fe ff ff       	call   6a8 <printint>
        ap++;
 7f6:	83 c7 04             	add    $0x4,%edi
 7f9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 7fc:	83 c4 10             	add    $0x10,%esp
      state = 0;
 7ff:	be 00 00 00 00       	mov    $0x0,%esi
 804:	e9 56 ff ff ff       	jmp    75f <printf+0x2c>
        s = (char*)*ap;
 809:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 80c:	8b 30                	mov    (%eax),%esi
        ap++;
 80e:	83 c0 04             	add    $0x4,%eax
 811:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 814:	85 f6                	test   %esi,%esi
 816:	75 15                	jne    82d <printf+0xfa>
          s = "(null)";
 818:	be 53 0b 00 00       	mov    $0xb53,%esi
 81d:	eb 0e                	jmp    82d <printf+0xfa>
          putc(fd, *s);
 81f:	0f be d2             	movsbl %dl,%edx
 822:	8b 45 08             	mov    0x8(%ebp),%eax
 825:	e8 64 fe ff ff       	call   68e <putc>
          s++;
 82a:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 82d:	0f b6 16             	movzbl (%esi),%edx
 830:	84 d2                	test   %dl,%dl
 832:	75 eb                	jne    81f <printf+0xec>
      state = 0;
 834:	be 00 00 00 00       	mov    $0x0,%esi
 839:	e9 21 ff ff ff       	jmp    75f <printf+0x2c>
        putc(fd, *ap);
 83e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 841:	0f be 17             	movsbl (%edi),%edx
 844:	8b 45 08             	mov    0x8(%ebp),%eax
 847:	e8 42 fe ff ff       	call   68e <putc>
        ap++;
 84c:	83 c7 04             	add    $0x4,%edi
 84f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 852:	be 00 00 00 00       	mov    $0x0,%esi
 857:	e9 03 ff ff ff       	jmp    75f <printf+0x2c>
        putc(fd, c);
 85c:	89 fa                	mov    %edi,%edx
 85e:	8b 45 08             	mov    0x8(%ebp),%eax
 861:	e8 28 fe ff ff       	call   68e <putc>
      state = 0;
 866:	be 00 00 00 00       	mov    $0x0,%esi
 86b:	e9 ef fe ff ff       	jmp    75f <printf+0x2c>
        putc(fd, '%');
 870:	ba 25 00 00 00       	mov    $0x25,%edx
 875:	8b 45 08             	mov    0x8(%ebp),%eax
 878:	e8 11 fe ff ff       	call   68e <putc>
        putc(fd, c);
 87d:	89 fa                	mov    %edi,%edx
 87f:	8b 45 08             	mov    0x8(%ebp),%eax
 882:	e8 07 fe ff ff       	call   68e <putc>
      state = 0;
 887:	be 00 00 00 00       	mov    $0x0,%esi
 88c:	e9 ce fe ff ff       	jmp    75f <printf+0x2c>
    }
  }
}
 891:	8d 65 f4             	lea    -0xc(%ebp),%esp
 894:	5b                   	pop    %ebx
 895:	5e                   	pop    %esi
 896:	5f                   	pop    %edi
 897:	5d                   	pop    %ebp
 898:	c3                   	ret    
