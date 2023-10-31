
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
   6:	e8 52 06 00 00       	call   65d <yield>
   b:	eb f9                	jmp    6 <yield_forever+0x6>

0000000d <run_forever>:
    }
}

__attribute__((noreturn))
void run_forever() {
   d:	55                   	push   %ebp
   e:	89 e5                	mov    %esp,%ebp
    while (1) {
        __asm__("");
  10:	eb fe                	jmp    10 <run_forever+0x3>

00000012 <spawn>:
    }
}

int spawn(int tickets) {
  12:	55                   	push   %ebp
  13:	89 e5                	mov    %esp,%ebp
  15:	83 ec 18             	sub    $0x18,%esp
    int pid = fork();
  18:	e8 98 05 00 00       	call   5b5 <fork>
    if (pid == 0) {
  1d:	85 c0                	test   %eax,%eax
  1f:	75 15                	jne    36 <spawn+0x24>
        settickets(tickets);
  21:	8b 45 08             	mov    0x8(%ebp),%eax
  24:	89 04 24             	mov    %eax,(%esp)
  27:	e8 51 06 00 00       	call   67d <settickets>
        yield();
  2c:	e8 2c 06 00 00       	call   65d <yield>
#ifdef USE_YIELD
        yield_forever();
#else
        run_forever();
  31:	e8 d7 ff ff ff       	call   d <run_forever>
#endif
    } else if (pid != -1) {
  36:	83 f8 ff             	cmp    $0xffffffff,%eax
  39:	75 19                	jne    54 <spawn+0x42>
        return pid;
    } else {
        printf(2, "error in fork\n");
  3b:	c7 44 24 04 a8 08 00 	movl   $0x8a8,0x4(%esp)
  42:	00 
  43:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  4a:	e8 fd 06 00 00       	call   74c <printf>
        return -1;
  4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
}
  54:	c9                   	leave  
  55:	c3                   	ret    

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
  68:	eb 08                	jmp    72 <find_index_of_pid+0x1c>
        if (list[i] == pid)
  6a:	39 0c 83             	cmp    %ecx,(%ebx,%eax,4)
  6d:	74 0c                	je     7b <find_index_of_pid+0x25>
    for (int i = 0; i < list_size; ++i) {
  6f:	83 c0 01             	add    $0x1,%eax
  72:	39 d0                	cmp    %edx,%eax
  74:	7c f4                	jl     6a <find_index_of_pid+0x14>
            return i;
    }
    return -1;
  76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  7b:	5b                   	pop    %ebx
  7c:	5d                   	pop    %ebp
  7d:	c3                   	ret    

0000007e <wait_for_ticket_counts>:

void wait_for_ticket_counts(int num_children, int *pids, int *tickets) {
  7e:	55                   	push   %ebp
  7f:	89 e5                	mov    %esp,%ebp
  81:	57                   	push   %edi
  82:	56                   	push   %esi
  83:	53                   	push   %ebx
  84:	81 ec 3c 03 00 00    	sub    $0x33c,%esp
  8a:	8b 75 0c             	mov    0xc(%ebp),%esi
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
  8d:	c7 85 d0 fc ff ff 00 	movl   $0x0,-0x330(%ebp)
  94:	00 00 00 
        yield();
        int done = 1;
        struct processes_info info;
        getprocessesinfo(&info);
        for (int i = 0; i < num_children; ++i) {
            int index = find_index_of_pid(info.pids, info.num_processes, pids[i]);
  97:	8d bd e8 fc ff ff    	lea    -0x318(%ebp),%edi
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
  9d:	eb 6e                	jmp    10d <wait_for_ticket_counts+0x8f>
        yield();
  9f:	e8 b9 05 00 00       	call   65d <yield>
        getprocessesinfo(&info);
  a4:	8d 85 e4 fc ff ff    	lea    -0x31c(%ebp),%eax
  aa:	89 04 24             	mov    %eax,(%esp)
  ad:	e8 d3 05 00 00       	call   685 <getprocessesinfo>
        for (int i = 0; i < num_children; ++i) {
  b2:	bb 00 00 00 00       	mov    $0x0,%ebx
        int done = 1;
  b7:	c7 85 d4 fc ff ff 01 	movl   $0x1,-0x32c(%ebp)
  be:	00 00 00 
        for (int i = 0; i < num_children; ++i) {
  c1:	eb 35                	jmp    f8 <wait_for_ticket_counts+0x7a>
            int index = find_index_of_pid(info.pids, info.num_processes, pids[i]);
  c3:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  ca:	8b 85 e4 fc ff ff    	mov    -0x31c(%ebp),%eax
  d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  d4:	89 3c 24             	mov    %edi,(%esp)
  d7:	e8 7a ff ff ff       	call   56 <find_index_of_pid>
            if (info.tickets[index] != tickets[i]) done = 0;
  dc:	8b 55 10             	mov    0x10(%ebp),%edx
  df:	8b 0c 9a             	mov    (%edx,%ebx,4),%ecx
  e2:	39 8c 85 e8 fe ff ff 	cmp    %ecx,-0x118(%ebp,%eax,4)
  e9:	74 0a                	je     f5 <wait_for_ticket_counts+0x77>
  eb:	c7 85 d4 fc ff ff 00 	movl   $0x0,-0x32c(%ebp)
  f2:	00 00 00 
        for (int i = 0; i < num_children; ++i) {
  f5:	83 c3 01             	add    $0x1,%ebx
  f8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  fb:	7c c6                	jl     c3 <wait_for_ticket_counts+0x45>
        }
        if (done)
  fd:	83 bd d4 fc ff ff 00 	cmpl   $0x0,-0x32c(%ebp)
 104:	75 10                	jne    116 <wait_for_ticket_counts+0x98>
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
 106:	83 85 d0 fc ff ff 01 	addl   $0x1,-0x330(%ebp)
 10d:	83 bd d0 fc ff ff 63 	cmpl   $0x63,-0x330(%ebp)
 114:	7e 89                	jle    9f <wait_for_ticket_counts+0x21>
            break;
    }
}
 116:	81 c4 3c 03 00 00    	add    $0x33c,%esp
 11c:	5b                   	pop    %ebx
 11d:	5e                   	pop    %esi
 11e:	5f                   	pop    %edi
 11f:	5d                   	pop    %ebp
 120:	c3                   	ret    

00000121 <main>:

int main(int argc, char *argv[])
{
 121:	55                   	push   %ebp
 122:	89 e5                	mov    %esp,%ebp
 124:	57                   	push   %edi
 125:	56                   	push   %esi
 126:	53                   	push   %ebx
 127:	83 e4 f0             	and    $0xfffffff0,%esp
 12a:	81 ec 30 07 00 00    	sub    $0x730,%esp
 130:	8b 75 08             	mov    0x8(%ebp),%esi
 133:	8b 7d 0c             	mov    0xc(%ebp),%edi
    if (argc < 3) {
 136:	83 fe 02             	cmp    $0x2,%esi
 139:	7f 1f                	jg     15a <main+0x39>
        printf(2, "usage: %s seconds tickets1 tickets2 ... ticketsN\n"
 13b:	8b 07                	mov    (%edi),%eax
 13d:	89 44 24 08          	mov    %eax,0x8(%esp)
 141:	c7 44 24 04 00 09 00 	movl   $0x900,0x4(%esp)
 148:	00 
 149:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 150:	e8 f7 05 00 00       	call   74c <printf>
                  "       seconds is the number of time units to run for\n"
                  "       ticketsX is the number of tickets to give to subprocess N\n",
                  argv[0]);
        exit();
 155:	e8 63 04 00 00       	call   5bd <exit>
    }
    int tickets_for[MAX_CHILDREN];
    int active_pids[MAX_CHILDREN];
    int num_seconds = atoi(argv[1]);
 15a:	8b 47 04             	mov    0x4(%edi),%eax
 15d:	89 04 24             	mov    %eax,(%esp)
 160:	e8 fb 03 00 00       	call   560 <atoi>
 165:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    int num_children = argc - 2;
 169:	83 ee 02             	sub    $0x2,%esi
    if (num_children > MAX_CHILDREN) {
 16c:	83 fe 20             	cmp    $0x20,%esi
 16f:	7e 21                	jle    192 <main+0x71>
        printf(2, "only up to %d supported\n", MAX_CHILDREN);
 171:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
 178:	00 
 179:	c7 44 24 04 b7 08 00 	movl   $0x8b7,0x4(%esp)
 180:	00 
 181:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 188:	e8 bf 05 00 00       	call   74c <printf>
        exit();
 18d:	e8 2b 04 00 00       	call   5bd <exit>
    }
    /* give us a lot of ticket so we don't get starved */
    settickets(LARGE_TICKET_COUNT);
 192:	c7 04 24 a0 86 01 00 	movl   $0x186a0,(%esp)
 199:	e8 df 04 00 00       	call   67d <settickets>
    for (int i = 0; i < num_children; ++i) {
 19e:	bb 00 00 00 00       	mov    $0x0,%ebx
 1a3:	eb 25                	jmp    1ca <main+0xa9>
        int tickets = atoi(argv[i + 2]);
 1a5:	8b 44 9f 08          	mov    0x8(%edi,%ebx,4),%eax
 1a9:	89 04 24             	mov    %eax,(%esp)
 1ac:	e8 af 03 00 00       	call   560 <atoi>
        tickets_for[i] = tickets;
 1b1:	89 84 9c b0 06 00 00 	mov    %eax,0x6b0(%esp,%ebx,4)
        active_pids[i] = spawn(tickets);
 1b8:	89 04 24             	mov    %eax,(%esp)
 1bb:	e8 52 fe ff ff       	call   12 <spawn>
 1c0:	89 84 9c 30 06 00 00 	mov    %eax,0x630(%esp,%ebx,4)
    for (int i = 0; i < num_children; ++i) {
 1c7:	83 c3 01             	add    $0x1,%ebx
 1ca:	39 f3                	cmp    %esi,%ebx
 1cc:	7c d7                	jl     1a5 <main+0x84>
    }
    wait_for_ticket_counts(num_children, active_pids, tickets_for);
 1ce:	8d 84 24 b0 06 00 00 	lea    0x6b0(%esp),%eax
 1d5:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d9:	8d 84 24 30 06 00 00 	lea    0x630(%esp),%eax
 1e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e4:	89 34 24             	mov    %esi,(%esp)
 1e7:	e8 92 fe ff ff       	call   7e <wait_for_ticket_counts>
    struct processes_info before, after;
    before.num_processes = after.num_processes = -1;
 1ec:	c7 44 24 28 ff ff ff 	movl   $0xffffffff,0x28(%esp)
 1f3:	ff 
 1f4:	c7 84 24 2c 03 00 00 	movl   $0xffffffff,0x32c(%esp)
 1fb:	ff ff ff ff 
    getprocessesinfo(&before);
 1ff:	8d 84 24 2c 03 00 00 	lea    0x32c(%esp),%eax
 206:	89 04 24             	mov    %eax,(%esp)
 209:	e8 77 04 00 00       	call   685 <getprocessesinfo>
    sleep(num_seconds);
 20e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 212:	89 04 24             	mov    %eax,(%esp)
 215:	e8 33 04 00 00       	call   64d <sleep>
    getprocessesinfo(&after);
 21a:	8d 44 24 28          	lea    0x28(%esp),%eax
 21e:	89 04 24             	mov    %eax,(%esp)
 221:	e8 5f 04 00 00       	call   685 <getprocessesinfo>
    for (int i = 0; i < num_children; ++i) {
 226:	bb 00 00 00 00       	mov    $0x0,%ebx
 22b:	eb 12                	jmp    23f <main+0x11e>
        kill(active_pids[i]);
 22d:	8b 84 9c 30 06 00 00 	mov    0x630(%esp,%ebx,4),%eax
 234:	89 04 24             	mov    %eax,(%esp)
 237:	e8 b1 03 00 00       	call   5ed <kill>
    for (int i = 0; i < num_children; ++i) {
 23c:	83 c3 01             	add    $0x1,%ebx
 23f:	39 f3                	cmp    %esi,%ebx
 241:	7c ea                	jl     22d <main+0x10c>
 243:	bb 00 00 00 00       	mov    $0x0,%ebx
 248:	eb 08                	jmp    252 <main+0x131>
    }
    for (int i = 0; i < num_children; ++i) {
        wait();
 24a:	e8 76 03 00 00       	call   5c5 <wait>
    for (int i = 0; i < num_children; ++i) {
 24f:	83 c3 01             	add    $0x1,%ebx
 252:	39 f3                	cmp    %esi,%ebx
 254:	7c f4                	jl     24a <main+0x129>
    }
    if (before.num_processes >= NPROC || after.num_processes >= NPROC) {
 256:	8b 84 24 2c 03 00 00 	mov    0x32c(%esp),%eax
 25d:	83 f8 3f             	cmp    $0x3f,%eax
 260:	7f 09                	jg     26b <main+0x14a>
 262:	8b 54 24 28          	mov    0x28(%esp),%edx
 266:	83 fa 3f             	cmp    $0x3f,%edx
 269:	7e 19                	jle    284 <main+0x163>
        printf(2, "getprocessesinfo's num_processes is greater than NPROC before parent slept\n");
 26b:	c7 44 24 04 ac 09 00 	movl   $0x9ac,0x4(%esp)
 272:	00 
 273:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 27a:	e8 cd 04 00 00       	call   74c <printf>
        return 1;
 27f:	e9 8b 01 00 00       	jmp    40f <main+0x2ee>
    }
    if (before.num_processes < 0 || after.num_processes < 0) {
 284:	85 c0                	test   %eax,%eax
 286:	78 0a                	js     292 <main+0x171>
 288:	85 d2                	test   %edx,%edx
 28a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 290:	79 19                	jns    2ab <main+0x18a>
        printf(2, "getprocessesinfo's num_processes is negative -- not changed by syscall?\n");
 292:	c7 44 24 04 f8 09 00 	movl   $0x9f8,0x4(%esp)
 299:	00 
 29a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2a1:	e8 a6 04 00 00       	call   74c <printf>
        return 1;
 2a6:	e9 64 01 00 00       	jmp    40f <main+0x2ee>
    }
    printf(1, "TICKETS\tTIMES SCHEDULED\n");
 2ab:	c7 44 24 04 d0 08 00 	movl   $0x8d0,0x4(%esp)
 2b2:	00 
 2b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2ba:	e8 8d 04 00 00       	call   74c <printf>
    for (int i = 0; i < num_children; ++i) {
 2bf:	bb 00 00 00 00       	mov    $0x0,%ebx
 2c4:	89 74 24 1c          	mov    %esi,0x1c(%esp)
 2c8:	e9 33 01 00 00       	jmp    400 <main+0x2df>
        int before_index = find_index_of_pid(before.pids, before.num_processes, active_pids[i]);
 2cd:	8b bc 9c 30 06 00 00 	mov    0x630(%esp,%ebx,4),%edi
 2d4:	89 7c 24 08          	mov    %edi,0x8(%esp)
 2d8:	8b 84 24 2c 03 00 00 	mov    0x32c(%esp),%eax
 2df:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e3:	8d 84 24 30 03 00 00 	lea    0x330(%esp),%eax
 2ea:	89 04 24             	mov    %eax,(%esp)
 2ed:	e8 64 fd ff ff       	call   56 <find_index_of_pid>
 2f2:	89 c6                	mov    %eax,%esi
        int after_index = find_index_of_pid(after.pids, after.num_processes, active_pids[i]);
 2f4:	89 7c 24 08          	mov    %edi,0x8(%esp)
 2f8:	8b 44 24 28          	mov    0x28(%esp),%eax
 2fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 300:	8d 44 24 2c          	lea    0x2c(%esp),%eax
 304:	89 04 24             	mov    %eax,(%esp)
 307:	e8 4a fd ff ff       	call   56 <find_index_of_pid>
 30c:	89 c7                	mov    %eax,%edi
        if (before_index == -1)
 30e:	83 fe ff             	cmp    $0xffffffff,%esi
 311:	75 18                	jne    32b <main+0x20a>
            printf(2, "child %d did not exist for getprocessesinfo before parent slept\n", i);
 313:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 317:	c7 44 24 04 44 0a 00 	movl   $0xa44,0x4(%esp)
 31e:	00 
 31f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 326:	e8 21 04 00 00       	call   74c <printf>
        if (after_index == -1)
 32b:	83 ff ff             	cmp    $0xffffffff,%edi
 32e:	75 18                	jne    348 <main+0x227>
            printf(2, "child %d did not exist for getprocessesinfo after parent slept\n", i);
 330:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 334:	c7 44 24 04 88 0a 00 	movl   $0xa88,0x4(%esp)
 33b:	00 
 33c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 343:	e8 04 04 00 00       	call   74c <printf>
        if (before_index == -1 || after_index == -1) {
 348:	83 fe ff             	cmp    $0xffffffff,%esi
 34b:	0f 94 c2             	sete   %dl
 34e:	83 ff ff             	cmp    $0xffffffff,%edi
 351:	0f 94 c0             	sete   %al
 354:	08 c2                	or     %al,%dl
 356:	74 24                	je     37c <main+0x25b>
            printf(1, "%d\t--unknown--\n", tickets_for[i]);
 358:	8b 84 9c b0 06 00 00 	mov    0x6b0(%esp,%ebx,4),%eax
 35f:	89 44 24 08          	mov    %eax,0x8(%esp)
 363:	c7 44 24 04 e9 08 00 	movl   $0x8e9,0x4(%esp)
 36a:	00 
 36b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 372:	e8 d5 03 00 00       	call   74c <printf>
 377:	e9 81 00 00 00       	jmp    3fd <main+0x2dc>
        } else {
            if (before.tickets[before_index] != tickets_for[i]) {
 37c:	8b 84 9c b0 06 00 00 	mov    0x6b0(%esp,%ebx,4),%eax
 383:	39 84 b4 30 05 00 00 	cmp    %eax,0x530(%esp,%esi,4)
 38a:	74 18                	je     3a4 <main+0x283>
                printf(2, "child %d had wrong number of tickets in getprocessinfo before parent slept\n", i);
 38c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 390:	c7 44 24 04 c8 0a 00 	movl   $0xac8,0x4(%esp)
 397:	00 
 398:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 39f:	e8 a8 03 00 00       	call   74c <printf>
            }
            if (after.tickets[after_index] != tickets_for[i]) {
 3a4:	8b 84 9c b0 06 00 00 	mov    0x6b0(%esp,%ebx,4),%eax
 3ab:	39 84 bc 2c 02 00 00 	cmp    %eax,0x22c(%esp,%edi,4)
 3b2:	74 18                	je     3cc <main+0x2ab>
                printf(2, "child %d had wrong number of tickets in getprocessinfo after parent slept\n", i);
 3b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 3b8:	c7 44 24 04 14 0b 00 	movl   $0xb14,0x4(%esp)
 3bf:	00 
 3c0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 3c7:	e8 80 03 00 00       	call   74c <printf>
            }
            printf(1, "%d\t%d\n", tickets_for[i], after.times_scheduled[after_index] - before.times_scheduled[before_index]);
 3cc:	8b 84 bc 2c 01 00 00 	mov    0x12c(%esp,%edi,4),%eax
 3d3:	2b 84 b4 30 04 00 00 	sub    0x430(%esp,%esi,4),%eax
 3da:	89 44 24 0c          	mov    %eax,0xc(%esp)
 3de:	8b 84 9c b0 06 00 00 	mov    0x6b0(%esp,%ebx,4),%eax
 3e5:	89 44 24 08          	mov    %eax,0x8(%esp)
 3e9:	c7 44 24 04 f9 08 00 	movl   $0x8f9,0x4(%esp)
 3f0:	00 
 3f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3f8:	e8 4f 03 00 00       	call   74c <printf>
    for (int i = 0; i < num_children; ++i) {
 3fd:	83 c3 01             	add    $0x1,%ebx
 400:	3b 5c 24 1c          	cmp    0x1c(%esp),%ebx
 404:	0f 8c c3 fe ff ff    	jl     2cd <main+0x1ac>
        }
    }
    exit();
 40a:	e8 ae 01 00 00       	call   5bd <exit>
 40f:	b8 01 00 00 00       	mov    $0x1,%eax
 414:	8d 65 f4             	lea    -0xc(%ebp),%esp
 417:	5b                   	pop    %ebx
 418:	5e                   	pop    %esi
 419:	5f                   	pop    %edi
 41a:	5d                   	pop    %ebp
 41b:	c3                   	ret    

0000041c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 41c:	55                   	push   %ebp
 41d:	89 e5                	mov    %esp,%ebp
 41f:	53                   	push   %ebx
 420:	8b 45 08             	mov    0x8(%ebp),%eax
 423:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 426:	89 c2                	mov    %eax,%edx
 428:	0f b6 19             	movzbl (%ecx),%ebx
 42b:	88 1a                	mov    %bl,(%edx)
 42d:	8d 52 01             	lea    0x1(%edx),%edx
 430:	8d 49 01             	lea    0x1(%ecx),%ecx
 433:	84 db                	test   %bl,%bl
 435:	75 f1                	jne    428 <strcpy+0xc>
    ;
  return os;
}
 437:	5b                   	pop    %ebx
 438:	5d                   	pop    %ebp
 439:	c3                   	ret    

0000043a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 43a:	55                   	push   %ebp
 43b:	89 e5                	mov    %esp,%ebp
 43d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 440:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 443:	eb 06                	jmp    44b <strcmp+0x11>
    p++, q++;
 445:	83 c1 01             	add    $0x1,%ecx
 448:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 44b:	0f b6 01             	movzbl (%ecx),%eax
 44e:	84 c0                	test   %al,%al
 450:	74 04                	je     456 <strcmp+0x1c>
 452:	3a 02                	cmp    (%edx),%al
 454:	74 ef                	je     445 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 456:	0f b6 c0             	movzbl %al,%eax
 459:	0f b6 12             	movzbl (%edx),%edx
 45c:	29 d0                	sub    %edx,%eax
}
 45e:	5d                   	pop    %ebp
 45f:	c3                   	ret    

00000460 <strlen>:

uint
strlen(const char *s)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 466:	ba 00 00 00 00       	mov    $0x0,%edx
 46b:	eb 03                	jmp    470 <strlen+0x10>
 46d:	83 c2 01             	add    $0x1,%edx
 470:	89 d0                	mov    %edx,%eax
 472:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 476:	75 f5                	jne    46d <strlen+0xd>
    ;
  return n;
}
 478:	5d                   	pop    %ebp
 479:	c3                   	ret    

0000047a <memset>:

void*
memset(void *dst, int c, uint n)
{
 47a:	55                   	push   %ebp
 47b:	89 e5                	mov    %esp,%ebp
 47d:	57                   	push   %edi
 47e:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 481:	89 d7                	mov    %edx,%edi
 483:	8b 4d 10             	mov    0x10(%ebp),%ecx
 486:	8b 45 0c             	mov    0xc(%ebp),%eax
 489:	fc                   	cld    
 48a:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 48c:	89 d0                	mov    %edx,%eax
 48e:	5f                   	pop    %edi
 48f:	5d                   	pop    %ebp
 490:	c3                   	ret    

00000491 <strchr>:

char*
strchr(const char *s, char c)
{
 491:	55                   	push   %ebp
 492:	89 e5                	mov    %esp,%ebp
 494:	8b 45 08             	mov    0x8(%ebp),%eax
 497:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 49b:	eb 07                	jmp    4a4 <strchr+0x13>
    if(*s == c)
 49d:	38 ca                	cmp    %cl,%dl
 49f:	74 0f                	je     4b0 <strchr+0x1f>
  for(; *s; s++)
 4a1:	83 c0 01             	add    $0x1,%eax
 4a4:	0f b6 10             	movzbl (%eax),%edx
 4a7:	84 d2                	test   %dl,%dl
 4a9:	75 f2                	jne    49d <strchr+0xc>
      return (char*)s;
  return 0;
 4ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4b0:	5d                   	pop    %ebp
 4b1:	c3                   	ret    

000004b2 <gets>:

char*
gets(char *buf, int max)
{
 4b2:	55                   	push   %ebp
 4b3:	89 e5                	mov    %esp,%ebp
 4b5:	57                   	push   %edi
 4b6:	56                   	push   %esi
 4b7:	53                   	push   %ebx
 4b8:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4bb:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
 4c0:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
 4c3:	eb 36                	jmp    4fb <gets+0x49>
    cc = read(0, &c, 1);
 4c5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4cc:	00 
 4cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
 4d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4d8:	e8 f8 00 00 00       	call   5d5 <read>
    if(cc < 1)
 4dd:	85 c0                	test   %eax,%eax
 4df:	7e 26                	jle    507 <gets+0x55>
      break;
    buf[i++] = c;
 4e1:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 4e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4e8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
 4eb:	3c 0a                	cmp    $0xa,%al
 4ed:	0f 94 c2             	sete   %dl
 4f0:	3c 0d                	cmp    $0xd,%al
 4f2:	0f 94 c0             	sete   %al
    buf[i++] = c;
 4f5:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 4f7:	08 c2                	or     %al,%dl
 4f9:	75 0a                	jne    505 <gets+0x53>
  for(i=0; i+1 < max; ){
 4fb:	8d 73 01             	lea    0x1(%ebx),%esi
 4fe:	3b 75 0c             	cmp    0xc(%ebp),%esi
 501:	7c c2                	jl     4c5 <gets+0x13>
 503:	eb 02                	jmp    507 <gets+0x55>
    buf[i++] = c;
 505:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
 507:	8b 45 08             	mov    0x8(%ebp),%eax
 50a:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 50e:	83 c4 2c             	add    $0x2c,%esp
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
 51b:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 51e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 525:	00 
 526:	8b 45 08             	mov    0x8(%ebp),%eax
 529:	89 04 24             	mov    %eax,(%esp)
 52c:	e8 cc 00 00 00       	call   5fd <open>
 531:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 533:	85 c0                	test   %eax,%eax
 535:	78 1d                	js     554 <stat+0x3e>
    return -1;
  r = fstat(fd, st);
 537:	8b 45 0c             	mov    0xc(%ebp),%eax
 53a:	89 44 24 04          	mov    %eax,0x4(%esp)
 53e:	89 1c 24             	mov    %ebx,(%esp)
 541:	e8 cf 00 00 00       	call   615 <fstat>
 546:	89 c6                	mov    %eax,%esi
  close(fd);
 548:	89 1c 24             	mov    %ebx,(%esp)
 54b:	e8 95 00 00 00       	call   5e5 <close>
  return r;
 550:	89 f0                	mov    %esi,%eax
 552:	eb 05                	jmp    559 <stat+0x43>
    return -1;
 554:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 559:	83 c4 10             	add    $0x10,%esp
 55c:	5b                   	pop    %ebx
 55d:	5e                   	pop    %esi
 55e:	5d                   	pop    %ebp
 55f:	c3                   	ret    

00000560 <atoi>:

int
atoi(const char *s)
{
 560:	55                   	push   %ebp
 561:	89 e5                	mov    %esp,%ebp
 563:	53                   	push   %ebx
 564:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
 567:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 56c:	eb 0f                	jmp    57d <atoi+0x1d>
    n = n*10 + *s++ - '0';
 56e:	8d 04 80             	lea    (%eax,%eax,4),%eax
 571:	01 c0                	add    %eax,%eax
 573:	83 c2 01             	add    $0x1,%edx
 576:	0f be c9             	movsbl %cl,%ecx
 579:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
 57d:	0f b6 0a             	movzbl (%edx),%ecx
 580:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 583:	80 fb 09             	cmp    $0x9,%bl
 586:	76 e6                	jbe    56e <atoi+0xe>
  return n;
}
 588:	5b                   	pop    %ebx
 589:	5d                   	pop    %ebp
 58a:	c3                   	ret    

0000058b <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 58b:	55                   	push   %ebp
 58c:	89 e5                	mov    %esp,%ebp
 58e:	56                   	push   %esi
 58f:	53                   	push   %ebx
 590:	8b 45 08             	mov    0x8(%ebp),%eax
 593:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 596:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 599:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 59b:	eb 0d                	jmp    5aa <memmove+0x1f>
    *dst++ = *src++;
 59d:	0f b6 13             	movzbl (%ebx),%edx
 5a0:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
 5a2:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
 5a4:	8d 5b 01             	lea    0x1(%ebx),%ebx
 5a7:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 5aa:	8d 72 ff             	lea    -0x1(%edx),%esi
 5ad:	85 d2                	test   %edx,%edx
 5af:	7f ec                	jg     59d <memmove+0x12>
  return vdst;
}
 5b1:	5b                   	pop    %ebx
 5b2:	5e                   	pop    %esi
 5b3:	5d                   	pop    %ebp
 5b4:	c3                   	ret    

000005b5 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5b5:	b8 01 00 00 00       	mov    $0x1,%eax
 5ba:	cd 40                	int    $0x40
 5bc:	c3                   	ret    

000005bd <exit>:
SYSCALL(exit)
 5bd:	b8 02 00 00 00       	mov    $0x2,%eax
 5c2:	cd 40                	int    $0x40
 5c4:	c3                   	ret    

000005c5 <wait>:
SYSCALL(wait)
 5c5:	b8 03 00 00 00       	mov    $0x3,%eax
 5ca:	cd 40                	int    $0x40
 5cc:	c3                   	ret    

000005cd <pipe>:
SYSCALL(pipe)
 5cd:	b8 04 00 00 00       	mov    $0x4,%eax
 5d2:	cd 40                	int    $0x40
 5d4:	c3                   	ret    

000005d5 <read>:
SYSCALL(read)
 5d5:	b8 05 00 00 00       	mov    $0x5,%eax
 5da:	cd 40                	int    $0x40
 5dc:	c3                   	ret    

000005dd <write>:
SYSCALL(write)
 5dd:	b8 10 00 00 00       	mov    $0x10,%eax
 5e2:	cd 40                	int    $0x40
 5e4:	c3                   	ret    

000005e5 <close>:
SYSCALL(close)
 5e5:	b8 15 00 00 00       	mov    $0x15,%eax
 5ea:	cd 40                	int    $0x40
 5ec:	c3                   	ret    

000005ed <kill>:
SYSCALL(kill)
 5ed:	b8 06 00 00 00       	mov    $0x6,%eax
 5f2:	cd 40                	int    $0x40
 5f4:	c3                   	ret    

000005f5 <exec>:
SYSCALL(exec)
 5f5:	b8 07 00 00 00       	mov    $0x7,%eax
 5fa:	cd 40                	int    $0x40
 5fc:	c3                   	ret    

000005fd <open>:
SYSCALL(open)
 5fd:	b8 0f 00 00 00       	mov    $0xf,%eax
 602:	cd 40                	int    $0x40
 604:	c3                   	ret    

00000605 <mknod>:
SYSCALL(mknod)
 605:	b8 11 00 00 00       	mov    $0x11,%eax
 60a:	cd 40                	int    $0x40
 60c:	c3                   	ret    

0000060d <unlink>:
SYSCALL(unlink)
 60d:	b8 12 00 00 00       	mov    $0x12,%eax
 612:	cd 40                	int    $0x40
 614:	c3                   	ret    

00000615 <fstat>:
SYSCALL(fstat)
 615:	b8 08 00 00 00       	mov    $0x8,%eax
 61a:	cd 40                	int    $0x40
 61c:	c3                   	ret    

0000061d <link>:
SYSCALL(link)
 61d:	b8 13 00 00 00       	mov    $0x13,%eax
 622:	cd 40                	int    $0x40
 624:	c3                   	ret    

00000625 <mkdir>:
SYSCALL(mkdir)
 625:	b8 14 00 00 00       	mov    $0x14,%eax
 62a:	cd 40                	int    $0x40
 62c:	c3                   	ret    

0000062d <chdir>:
SYSCALL(chdir)
 62d:	b8 09 00 00 00       	mov    $0x9,%eax
 632:	cd 40                	int    $0x40
 634:	c3                   	ret    

00000635 <dup>:
SYSCALL(dup)
 635:	b8 0a 00 00 00       	mov    $0xa,%eax
 63a:	cd 40                	int    $0x40
 63c:	c3                   	ret    

0000063d <getpid>:
SYSCALL(getpid)
 63d:	b8 0b 00 00 00       	mov    $0xb,%eax
 642:	cd 40                	int    $0x40
 644:	c3                   	ret    

00000645 <sbrk>:
SYSCALL(sbrk)
 645:	b8 0c 00 00 00       	mov    $0xc,%eax
 64a:	cd 40                	int    $0x40
 64c:	c3                   	ret    

0000064d <sleep>:
SYSCALL(sleep)
 64d:	b8 0d 00 00 00       	mov    $0xd,%eax
 652:	cd 40                	int    $0x40
 654:	c3                   	ret    

00000655 <uptime>:
SYSCALL(uptime)
 655:	b8 0e 00 00 00       	mov    $0xe,%eax
 65a:	cd 40                	int    $0x40
 65c:	c3                   	ret    

0000065d <yield>:
SYSCALL(yield)
 65d:	b8 16 00 00 00       	mov    $0x16,%eax
 662:	cd 40                	int    $0x40
 664:	c3                   	ret    

00000665 <shutdown>:
SYSCALL(shutdown)
 665:	b8 17 00 00 00       	mov    $0x17,%eax
 66a:	cd 40                	int    $0x40
 66c:	c3                   	ret    

0000066d <writecount>:
SYSCALL(writecount)
 66d:	b8 18 00 00 00       	mov    $0x18,%eax
 672:	cd 40                	int    $0x40
 674:	c3                   	ret    

00000675 <setwritecount>:
SYSCALL(setwritecount)
 675:	b8 19 00 00 00       	mov    $0x19,%eax
 67a:	cd 40                	int    $0x40
 67c:	c3                   	ret    

0000067d <settickets>:
SYSCALL(settickets)
 67d:	b8 1a 00 00 00       	mov    $0x1a,%eax
 682:	cd 40                	int    $0x40
 684:	c3                   	ret    

00000685 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 685:	b8 1b 00 00 00       	mov    $0x1b,%eax
 68a:	cd 40                	int    $0x40
 68c:	c3                   	ret    

0000068d <getpagetableentry>:
SYSCALL(getpagetableentry)
 68d:	b8 1c 00 00 00       	mov    $0x1c,%eax
 692:	cd 40                	int    $0x40
 694:	c3                   	ret    

00000695 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 695:	b8 1d 00 00 00       	mov    $0x1d,%eax
 69a:	cd 40                	int    $0x40
 69c:	c3                   	ret    

0000069d <dumppagetable>:
 69d:	b8 1e 00 00 00       	mov    $0x1e,%eax
 6a2:	cd 40                	int    $0x40
 6a4:	c3                   	ret    
 6a5:	66 90                	xchg   %ax,%ax
 6a7:	66 90                	xchg   %ax,%ax
 6a9:	66 90                	xchg   %ax,%ax
 6ab:	66 90                	xchg   %ax,%ax
 6ad:	66 90                	xchg   %ax,%ax
 6af:	90                   	nop

000006b0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6b0:	55                   	push   %ebp
 6b1:	89 e5                	mov    %esp,%ebp
 6b3:	83 ec 18             	sub    $0x18,%esp
 6b6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 6b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6c0:	00 
 6c1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 6c4:	89 54 24 04          	mov    %edx,0x4(%esp)
 6c8:	89 04 24             	mov    %eax,(%esp)
 6cb:	e8 0d ff ff ff       	call   5dd <write>
}
 6d0:	c9                   	leave  
 6d1:	c3                   	ret    

000006d2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6d2:	55                   	push   %ebp
 6d3:	89 e5                	mov    %esp,%ebp
 6d5:	57                   	push   %edi
 6d6:	56                   	push   %esi
 6d7:	53                   	push   %ebx
 6d8:	83 ec 2c             	sub    $0x2c,%esp
 6db:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 6e1:	0f 95 c3             	setne  %bl
 6e4:	89 d0                	mov    %edx,%eax
 6e6:	c1 e8 1f             	shr    $0x1f,%eax
 6e9:	84 c3                	test   %al,%bl
 6eb:	74 0b                	je     6f8 <printint+0x26>
    neg = 1;
    x = -xx;
 6ed:	f7 da                	neg    %edx
    neg = 1;
 6ef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 6f6:	eb 07                	jmp    6ff <printint+0x2d>
  neg = 0;
 6f8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 6ff:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 704:	8d 5e 01             	lea    0x1(%esi),%ebx
 707:	89 d0                	mov    %edx,%eax
 709:	ba 00 00 00 00       	mov    $0x0,%edx
 70e:	f7 f1                	div    %ecx
 710:	0f b6 92 67 0b 00 00 	movzbl 0xb67(%edx),%edx
 717:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 71b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 71d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 71f:	85 c0                	test   %eax,%eax
 721:	75 e1                	jne    704 <printint+0x32>
  if(neg)
 723:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 727:	74 16                	je     73f <printint+0x6d>
    buf[i++] = '-';
 729:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 72e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 731:	eb 0c                	jmp    73f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 733:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 738:	89 f8                	mov    %edi,%eax
 73a:	e8 71 ff ff ff       	call   6b0 <putc>
  while(--i >= 0)
 73f:	83 eb 01             	sub    $0x1,%ebx
 742:	79 ef                	jns    733 <printint+0x61>
}
 744:	83 c4 2c             	add    $0x2c,%esp
 747:	5b                   	pop    %ebx
 748:	5e                   	pop    %esi
 749:	5f                   	pop    %edi
 74a:	5d                   	pop    %ebp
 74b:	c3                   	ret    

0000074c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 74c:	55                   	push   %ebp
 74d:	89 e5                	mov    %esp,%ebp
 74f:	57                   	push   %edi
 750:	56                   	push   %esi
 751:	53                   	push   %ebx
 752:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 755:	8d 45 10             	lea    0x10(%ebp),%eax
 758:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 75b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 760:	be 00 00 00 00       	mov    $0x0,%esi
 765:	e9 23 01 00 00       	jmp    88d <printf+0x141>
    c = fmt[i] & 0xff;
 76a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 76d:	85 ff                	test   %edi,%edi
 76f:	75 19                	jne    78a <printf+0x3e>
      if(c == '%'){
 771:	83 f8 25             	cmp    $0x25,%eax
 774:	0f 84 0b 01 00 00    	je     885 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 77a:	0f be d3             	movsbl %bl,%edx
 77d:	8b 45 08             	mov    0x8(%ebp),%eax
 780:	e8 2b ff ff ff       	call   6b0 <putc>
 785:	e9 00 01 00 00       	jmp    88a <printf+0x13e>
      }
    } else if(state == '%'){
 78a:	83 ff 25             	cmp    $0x25,%edi
 78d:	0f 85 f7 00 00 00    	jne    88a <printf+0x13e>
      if(c == 'd'){
 793:	83 f8 64             	cmp    $0x64,%eax
 796:	75 26                	jne    7be <printf+0x72>
        printint(fd, *ap, 10, 1);
 798:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79b:	8b 10                	mov    (%eax),%edx
 79d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 7a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 7a9:	8b 45 08             	mov    0x8(%ebp),%eax
 7ac:	e8 21 ff ff ff       	call   6d2 <printint>
        ap++;
 7b1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 7b5:	66 bf 00 00          	mov    $0x0,%di
 7b9:	e9 cc 00 00 00       	jmp    88a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 7be:	83 f8 78             	cmp    $0x78,%eax
 7c1:	0f 94 c1             	sete   %cl
 7c4:	83 f8 70             	cmp    $0x70,%eax
 7c7:	0f 94 c2             	sete   %dl
 7ca:	08 d1                	or     %dl,%cl
 7cc:	74 27                	je     7f5 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 7ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7d1:	8b 10                	mov    (%eax),%edx
 7d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 7da:	b9 10 00 00 00       	mov    $0x10,%ecx
 7df:	8b 45 08             	mov    0x8(%ebp),%eax
 7e2:	e8 eb fe ff ff       	call   6d2 <printint>
        ap++;
 7e7:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 7eb:	bf 00 00 00 00       	mov    $0x0,%edi
 7f0:	e9 95 00 00 00       	jmp    88a <printf+0x13e>
      } else if(c == 's'){
 7f5:	83 f8 73             	cmp    $0x73,%eax
 7f8:	75 37                	jne    831 <printf+0xe5>
        s = (char*)*ap;
 7fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7fd:	8b 18                	mov    (%eax),%ebx
        ap++;
 7ff:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 803:	85 db                	test   %ebx,%ebx
 805:	75 19                	jne    820 <printf+0xd4>
          s = "(null)";
 807:	bb 60 0b 00 00       	mov    $0xb60,%ebx
 80c:	8b 7d 08             	mov    0x8(%ebp),%edi
 80f:	eb 12                	jmp    823 <printf+0xd7>
          putc(fd, *s);
 811:	0f be d2             	movsbl %dl,%edx
 814:	89 f8                	mov    %edi,%eax
 816:	e8 95 fe ff ff       	call   6b0 <putc>
          s++;
 81b:	83 c3 01             	add    $0x1,%ebx
 81e:	eb 03                	jmp    823 <printf+0xd7>
 820:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 823:	0f b6 13             	movzbl (%ebx),%edx
 826:	84 d2                	test   %dl,%dl
 828:	75 e7                	jne    811 <printf+0xc5>
      state = 0;
 82a:	bf 00 00 00 00       	mov    $0x0,%edi
 82f:	eb 59                	jmp    88a <printf+0x13e>
      } else if(c == 'c'){
 831:	83 f8 63             	cmp    $0x63,%eax
 834:	75 19                	jne    84f <printf+0x103>
        putc(fd, *ap);
 836:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 839:	0f be 10             	movsbl (%eax),%edx
 83c:	8b 45 08             	mov    0x8(%ebp),%eax
 83f:	e8 6c fe ff ff       	call   6b0 <putc>
        ap++;
 844:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 848:	bf 00 00 00 00       	mov    $0x0,%edi
 84d:	eb 3b                	jmp    88a <printf+0x13e>
      } else if(c == '%'){
 84f:	83 f8 25             	cmp    $0x25,%eax
 852:	75 12                	jne    866 <printf+0x11a>
        putc(fd, c);
 854:	0f be d3             	movsbl %bl,%edx
 857:	8b 45 08             	mov    0x8(%ebp),%eax
 85a:	e8 51 fe ff ff       	call   6b0 <putc>
      state = 0;
 85f:	bf 00 00 00 00       	mov    $0x0,%edi
 864:	eb 24                	jmp    88a <printf+0x13e>
        putc(fd, '%');
 866:	ba 25 00 00 00       	mov    $0x25,%edx
 86b:	8b 45 08             	mov    0x8(%ebp),%eax
 86e:	e8 3d fe ff ff       	call   6b0 <putc>
        putc(fd, c);
 873:	0f be d3             	movsbl %bl,%edx
 876:	8b 45 08             	mov    0x8(%ebp),%eax
 879:	e8 32 fe ff ff       	call   6b0 <putc>
      state = 0;
 87e:	bf 00 00 00 00       	mov    $0x0,%edi
 883:	eb 05                	jmp    88a <printf+0x13e>
        state = '%';
 885:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 88a:	83 c6 01             	add    $0x1,%esi
 88d:	89 f0                	mov    %esi,%eax
 88f:	03 45 0c             	add    0xc(%ebp),%eax
 892:	0f b6 18             	movzbl (%eax),%ebx
 895:	84 db                	test   %bl,%bl
 897:	0f 85 cd fe ff ff    	jne    76a <printf+0x1e>
    }
  }
}
 89d:	83 c4 1c             	add    $0x1c,%esp
 8a0:	5b                   	pop    %ebx
 8a1:	5e                   	pop    %esi
 8a2:	5f                   	pop    %edi
 8a3:	5d                   	pop    %ebp
 8a4:	c3                   	ret    
