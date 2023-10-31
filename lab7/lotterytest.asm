
_lotterytest:     file format elf32-i386


Disassembly of section .text:

00000000 <run_forever>:
        yield();
    }
}

__attribute__((noreturn))
void run_forever() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
    while (1) {
        __asm__("");
   3:	eb fe                	jmp    3 <run_forever+0x3>

00000005 <yield_forever>:
void yield_forever() {
   5:	55                   	push   %ebp
   6:	89 e5                	mov    %esp,%ebp
   8:	83 ec 08             	sub    $0x8,%esp
        yield();
   b:	e8 57 0a 00 00       	call   a67 <yield>
  10:	eb f9                	jmp    b <yield_forever+0x6>

00000012 <iowait_forever>:
    }
}

__attribute__((noreturn))
void iowait_forever() {
  12:	55                   	push   %ebp
  13:	89 e5                	mov    %esp,%ebp
  15:	53                   	push   %ebx
  16:	83 ec 24             	sub    $0x24,%esp
    int fds[2];
    pipe(fds);
  19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1c:	89 04 24             	mov    %eax,(%esp)
  1f:	e8 b3 09 00 00       	call   9d7 <pipe>
    while (1) {
        char temp[1];
        read(fds[0], temp, 0);
  24:	8d 5d ef             	lea    -0x11(%ebp),%ebx
  27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  2e:	00 
  2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 a1 09 00 00       	call   9df <read>
  3e:	eb e7                	jmp    27 <iowait_forever+0x15>

00000040 <exit_fast>:
    }
}

__attribute__((noreturn))
void exit_fast() {
  40:	55                   	push   %ebp
  41:	89 e5                	mov    %esp,%ebp
  43:	83 ec 08             	sub    $0x8,%esp
    exit();
  46:	e8 7c 09 00 00       	call   9c7 <exit>

0000004b <spawn>:
}


int spawn(int tickets, function_type function) {
  4b:	55                   	push   %ebp
  4c:	89 e5                	mov    %esp,%ebp
  4e:	83 ec 18             	sub    $0x18,%esp
    int pid = fork();
  51:	e8 69 09 00 00       	call   9bf <fork>
    if (pid == 0) {
  56:	85 c0                	test   %eax,%eax
  58:	75 1b                	jne    75 <spawn+0x2a>
        settickets(tickets);
  5a:	8b 45 08             	mov    0x8(%ebp),%eax
  5d:	89 04 24             	mov    %eax,(%esp)
  60:	e8 22 0a 00 00       	call   a87 <settickets>
        yield();
  65:	e8 fd 09 00 00       	call   a67 <yield>
        (*function)();
  6a:	ff 55 0c             	call   *0xc(%ebp)
  6d:	8d 76 00             	lea    0x0(%esi),%esi
        exit();
  70:	e8 52 09 00 00       	call   9c7 <exit>
    } else if (pid != -1) {
  75:	83 f8 ff             	cmp    $0xffffffff,%eax
  78:	75 19                	jne    93 <spawn+0x48>
        return pid;
    } else {
        printf(2, "error in fork\n");
  7a:	c7 44 24 04 40 0e 00 	movl   $0xe40,0x4(%esp)
  81:	00 
  82:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  89:	e8 be 0a 00 00       	call   b4c <printf>
        return -1;
  8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
}
  93:	c9                   	leave  
  94:	c3                   	ret    

00000095 <find_index_of_pid>:

int find_index_of_pid(int *list, int list_size, int pid) {
  95:	55                   	push   %ebp
  96:	89 e5                	mov    %esp,%ebp
  98:	53                   	push   %ebx
  99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
    for (int i = 0; i < list_size; ++i) {
  a2:	b8 00 00 00 00       	mov    $0x0,%eax
  a7:	eb 08                	jmp    b1 <find_index_of_pid+0x1c>
        if (list[i] == pid)
  a9:	39 0c 83             	cmp    %ecx,(%ebx,%eax,4)
  ac:	74 0c                	je     ba <find_index_of_pid+0x25>
    for (int i = 0; i < list_size; ++i) {
  ae:	83 c0 01             	add    $0x1,%eax
  b1:	39 d0                	cmp    %edx,%eax
  b3:	7c f4                	jl     a9 <find_index_of_pid+0x14>
            return i;
    }
    return -1;
  b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  ba:	5b                   	pop    %ebx
  bb:	5d                   	pop    %ebp
  bc:	c3                   	ret    

000000bd <wait_for_ticket_counts>:

void wait_for_ticket_counts(int num_children, int *pids, int *tickets) {
  bd:	55                   	push   %ebp
  be:	89 e5                	mov    %esp,%ebp
  c0:	57                   	push   %edi
  c1:	56                   	push   %esi
  c2:	53                   	push   %ebx
  c3:	81 ec 3c 03 00 00    	sub    $0x33c,%esp
  c9:	8b 75 0c             	mov    0xc(%ebp),%esi
    /* temporarily lower our share to give other processes more of a chance to run
     * their settickets() call */
    settickets(NOT_AS_LARGE_TICKET_COUNT);
  cc:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  d3:	e8 af 09 00 00       	call   a87 <settickets>
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
  d8:	c7 85 d0 fc ff ff 00 	movl   $0x0,-0x330(%ebp)
  df:	00 00 00 
        yield();
        int done = 1;
        struct processes_info info;
        getprocessesinfo(&info);
        for (int i = 0; i < num_children; ++i) {
            int index = find_index_of_pid(info.pids, info.num_processes, pids[i]);
  e2:	8d bd e8 fc ff ff    	lea    -0x318(%ebp),%edi
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
  e8:	eb 6e                	jmp    158 <wait_for_ticket_counts+0x9b>
        yield();
  ea:	e8 78 09 00 00       	call   a67 <yield>
        getprocessesinfo(&info);
  ef:	8d 85 e4 fc ff ff    	lea    -0x31c(%ebp),%eax
  f5:	89 04 24             	mov    %eax,(%esp)
  f8:	e8 92 09 00 00       	call   a8f <getprocessesinfo>
        for (int i = 0; i < num_children; ++i) {
  fd:	bb 00 00 00 00       	mov    $0x0,%ebx
        int done = 1;
 102:	c7 85 d4 fc ff ff 01 	movl   $0x1,-0x32c(%ebp)
 109:	00 00 00 
        for (int i = 0; i < num_children; ++i) {
 10c:	eb 35                	jmp    143 <wait_for_ticket_counts+0x86>
            int index = find_index_of_pid(info.pids, info.num_processes, pids[i]);
 10e:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
 111:	89 44 24 08          	mov    %eax,0x8(%esp)
 115:	8b 85 e4 fc ff ff    	mov    -0x31c(%ebp),%eax
 11b:	89 44 24 04          	mov    %eax,0x4(%esp)
 11f:	89 3c 24             	mov    %edi,(%esp)
 122:	e8 6e ff ff ff       	call   95 <find_index_of_pid>
            if (info.tickets[index] != tickets[i]) done = 0;
 127:	8b 55 10             	mov    0x10(%ebp),%edx
 12a:	8b 0c 9a             	mov    (%edx,%ebx,4),%ecx
 12d:	39 8c 85 e8 fe ff ff 	cmp    %ecx,-0x118(%ebp,%eax,4)
 134:	74 0a                	je     140 <wait_for_ticket_counts+0x83>
 136:	c7 85 d4 fc ff ff 00 	movl   $0x0,-0x32c(%ebp)
 13d:	00 00 00 
        for (int i = 0; i < num_children; ++i) {
 140:	83 c3 01             	add    $0x1,%ebx
 143:	3b 5d 08             	cmp    0x8(%ebp),%ebx
 146:	7c c6                	jl     10e <wait_for_ticket_counts+0x51>
        }
        if (done)
 148:	83 bd d4 fc ff ff 00 	cmpl   $0x0,-0x32c(%ebp)
 14f:	75 10                	jne    161 <wait_for_ticket_counts+0xa4>
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
 151:	83 85 d0 fc ff ff 01 	addl   $0x1,-0x330(%ebp)
 158:	83 bd d0 fc ff ff 63 	cmpl   $0x63,-0x330(%ebp)
 15f:	7e 89                	jle    ea <wait_for_ticket_counts+0x2d>
            break;
    }
    settickets(LARGE_TICKET_COUNT);
 161:	c7 04 24 a0 86 01 00 	movl   $0x186a0,(%esp)
 168:	e8 1a 09 00 00       	call   a87 <settickets>
}
 16d:	81 c4 3c 03 00 00    	add    $0x33c,%esp
 173:	5b                   	pop    %ebx
 174:	5e                   	pop    %esi
 175:	5f                   	pop    %edi
 176:	5d                   	pop    %ebp
 177:	c3                   	ret    

00000178 <check>:

void check(struct test_case* test, int passed_p, const char *description) {
 178:	55                   	push   %ebp
 179:	89 e5                	mov    %esp,%ebp
 17b:	83 ec 18             	sub    $0x18,%esp
 17e:	8b 45 08             	mov    0x8(%ebp),%eax
    test->total_tests++;
 181:	83 40 04 01          	addl   $0x1,0x4(%eax)
    if (!passed_p) {
 185:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 189:	75 25                	jne    1b0 <check+0x38>
        test->errors++;
 18b:	83 40 08 01          	addl   $0x1,0x8(%eax)
        printf(1, "*** TEST FAILURE: for scenario '%s': %s\n", test->name, description);
 18f:	8b 55 10             	mov    0x10(%ebp),%edx
 192:	89 54 24 0c          	mov    %edx,0xc(%esp)
 196:	8b 00                	mov    (%eax),%eax
 198:	89 44 24 08          	mov    %eax,0x8(%esp)
 19c:	c7 44 24 04 08 0f 00 	movl   $0xf08,0x4(%esp)
 1a3:	00 
 1a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ab:	e8 9c 09 00 00       	call   b4c <printf>
    }
}
 1b0:	c9                   	leave  
 1b1:	c3                   	ret    

000001b2 <execute_and_get_info>:

void execute_and_get_info(
        struct test_case* test, int *pids,
        struct processes_info *before,
        struct processes_info *after) {
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	57                   	push   %edi
 1b6:	56                   	push   %esi
 1b7:	53                   	push   %ebx
 1b8:	83 ec 1c             	sub    $0x1c,%esp
 1bb:	8b 75 08             	mov    0x8(%ebp),%esi
    settickets(LARGE_TICKET_COUNT);
 1be:	c7 04 24 a0 86 01 00 	movl   $0x186a0,(%esp)
 1c5:	e8 bd 08 00 00       	call   a87 <settickets>
    for (int i = 0; i < test->num_children; ++i) {
 1ca:	bb 00 00 00 00       	mov    $0x0,%ebx
 1cf:	eb 22                	jmp    1f3 <execute_and_get_info+0x41>
        pids[i] = spawn(test->tickets[i], test->functions[i]);
 1d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d4:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
 1d7:	8b 84 9e 94 01 00 00 	mov    0x194(%esi,%ebx,4),%eax
 1de:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e2:	8b 44 9e 10          	mov    0x10(%esi,%ebx,4),%eax
 1e6:	89 04 24             	mov    %eax,(%esp)
 1e9:	e8 5d fe ff ff       	call   4b <spawn>
 1ee:	89 07                	mov    %eax,(%edi)
    for (int i = 0; i < test->num_children; ++i) {
 1f0:	83 c3 01             	add    $0x1,%ebx
 1f3:	8b 46 0c             	mov    0xc(%esi),%eax
 1f6:	39 d8                	cmp    %ebx,%eax
 1f8:	7f d7                	jg     1d1 <execute_and_get_info+0x1f>
    }
    wait_for_ticket_counts(test->num_children, pids, test->tickets);
 1fa:	8d 56 10             	lea    0x10(%esi),%edx
 1fd:	89 54 24 08          	mov    %edx,0x8(%esp)
 201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 204:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 208:	89 04 24             	mov    %eax,(%esp)
 20b:	e8 ad fe ff ff       	call   bd <wait_for_ticket_counts>
    before->num_processes = after->num_processes = -1;
 210:	8b 45 14             	mov    0x14(%ebp),%eax
 213:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
 219:	8b 45 10             	mov    0x10(%ebp),%eax
 21c:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    sleep(WARMUP_TIME);
 222:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
 229:	e8 29 08 00 00       	call   a57 <sleep>
    getprocessesinfo(before);
 22e:	8b 45 10             	mov    0x10(%ebp),%eax
 231:	89 04 24             	mov    %eax,(%esp)
 234:	e8 56 08 00 00       	call   a8f <getprocessesinfo>
    sleep(SLEEP_TIME);
 239:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
 240:	e8 12 08 00 00       	call   a57 <sleep>
    getprocessesinfo(after);
 245:	8b 45 14             	mov    0x14(%ebp),%eax
 248:	89 04 24             	mov    %eax,(%esp)
 24b:	e8 3f 08 00 00       	call   a8f <getprocessesinfo>
    for (int i = 0; i < test->num_children; ++i) {
 250:	bb 00 00 00 00       	mov    $0x0,%ebx
 255:	8b 7d 0c             	mov    0xc(%ebp),%edi
 258:	eb 0e                	jmp    268 <execute_and_get_info+0xb6>
        kill(pids[i]);
 25a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
 25d:	89 04 24             	mov    %eax,(%esp)
 260:	e8 92 07 00 00       	call   9f7 <kill>
    for (int i = 0; i < test->num_children; ++i) {
 265:	83 c3 01             	add    $0x1,%ebx
 268:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 26b:	7f ed                	jg     25a <execute_and_get_info+0xa8>
 26d:	bb 00 00 00 00       	mov    $0x0,%ebx
 272:	eb 08                	jmp    27c <execute_and_get_info+0xca>
    }
    for (int i = 0; i < test->num_children; ++i) {
        wait();
 274:	e8 56 07 00 00       	call   9cf <wait>
    for (int i = 0; i < test->num_children; ++i) {
 279:	83 c3 01             	add    $0x1,%ebx
 27c:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 27f:	7f f3                	jg     274 <execute_and_get_info+0xc2>
    }
}
 281:	83 c4 1c             	add    $0x1c,%esp
 284:	5b                   	pop    %ebx
 285:	5e                   	pop    %esi
 286:	5f                   	pop    %edi
 287:	5d                   	pop    %ebp
 288:	c3                   	ret    

00000289 <count_schedules>:

void count_schedules(
        struct test_case *test, int *pids,
        struct processes_info *before,
        struct processes_info *after) {
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	57                   	push   %edi
 28d:	56                   	push   %esi
 28e:	53                   	push   %ebx
 28f:	83 ec 2c             	sub    $0x2c,%esp
 292:	8b 7d 08             	mov    0x8(%ebp),%edi
    test->total_actual_schedules = 0;
 295:	c7 87 90 01 00 00 00 	movl   $0x0,0x190(%edi)
 29c:	00 00 00 
    for (int i = 0; i < test->num_children; ++i) {
 29f:	bb 00 00 00 00       	mov    $0x0,%ebx
        int before_index = find_index_of_pid(before->pids, before->num_processes, pids[i]);
 2a4:	8b 45 10             	mov    0x10(%ebp),%eax
 2a7:	83 c0 04             	add    $0x4,%eax
 2aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
        int after_index = find_index_of_pid(after->pids, after->num_processes, pids[i]);
 2ad:	8b 45 14             	mov    0x14(%ebp),%eax
 2b0:	83 c0 04             	add    $0x4,%eax
 2b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
    for (int i = 0; i < test->num_children; ++i) {
 2b6:	e9 ec 00 00 00       	jmp    3a7 <count_schedules+0x11e>
        int before_index = find_index_of_pid(before->pids, before->num_processes, pids[i]);
 2bb:	8b 45 0c             	mov    0xc(%ebp),%eax
 2be:	8b 34 98             	mov    (%eax,%ebx,4),%esi
 2c1:	8b 45 10             	mov    0x10(%ebp),%eax
 2c4:	8b 00                	mov    (%eax),%eax
 2c6:	89 74 24 08          	mov    %esi,0x8(%esp)
 2ca:	89 44 24 04          	mov    %eax,0x4(%esp)
 2ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
 2d1:	89 04 24             	mov    %eax,(%esp)
 2d4:	e8 bc fd ff ff       	call   95 <find_index_of_pid>
 2d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        int after_index = find_index_of_pid(after->pids, after->num_processes, pids[i]);
 2dc:	8b 55 14             	mov    0x14(%ebp),%edx
 2df:	8b 02                	mov    (%edx),%eax
 2e1:	89 74 24 08          	mov    %esi,0x8(%esp)
 2e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
 2ec:	89 0c 24             	mov    %ecx,(%esp)
 2ef:	e8 a1 fd ff ff       	call   95 <find_index_of_pid>
 2f4:	89 c6                	mov    %eax,%esi
 2f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        check(test,
              before_index >= 0 && after_index >= 0,
 2f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2fc:	f7 d0                	not    %eax
 2fe:	c1 e8 1f             	shr    $0x1f,%eax
 301:	f7 d6                	not    %esi
 303:	c1 ee 1f             	shr    $0x1f,%esi
        check(test,
 306:	21 c6                	and    %eax,%esi
 308:	c7 44 24 08 34 0f 00 	movl   $0xf34,0x8(%esp)
 30f:	00 
 310:	89 f0                	mov    %esi,%eax
 312:	0f b6 c0             	movzbl %al,%eax
 315:	89 44 24 04          	mov    %eax,0x4(%esp)
 319:	89 3c 24             	mov    %edi,(%esp)
 31c:	e8 57 fe ff ff       	call   178 <check>
              "subprocess's pid appeared in getprocessesinfo output");
        if (before_index >= 0 && after_index >= 0) {
 321:	89 f0                	mov    %esi,%eax
 323:	84 c0                	test   %al,%al
 325:	74 72                	je     399 <count_schedules+0x110>
            check(test,
                  test->tickets[i] == before->tickets[before_index] &&
 327:	8b 44 9f 10          	mov    0x10(%edi,%ebx,4),%eax
            check(test,
 32b:	8b 55 10             	mov    0x10(%ebp),%edx
 32e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 331:	3b 84 8a 04 02 00 00 	cmp    0x204(%edx,%ecx,4),%eax
 338:	75 16                	jne    350 <count_schedules+0xc7>
 33a:	8b 4d 14             	mov    0x14(%ebp),%ecx
 33d:	8b 55 e0             	mov    -0x20(%ebp),%edx
 340:	3b 84 91 04 02 00 00 	cmp    0x204(%ecx,%edx,4),%eax
 347:	74 0e                	je     357 <count_schedules+0xce>
 349:	b8 00 00 00 00       	mov    $0x0,%eax
 34e:	eb 0c                	jmp    35c <count_schedules+0xd3>
 350:	b8 00 00 00 00       	mov    $0x0,%eax
 355:	eb 05                	jmp    35c <count_schedules+0xd3>
 357:	b8 01 00 00 00       	mov    $0x1,%eax
 35c:	c7 44 24 08 6c 0f 00 	movl   $0xf6c,0x8(%esp)
 363:	00 
 364:	89 44 24 04          	mov    %eax,0x4(%esp)
 368:	89 3c 24             	mov    %edi,(%esp)
 36b:	e8 08 fe ff ff       	call   178 <check>
                  test->tickets[i] == after->tickets[after_index],
                  "subprocess assigned correct number of tickets");
            test->actual_schedules[i] = after->times_scheduled[after_index] - before->times_scheduled[before_index];
 370:	8b 45 14             	mov    0x14(%ebp),%eax
 373:	8b 55 e0             	mov    -0x20(%ebp),%edx
 376:	8b 84 90 04 01 00 00 	mov    0x104(%eax,%edx,4),%eax
 37d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 380:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 383:	2b 84 91 04 01 00 00 	sub    0x104(%ecx,%edx,4),%eax
 38a:	89 84 9f 10 01 00 00 	mov    %eax,0x110(%edi,%ebx,4)
            test->total_actual_schedules += test->actual_schedules[i];
 391:	01 87 90 01 00 00    	add    %eax,0x190(%edi)
 397:	eb 0b                	jmp    3a4 <count_schedules+0x11b>
        } else {
            test->actual_schedules[i] = -99999; // obviously bogus count that will fail checks later
 399:	c7 84 9f 10 01 00 00 	movl   $0xfffe7961,0x110(%edi,%ebx,4)
 3a0:	61 79 fe ff 
    for (int i = 0; i < test->num_children; ++i) {
 3a4:	83 c3 01             	add    $0x1,%ebx
 3a7:	39 5f 0c             	cmp    %ebx,0xc(%edi)
 3aa:	0f 8f 0b ff ff ff    	jg     2bb <count_schedules+0x32>
        }
    }
}
 3b0:	83 c4 2c             	add    $0x2c,%esp
 3b3:	5b                   	pop    %ebx
 3b4:	5e                   	pop    %esi
 3b5:	5f                   	pop    %edi
 3b6:	5d                   	pop    %ebp
 3b7:	c3                   	ret    

000003b8 <dump_test_timings>:

void dump_test_timings(struct test_case *test) {
 3b8:	55                   	push   %ebp
 3b9:	89 e5                	mov    %esp,%ebp
 3bb:	56                   	push   %esi
 3bc:	53                   	push   %ebx
 3bd:	83 ec 20             	sub    $0x20,%esp
 3c0:	8b 75 08             	mov    0x8(%ebp),%esi
    printf(1, "-----------------------------------------\n");
 3c3:	c7 44 24 04 9c 0f 00 	movl   $0xf9c,0x4(%esp)
 3ca:	00 
 3cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3d2:	e8 75 07 00 00       	call   b4c <printf>
    printf(1, "%s expected schedules ratios and observations\n", test->name);
 3d7:	8b 06                	mov    (%esi),%eax
 3d9:	89 44 24 08          	mov    %eax,0x8(%esp)
 3dd:	c7 44 24 04 c8 0f 00 	movl   $0xfc8,0x4(%esp)
 3e4:	00 
 3e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3ec:	e8 5b 07 00 00       	call   b4c <printf>
    printf(1, "#\texpect\tobserve\t(description)\n");
 3f1:	c7 44 24 04 f8 0f 00 	movl   $0xff8,0x4(%esp)
 3f8:	00 
 3f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 400:	e8 47 07 00 00       	call   b4c <printf>
    for (int i = 0; i < test->num_children; ++i) {
 405:	bb 00 00 00 00       	mov    $0x0,%ebx
 40a:	e9 81 00 00 00       	jmp    490 <dump_test_timings+0xd8>
        const char *assigned_function = "(unknown)";
        if (test->functions[i] == yield_forever) {
 40f:	8b 84 9e 94 01 00 00 	mov    0x194(%esi,%ebx,4),%eax
 416:	3d 05 00 00 00       	cmp    $0x5,%eax
 41b:	74 1c                	je     439 <dump_test_timings+0x81>
            assigned_function = "yield_forever";
        } else if (test->functions[i] == run_forever) {
 41d:	3d 00 00 00 00       	cmp    $0x0,%eax
 422:	74 1c                	je     440 <dump_test_timings+0x88>
            assigned_function = "run_forever";
        } else if (test->functions[i] == iowait_forever) {
 424:	3d 12 00 00 00       	cmp    $0x12,%eax
 429:	74 1c                	je     447 <dump_test_timings+0x8f>
            assigned_function = "iowait_forever";
        } else if (test->functions[i] == exit_fast) {
 42b:	3d 40 00 00 00       	cmp    $0x40,%eax
 430:	74 1c                	je     44e <dump_test_timings+0x96>
        const char *assigned_function = "(unknown)";
 432:	b8 78 0e 00 00       	mov    $0xe78,%eax
 437:	eb 1a                	jmp    453 <dump_test_timings+0x9b>
            assigned_function = "yield_forever";
 439:	b8 4f 0e 00 00       	mov    $0xe4f,%eax
 43e:	eb 13                	jmp    453 <dump_test_timings+0x9b>
            assigned_function = "run_forever";
 440:	b8 5d 0e 00 00       	mov    $0xe5d,%eax
 445:	eb 0c                	jmp    453 <dump_test_timings+0x9b>
            assigned_function = "iowait_forever";
 447:	b8 69 0e 00 00       	mov    $0xe69,%eax
 44c:	eb 05                	jmp    453 <dump_test_timings+0x9b>
            assigned_function = "exit_fast";
 44e:	b8 82 0e 00 00       	mov    $0xe82,%eax
        }
        printf(1, "%d\t%d\t%d\t(assigned %d tickets; running %s)\n",
 453:	89 44 24 18          	mov    %eax,0x18(%esp)
 457:	8b 44 9e 10          	mov    0x10(%esi,%ebx,4),%eax
 45b:	89 44 24 14          	mov    %eax,0x14(%esp)
 45f:	8b 84 9e 10 01 00 00 	mov    0x110(%esi,%ebx,4),%eax
 466:	89 44 24 10          	mov    %eax,0x10(%esp)
 46a:	8b 84 9e 90 00 00 00 	mov    0x90(%esi,%ebx,4),%eax
 471:	89 44 24 0c          	mov    %eax,0xc(%esp)
 475:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 479:	c7 44 24 04 18 10 00 	movl   $0x1018,0x4(%esp)
 480:	00 
 481:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 488:	e8 bf 06 00 00       	call   b4c <printf>
    for (int i = 0; i < test->num_children; ++i) {
 48d:	83 c3 01             	add    $0x1,%ebx
 490:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 493:	0f 8f 76 ff ff ff    	jg     40f <dump_test_timings+0x57>
            test->expect_schedules_unscaled[i],
            test->actual_schedules[i],
            test->tickets[i],
            assigned_function);
    }
    printf(1, "\nNOTE: the 'expect' values above represent the expected\n"
 499:	c7 44 24 04 44 10 00 	movl   $0x1044,0x4(%esp)
 4a0:	00 
 4a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4a8:	e8 9f 06 00 00       	call   b4c <printf>
              "      ratio of schedules between the processes. So, to compare\n"
              "      them to the observations by hand, multiply each expected\n"
              "      value by (sum of observed)/(sum of expected)\n");
    printf(1, "-----------------------------------------\n");
 4ad:	c7 44 24 04 9c 0f 00 	movl   $0xf9c,0x4(%esp)
 4b4:	00 
 4b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4bc:	e8 8b 06 00 00       	call   b4c <printf>
}
 4c1:	83 c4 20             	add    $0x20,%esp
 4c4:	5b                   	pop    %ebx
 4c5:	5e                   	pop    %esi
 4c6:	5d                   	pop    %ebp
 4c7:	c3                   	ret    

000004c8 <compare_schedules_chi_squared>:
    FIXED_POINT_BASE / 100 * 2612,
    FIXED_POINT_BASE / 100 * 2788,
    FIXED_POINT_BASE / 100 * 2959,
};

int compare_schedules_chi_squared(struct test_case *test) {
 4c8:	55                   	push   %ebp
 4c9:	89 e5                	mov    %esp,%ebp
 4cb:	57                   	push   %edi
 4cc:	56                   	push   %esi
 4cd:	53                   	push   %ebx
 4ce:	83 ec 3c             	sub    $0x3c,%esp
 4d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (test->num_children < 2) {
 4d4:	8b 43 0c             	mov    0xc(%ebx),%eax
 4d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
 4da:	83 f8 01             	cmp    $0x1,%eax
 4dd:	0f 8e a5 01 00 00    	jle    688 <compare_schedules_chi_squared+0x1c0>
 4e3:	b9 00 00 00 00       	mov    $0x0,%ecx
 4e8:	b8 00 00 00 00       	mov    $0x0,%eax
 4ed:	ba 00 00 00 00       	mov    $0x0,%edx
 4f2:	eb 13                	jmp    507 <compare_schedules_chi_squared+0x3f>
        return 1;
    }
    long long expect_schedules_total = 0;
    for (int i = 0; i < test->num_children; ++i) {
        expect_schedules_total += test->expect_schedules_unscaled[i];
 4f4:	8b b4 8b 90 00 00 00 	mov    0x90(%ebx,%ecx,4),%esi
 4fb:	89 f7                	mov    %esi,%edi
 4fd:	c1 ff 1f             	sar    $0x1f,%edi
 500:	01 f0                	add    %esi,%eax
 502:	11 fa                	adc    %edi,%edx
    for (int i = 0; i < test->num_children; ++i) {
 504:	83 c1 01             	add    $0x1,%ecx
 507:	3b 4d dc             	cmp    -0x24(%ebp),%ecx
 50a:	7c e8                	jl     4f4 <compare_schedules_chi_squared+0x2c>
 50c:	89 45 d0             	mov    %eax,-0x30(%ebp)
 50f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 512:	bf 00 00 00 00       	mov    $0x0,%edi
 517:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 51e:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
 525:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 52c:	89 de                	mov    %ebx,%esi
 52e:	e9 c6 00 00 00       	jmp    5f9 <compare_schedules_chi_squared+0x131>
       like Fisher's exact test.
    */
    long long delta = 0;
    int skipped = 0;
    for (int i = 0; i < test->num_children; ++i) {
        long long scaled_expected = (test->expect_schedules_unscaled[i] << FIXED_POINT_COUNT) / expect_schedules_total
 533:	8b 84 be 90 00 00 00 	mov    0x90(%esi,%edi,4),%eax
 53a:	c1 e0 0a             	shl    $0xa,%eax
 53d:	8b 55 d0             	mov    -0x30(%ebp),%edx
 540:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
 543:	89 54 24 08          	mov    %edx,0x8(%esp)
 547:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
 54b:	89 04 24             	mov    %eax,(%esp)
 54e:	89 c3                	mov    %eax,%ebx
 550:	c1 fb 1f             	sar    $0x1f,%ebx
 553:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 557:	e8 54 07 00 00       	call   cb0 <__divdi3>
                             * test->total_actual_schedules;
 55c:	8b 8e 90 01 00 00    	mov    0x190(%esi),%ecx
 562:	89 cb                	mov    %ecx,%ebx
 564:	c1 fb 1f             	sar    $0x1f,%ebx
        long long scaled_expected = (test->expect_schedules_unscaled[i] << FIXED_POINT_COUNT) / expect_schedules_total
 567:	0f af 96 90 01 00 00 	imul   0x190(%esi),%edx
 56e:	89 d9                	mov    %ebx,%ecx
 570:	0f af c8             	imul   %eax,%ecx
 573:	8d 1c 0a             	lea    (%edx,%ecx,1),%ebx
 576:	f7 a6 90 01 00 00    	mull   0x190(%esi)
 57c:	89 45 e0             	mov    %eax,-0x20(%ebp)
 57f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
 582:	01 5d e4             	add    %ebx,-0x1c(%ebp)
            test->expect_schedules_unscaled[i],
            (int)(scaled_expected >> FIXED_POINT_COUNT),
            (int) expect_schedules_total,
            test->total_actual_schedules);
#endif
        if (scaled_expected == 0) {
 585:	8b 45 e0             	mov    -0x20(%ebp),%eax
 588:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 58b:	89 d3                	mov    %edx,%ebx
 58d:	09 c3                	or     %eax,%ebx
 58f:	75 06                	jne    597 <compare_schedules_chi_squared+0xcf>
            ++skipped;
 591:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
            continue;
 595:	eb 5f                	jmp    5f6 <compare_schedules_chi_squared+0x12e>
        }
        long long cur_delta = scaled_expected - (test->actual_schedules[i] << FIXED_POINT_COUNT);
 597:	8b 84 be 10 01 00 00 	mov    0x110(%esi,%edi,4),%eax
 59e:	c1 e0 0a             	shl    $0xa,%eax
 5a1:	99                   	cltd   
 5a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 5a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
 5a8:	29 c1                	sub    %eax,%ecx
 5aa:	19 d3                	sbb    %edx,%ebx
 5ac:	89 c8                	mov    %ecx,%eax
#ifdef DEBUG
        printf(1, "raw delta is is %x/%x\n", (int) cur_delta, (int) (cur_delta >> 32));
        printf(1, "raw delta rounded is is %x\n", (int) (cur_delta >> FIXED_POINT_COUNT));
#endif
        cur_delta *= cur_delta;
 5ae:	0f af d9             	imul   %ecx,%ebx
 5b1:	89 d9                	mov    %ebx,%ecx
 5b3:	01 c9                	add    %ecx,%ecx
 5b5:	f7 e0                	mul    %eax
 5b7:	01 ca                	add    %ecx,%edx
        // cur_delta >>= FIXED_POINT_COUNT; // skipped because cancelled out by future shift back
#ifdef DEBUG
        printf(1, "delta before division [raw]     %x/%x\n", (int) cur_delta, (int) (cur_delta >> 32));
        printf(1, "delta before division [rounded] %d\n", (int) (cur_delta >> FIXED_POINT_COUNT));
#endif
        if (scaled_expected > 0) {
 5b9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
 5bc:	85 db                	test   %ebx,%ebx
 5be:	78 26                	js     5e6 <compare_schedules_chi_squared+0x11e>
 5c0:	85 db                	test   %ebx,%ebx
 5c2:	7f 06                	jg     5ca <compare_schedules_chi_squared+0x102>
 5c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 5c8:	76 1c                	jbe    5e6 <compare_schedules_chi_squared+0x11e>
            // cur_delta <<= FIXED_POINT_COUNT;
            cur_delta /= scaled_expected;
 5ca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 5cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
 5d0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
 5d4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 5d8:	89 04 24             	mov    %eax,(%esp)
 5db:	89 54 24 04          	mov    %edx,0x4(%esp)
 5df:	e8 cc 06 00 00       	call   cb0 <__divdi3>
 5e4:	eb 0a                	jmp    5f0 <compare_schedules_chi_squared+0x128>
        } else {
            /* a huge number to make sure statistical test fails */
            cur_delta = FIXED_POINT_BASE * 100000LL;
 5e6:	b8 00 80 1a 06       	mov    $0x61a8000,%eax
 5eb:	ba 00 00 00 00       	mov    $0x0,%edx
        }
#ifdef DEBUG
        printf(1, "cur_delta = %x/%x\n", (int) cur_delta, (int) (cur_delta >> 32));
#endif
        delta += cur_delta;
 5f0:	01 45 c8             	add    %eax,-0x38(%ebp)
 5f3:	11 55 cc             	adc    %edx,-0x34(%ebp)
    for (int i = 0; i < test->num_children; ++i) {
 5f6:	83 c7 01             	add    $0x1,%edi
 5f9:	3b 7d dc             	cmp    -0x24(%ebp),%edi
 5fc:	0f 8c 31 ff ff ff    	jl     533 <compare_schedules_chi_squared+0x6b>
 602:	89 f3                	mov    %esi,%ebx
    }
#ifdef DEBUG
    printf(1, "%s test statistic %d (rounded)\n", test->name, (int) ((delta + FIXED_POINT_BASE / 2) >> FIXED_POINT_COUNT));
#endif
    int degrees_of_freedom = test->num_children - 1 - skipped;
 604:	8b 45 dc             	mov    -0x24(%ebp),%eax
 607:	2b 45 d8             	sub    -0x28(%ebp),%eax
    long long expected_value = chi_squared_thresholds[degrees_of_freedom - 1];
 60a:	8d 40 fe             	lea    -0x2(%eax),%eax
 60d:	8b 14 c5 c0 14 00 00 	mov    0x14c0(,%eax,8),%edx
 614:	8b 04 c5 c4 14 00 00 	mov    0x14c4(,%eax,8),%eax
    int passed_threshold = delta < expected_value;
 61b:	b9 01 00 00 00       	mov    $0x1,%ecx
 620:	39 45 cc             	cmp    %eax,-0x34(%ebp)
 623:	7c 0c                	jl     631 <compare_schedules_chi_squared+0x169>
 625:	7f 05                	jg     62c <compare_schedules_chi_squared+0x164>
 627:	39 55 c8             	cmp    %edx,-0x38(%ebp)
 62a:	72 05                	jb     631 <compare_schedules_chi_squared+0x169>
 62c:	b9 00 00 00 00       	mov    $0x0,%ecx
 631:	0f b6 f1             	movzbl %cl,%esi
    check(test, passed_threshold,
 634:	c7 44 24 08 30 11 00 	movl   $0x1130,0x8(%esp)
 63b:	00 
 63c:	89 74 24 04          	mov    %esi,0x4(%esp)
 640:	89 1c 24             	mov    %ebx,(%esp)
 643:	e8 30 fb ff ff       	call   178 <check>
          "distribution of schedules run passed chi-squared test "
          "for being same as expected");
    if (!passed_threshold) {
 648:	85 f6                	test   %esi,%esi
 64a:	75 08                	jne    654 <compare_schedules_chi_squared+0x18c>
        dump_test_timings(test);
 64c:	89 1c 24             	mov    %ebx,(%esp)
 64f:	e8 64 fd ff ff       	call   3b8 <dump_test_timings>
    }
    check(test, test->total_actual_schedules >
 654:	8b 93 90 01 00 00    	mov    0x190(%ebx),%edx
                (test->override_min_schedules == 0 ? MIN_SCHEDULES : test->override_min_schedules),
 65a:	8b 83 14 02 00 00    	mov    0x214(%ebx),%eax
 660:	85 c0                	test   %eax,%eax
 662:	75 04                	jne    668 <compare_schedules_chi_squared+0x1a0>
 664:	66 b8 d0 07          	mov    $0x7d0,%ax
    check(test, test->total_actual_schedules >
 668:	c7 44 24 08 84 11 00 	movl   $0x1184,0x8(%esp)
 66f:	00 
 670:	39 c2                	cmp    %eax,%edx
 672:	0f 9f c0             	setg   %al
 675:	0f b6 c0             	movzbl %al,%eax
 678:	89 44 24 04          	mov    %eax,0x4(%esp)
 67c:	89 1c 24             	mov    %ebx,(%esp)
 67f:	e8 f4 fa ff ff       	call   178 <check>
          "threads scheduled enough times to get significant sample\n"
          "if you are properly recording times_scheduled, then this might\n"
          "just mean that SLEEP_TIME in lotterytest.c should be increased\n"
          "to get a larger sample");
    return passed_threshold;
 684:	89 f0                	mov    %esi,%eax
 686:	eb 05                	jmp    68d <compare_schedules_chi_squared+0x1c5>
        return 1;
 688:	b8 01 00 00 00       	mov    $0x1,%eax
}
 68d:	83 c4 3c             	add    $0x3c,%esp
 690:	5b                   	pop    %ebx
 691:	5e                   	pop    %esi
 692:	5f                   	pop    %edi
 693:	5d                   	pop    %ebp
 694:	c3                   	ret    

00000695 <compare_schedules_naive>:

   This hopefully will detect cases where a biased random
   number generator is in use but otherwise the implementation
   is generally okay.
 */
void compare_schedules_naive(struct test_case *test) {
 695:	55                   	push   %ebp
 696:	89 e5                	mov    %esp,%ebp
 698:	57                   	push   %edi
 699:	56                   	push   %esi
 69a:	53                   	push   %ebx
 69b:	83 ec 3c             	sub    $0x3c,%esp
 69e:	8b 7d 08             	mov    0x8(%ebp),%edi
    if (test->num_children < 2) {
 6a1:	8b 47 0c             	mov    0xc(%edi),%eax
 6a4:	89 c1                	mov    %eax,%ecx
 6a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
 6a9:	83 f8 01             	cmp    $0x1,%eax
 6ac:	0f 8e 70 01 00 00    	jle    822 <compare_schedules_naive+0x18d>
 6b2:	b8 00 00 00 00       	mov    $0x0,%eax
 6b7:	ba 00 00 00 00       	mov    $0x0,%edx
 6bc:	eb 0a                	jmp    6c8 <compare_schedules_naive+0x33>
        return;
    }
    int expect_schedules_total = 0;
    for (int i = 0; i < test->num_children; ++i) {
        expect_schedules_total += test->expect_schedules_unscaled[i];
 6be:	03 94 87 90 00 00 00 	add    0x90(%edi,%eax,4),%edx
    for (int i = 0; i < test->num_children; ++i) {
 6c5:	83 c0 01             	add    $0x1,%eax
 6c8:	39 c8                	cmp    %ecx,%eax
 6ca:	7c f2                	jl     6be <compare_schedules_naive+0x29>
 6cc:	be 00 00 00 00       	mov    $0x0,%esi
 6d1:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
    }
    int failed_any = 0;
    for (int i = 0; i < test->num_children; ++i) {
        long long scaled_expected = ((long long) test->expect_schedules_unscaled[i] * test->total_actual_schedules) / expect_schedules_total;
 6d8:	89 55 d0             	mov    %edx,-0x30(%ebp)
 6db:	89 d0                	mov    %edx,%eax
 6dd:	c1 f8 1f             	sar    $0x1f,%eax
 6e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 6e3:	89 75 e4             	mov    %esi,-0x1c(%ebp)
 6e6:	e9 dd 00 00 00       	jmp    7c8 <compare_schedules_naive+0x133>
 6eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ee:	8b 84 87 90 00 00 00 	mov    0x90(%edi,%eax,4),%eax
 6f5:	89 c6                	mov    %eax,%esi
 6f7:	c1 fe 1f             	sar    $0x1f,%esi
 6fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
 6fd:	89 75 dc             	mov    %esi,-0x24(%ebp)
 700:	8b 97 90 01 00 00    	mov    0x190(%edi),%edx
 706:	89 d6                	mov    %edx,%esi
 708:	c1 fe 1f             	sar    $0x1f,%esi
 70b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
 70e:	0f af ca             	imul   %edx,%ecx
 711:	89 f3                	mov    %esi,%ebx
 713:	0f af d8             	imul   %eax,%ebx
 716:	01 d9                	add    %ebx,%ecx
 718:	f7 e2                	mul    %edx
 71a:	01 ca                	add    %ecx,%edx
 71c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
 71f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
 722:	89 4c 24 08          	mov    %ecx,0x8(%esp)
 726:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 72a:	89 04 24             	mov    %eax,(%esp)
 72d:	89 54 24 04          	mov    %edx,0x4(%esp)
 731:	e8 7a 05 00 00       	call   cb0 <__divdi3>
 736:	89 c3                	mov    %eax,%ebx
        int max_expected = scaled_expected * 11 / 10 + 10;
 738:	89 d6                	mov    %edx,%esi
 73a:	6b ca 0b             	imul   $0xb,%edx,%ecx
 73d:	b8 0b 00 00 00       	mov    $0xb,%eax
 742:	f7 e3                	mul    %ebx
 744:	01 ca                	add    %ecx,%edx
 746:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 74d:	00 
 74e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 755:	00 
 756:	89 04 24             	mov    %eax,(%esp)
 759:	89 54 24 04          	mov    %edx,0x4(%esp)
 75d:	e8 4e 05 00 00       	call   cb0 <__divdi3>
 762:	83 c0 0a             	add    $0xa,%eax
 765:	89 45 d8             	mov    %eax,-0x28(%ebp)
        int min_expected = scaled_expected * 9 / 10 - 10;
 768:	6b ce 09             	imul   $0x9,%esi,%ecx
 76b:	b8 09 00 00 00       	mov    $0x9,%eax
 770:	f7 e3                	mul    %ebx
 772:	01 ca                	add    %ecx,%edx
 774:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 77b:	00 
 77c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 783:	00 
 784:	89 04 24             	mov    %eax,(%esp)
 787:	89 54 24 04          	mov    %edx,0x4(%esp)
 78b:	e8 20 05 00 00       	call   cb0 <__divdi3>
 790:	83 e8 0a             	sub    $0xa,%eax
        int in_range = (test->actual_schedules[i] >= min_expected && test->actual_schedules[i] <= max_expected);
 793:	8b 75 e4             	mov    -0x1c(%ebp),%esi
 796:	8b 94 b7 10 01 00 00 	mov    0x110(%edi,%esi,4),%edx
 79d:	39 c2                	cmp    %eax,%edx
 79f:	7c 0c                	jl     7ad <compare_schedules_naive+0x118>
 7a1:	39 55 d8             	cmp    %edx,-0x28(%ebp)
 7a4:	7d 0e                	jge    7b4 <compare_schedules_naive+0x11f>
 7a6:	b8 00 00 00 00       	mov    $0x0,%eax
 7ab:	eb 0c                	jmp    7b9 <compare_schedules_naive+0x124>
 7ad:	b8 00 00 00 00       	mov    $0x0,%eax
 7b2:	eb 05                	jmp    7b9 <compare_schedules_naive+0x124>
 7b4:	b8 01 00 00 00       	mov    $0x1,%eax
        if (!in_range) {
 7b9:	85 c0                	test   %eax,%eax
 7bb:	75 07                	jne    7c4 <compare_schedules_naive+0x12f>
            failed_any = 1;
 7bd:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
    for (int i = 0; i < test->num_children; ++i) {
 7c4:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 7c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
 7cb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
 7ce:	0f 8c 17 ff ff ff    	jl     6eb <compare_schedules_naive+0x56>
        }
    }
    check(test, !failed_any, "schedule counts within +/- 10% or +/- 10 of expected");
 7d4:	c7 44 24 08 54 12 00 	movl   $0x1254,0x8(%esp)
 7db:	00 
 7dc:	8b 75 cc             	mov    -0x34(%ebp),%esi
 7df:	89 f0                	mov    %esi,%eax
 7e1:	83 f0 01             	xor    $0x1,%eax
 7e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e8:	89 3c 24             	mov    %edi,(%esp)
 7eb:	e8 88 f9 ff ff       	call   178 <check>
    if (!failed_any) {
 7f0:	85 f6                	test   %esi,%esi
 7f2:	75 2e                	jne    822 <compare_schedules_naive+0x18d>
        printf(1, "*** %s failed chi-squared test, but was w/in 10% of expected\n", test->name);
 7f4:	8b 07                	mov    (%edi),%eax
 7f6:	89 44 24 08          	mov    %eax,0x8(%esp)
 7fa:	c7 44 24 04 8c 12 00 	movl   $0x128c,0x4(%esp)
 801:	00 
 802:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 809:	e8 3e 03 00 00       	call   b4c <printf>
        printf(1, "*** a likely cause is bias in random number generation\n");
 80e:	c7 44 24 04 cc 12 00 	movl   $0x12cc,0x4(%esp)
 815:	00 
 816:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 81d:	e8 2a 03 00 00       	call   b4c <printf>
    }
}
 822:	83 c4 3c             	add    $0x3c,%esp
 825:	5b                   	pop    %ebx
 826:	5e                   	pop    %esi
 827:	5f                   	pop    %edi
 828:	5d                   	pop    %ebp
 829:	c3                   	ret    

0000082a <run_test_case>:

void run_test_case(struct test_case* test) {
 82a:	55                   	push   %ebp
 82b:	89 e5                	mov    %esp,%ebp
 82d:	53                   	push   %ebx
 82e:	81 ec b4 06 00 00    	sub    $0x6b4,%esp
 834:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int pids[MAX_CHILDREN];
    test->total_tests = test->errors = 0;
 837:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
 83e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
    struct processes_info before, after;
    execute_and_get_info(test, pids, &before, &after);
 845:	8d 85 70 f9 ff ff    	lea    -0x690(%ebp),%eax
 84b:	89 44 24 0c          	mov    %eax,0xc(%esp)
 84f:	8d 85 74 fc ff ff    	lea    -0x38c(%ebp),%eax
 855:	89 44 24 08          	mov    %eax,0x8(%esp)
 859:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
 85f:	89 44 24 04          	mov    %eax,0x4(%esp)
 863:	89 1c 24             	mov    %ebx,(%esp)
 866:	e8 47 f9 ff ff       	call   1b2 <execute_and_get_info>
    check(test, 
          before.num_processes < NPROC && after.num_processes < NPROC &&
 86b:	8b 85 74 fc ff ff    	mov    -0x38c(%ebp),%eax
    check(test, 
 871:	83 f8 3f             	cmp    $0x3f,%eax
 874:	7f 1d                	jg     893 <run_test_case+0x69>
          before.num_processes < NPROC && after.num_processes < NPROC &&
 876:	8b 95 70 f9 ff ff    	mov    -0x690(%ebp),%edx
 87c:	83 fa 3f             	cmp    $0x3f,%edx
 87f:	7f 19                	jg     89a <run_test_case+0x70>
          before.num_processes > test->num_children && after.num_processes > test->num_children,
 881:	8b 4b 0c             	mov    0xc(%ebx),%ecx
          before.num_processes < NPROC && after.num_processes < NPROC &&
 884:	39 c8                	cmp    %ecx,%eax
 886:	7e 19                	jle    8a1 <run_test_case+0x77>
    check(test, 
 888:	39 ca                	cmp    %ecx,%edx
 88a:	7f 1c                	jg     8a8 <run_test_case+0x7e>
 88c:	b8 00 00 00 00       	mov    $0x0,%eax
 891:	eb 1a                	jmp    8ad <run_test_case+0x83>
 893:	b8 00 00 00 00       	mov    $0x0,%eax
 898:	eb 13                	jmp    8ad <run_test_case+0x83>
 89a:	b8 00 00 00 00       	mov    $0x0,%eax
 89f:	eb 0c                	jmp    8ad <run_test_case+0x83>
 8a1:	b8 00 00 00 00       	mov    $0x0,%eax
 8a6:	eb 05                	jmp    8ad <run_test_case+0x83>
 8a8:	b8 01 00 00 00       	mov    $0x1,%eax
 8ad:	c7 44 24 08 04 13 00 	movl   $0x1304,0x8(%esp)
 8b4:	00 
 8b5:	89 44 24 04          	mov    %eax,0x4(%esp)
 8b9:	89 1c 24             	mov    %ebx,(%esp)
 8bc:	e8 b7 f8 ff ff       	call   178 <check>
          "getprocessesinfo returned a reasonable number of processes");
    count_schedules(test, pids, &before, &after);
 8c1:	8d 85 70 f9 ff ff    	lea    -0x690(%ebp),%eax
 8c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
 8cb:	8d 85 74 fc ff ff    	lea    -0x38c(%ebp),%eax
 8d1:	89 44 24 08          	mov    %eax,0x8(%esp)
 8d5:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
 8db:	89 44 24 04          	mov    %eax,0x4(%esp)
 8df:	89 1c 24             	mov    %ebx,(%esp)
 8e2:	e8 a2 f9 ff ff       	call   289 <count_schedules>
    if (!compare_schedules_chi_squared(test)) {
 8e7:	89 1c 24             	mov    %ebx,(%esp)
 8ea:	e8 d9 fb ff ff       	call   4c8 <compare_schedules_chi_squared>
 8ef:	85 c0                	test   %eax,%eax
 8f1:	75 0a                	jne    8fd <run_test_case+0xd3>
        compare_schedules_naive(test);
 8f3:	89 1c 24             	mov    %ebx,(%esp)
 8f6:	e8 9a fd ff ff       	call   695 <compare_schedules_naive>
 8fb:	eb 18                	jmp    915 <run_test_case+0xeb>
    } else {
        check(test, 1, "assuming schedule counts approximately right given chi-squared test");
 8fd:	c7 44 24 08 40 13 00 	movl   $0x1340,0x8(%esp)
 904:	00 
 905:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 90c:	00 
 90d:	89 1c 24             	mov    %ebx,(%esp)
 910:	e8 63 f8 ff ff       	call   178 <check>
    }
    printf(1, "%s: passed %d of %d\n", test->name, test->total_tests - test->errors, test->total_tests);
 915:	8b 43 04             	mov    0x4(%ebx),%eax
 918:	8b 53 08             	mov    0x8(%ebx),%edx
 91b:	89 44 24 10          	mov    %eax,0x10(%esp)
 91f:	29 d0                	sub    %edx,%eax
 921:	89 44 24 0c          	mov    %eax,0xc(%esp)
 925:	8b 03                	mov    (%ebx),%eax
 927:	89 44 24 08          	mov    %eax,0x8(%esp)
 92b:	c7 44 24 04 8c 0e 00 	movl   $0xe8c,0x4(%esp)
 932:	00 
 933:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 93a:	e8 0d 02 00 00       	call   b4c <printf>
}
 93f:	81 c4 b4 06 00 00    	add    $0x6b4,%esp
 945:	5b                   	pop    %ebx
 946:	5d                   	pop    %ebp
 947:	c3                   	ret    

00000948 <main>:

int main(int argc, char *argv[])
{
 948:	55                   	push   %ebp
 949:	89 e5                	mov    %esp,%ebp
 94b:	57                   	push   %edi
 94c:	56                   	push   %esi
 94d:	53                   	push   %ebx
 94e:	83 e4 f0             	and    $0xfffffff0,%esp
 951:	83 ec 20             	sub    $0x20,%esp
    int total_tests = 0;
    int passed_tests = 0;
    for (int i = 0; tests[i].name; ++i) {
 954:	bb 00 00 00 00       	mov    $0x0,%ebx
    int passed_tests = 0;
 959:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
 960:	00 
    int total_tests = 0;
 961:	bf 00 00 00 00       	mov    $0x0,%edi
    for (int i = 0; tests[i].name; ++i) {
 966:	eb 23                	jmp    98b <main+0x43>
        struct test_case *test = &tests[i];
 968:	69 f3 18 02 00 00    	imul   $0x218,%ebx,%esi
 96e:	81 c6 40 15 00 00    	add    $0x1540,%esi
        run_test_case(test);
 974:	89 34 24             	mov    %esi,(%esp)
 977:	e8 ae fe ff ff       	call   82a <run_test_case>
        total_tests += test->total_tests;
 97c:	8b 46 04             	mov    0x4(%esi),%eax
 97f:	01 c7                	add    %eax,%edi
        passed_tests += test->total_tests - test->errors;
 981:	2b 46 08             	sub    0x8(%esi),%eax
 984:	01 44 24 1c          	add    %eax,0x1c(%esp)
    for (int i = 0; tests[i].name; ++i) {
 988:	83 c3 01             	add    $0x1,%ebx
 98b:	69 c3 18 02 00 00    	imul   $0x218,%ebx,%eax
 991:	83 b8 40 15 00 00 00 	cmpl   $0x0,0x1540(%eax)
 998:	75 ce                	jne    968 <main+0x20>
    }
    printf(1, "overall: passed %d of %d tests attempted\n", passed_tests, total_tests);
 99a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
 99e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 9a2:	89 44 24 08          	mov    %eax,0x8(%esp)
 9a6:	c7 44 24 04 84 13 00 	movl   $0x1384,0x4(%esp)
 9ad:	00 
 9ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 9b5:	e8 92 01 00 00       	call   b4c <printf>
    exit();
 9ba:	e8 08 00 00 00       	call   9c7 <exit>

000009bf <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 9bf:	b8 01 00 00 00       	mov    $0x1,%eax
 9c4:	cd 40                	int    $0x40
 9c6:	c3                   	ret    

000009c7 <exit>:
SYSCALL(exit)
 9c7:	b8 02 00 00 00       	mov    $0x2,%eax
 9cc:	cd 40                	int    $0x40
 9ce:	c3                   	ret    

000009cf <wait>:
SYSCALL(wait)
 9cf:	b8 03 00 00 00       	mov    $0x3,%eax
 9d4:	cd 40                	int    $0x40
 9d6:	c3                   	ret    

000009d7 <pipe>:
SYSCALL(pipe)
 9d7:	b8 04 00 00 00       	mov    $0x4,%eax
 9dc:	cd 40                	int    $0x40
 9de:	c3                   	ret    

000009df <read>:
SYSCALL(read)
 9df:	b8 05 00 00 00       	mov    $0x5,%eax
 9e4:	cd 40                	int    $0x40
 9e6:	c3                   	ret    

000009e7 <write>:
SYSCALL(write)
 9e7:	b8 10 00 00 00       	mov    $0x10,%eax
 9ec:	cd 40                	int    $0x40
 9ee:	c3                   	ret    

000009ef <close>:
SYSCALL(close)
 9ef:	b8 15 00 00 00       	mov    $0x15,%eax
 9f4:	cd 40                	int    $0x40
 9f6:	c3                   	ret    

000009f7 <kill>:
SYSCALL(kill)
 9f7:	b8 06 00 00 00       	mov    $0x6,%eax
 9fc:	cd 40                	int    $0x40
 9fe:	c3                   	ret    

000009ff <exec>:
SYSCALL(exec)
 9ff:	b8 07 00 00 00       	mov    $0x7,%eax
 a04:	cd 40                	int    $0x40
 a06:	c3                   	ret    

00000a07 <open>:
SYSCALL(open)
 a07:	b8 0f 00 00 00       	mov    $0xf,%eax
 a0c:	cd 40                	int    $0x40
 a0e:	c3                   	ret    

00000a0f <mknod>:
SYSCALL(mknod)
 a0f:	b8 11 00 00 00       	mov    $0x11,%eax
 a14:	cd 40                	int    $0x40
 a16:	c3                   	ret    

00000a17 <unlink>:
SYSCALL(unlink)
 a17:	b8 12 00 00 00       	mov    $0x12,%eax
 a1c:	cd 40                	int    $0x40
 a1e:	c3                   	ret    

00000a1f <fstat>:
SYSCALL(fstat)
 a1f:	b8 08 00 00 00       	mov    $0x8,%eax
 a24:	cd 40                	int    $0x40
 a26:	c3                   	ret    

00000a27 <link>:
SYSCALL(link)
 a27:	b8 13 00 00 00       	mov    $0x13,%eax
 a2c:	cd 40                	int    $0x40
 a2e:	c3                   	ret    

00000a2f <mkdir>:
SYSCALL(mkdir)
 a2f:	b8 14 00 00 00       	mov    $0x14,%eax
 a34:	cd 40                	int    $0x40
 a36:	c3                   	ret    

00000a37 <chdir>:
SYSCALL(chdir)
 a37:	b8 09 00 00 00       	mov    $0x9,%eax
 a3c:	cd 40                	int    $0x40
 a3e:	c3                   	ret    

00000a3f <dup>:
SYSCALL(dup)
 a3f:	b8 0a 00 00 00       	mov    $0xa,%eax
 a44:	cd 40                	int    $0x40
 a46:	c3                   	ret    

00000a47 <getpid>:
SYSCALL(getpid)
 a47:	b8 0b 00 00 00       	mov    $0xb,%eax
 a4c:	cd 40                	int    $0x40
 a4e:	c3                   	ret    

00000a4f <sbrk>:
SYSCALL(sbrk)
 a4f:	b8 0c 00 00 00       	mov    $0xc,%eax
 a54:	cd 40                	int    $0x40
 a56:	c3                   	ret    

00000a57 <sleep>:
SYSCALL(sleep)
 a57:	b8 0d 00 00 00       	mov    $0xd,%eax
 a5c:	cd 40                	int    $0x40
 a5e:	c3                   	ret    

00000a5f <uptime>:
SYSCALL(uptime)
 a5f:	b8 0e 00 00 00       	mov    $0xe,%eax
 a64:	cd 40                	int    $0x40
 a66:	c3                   	ret    

00000a67 <yield>:
SYSCALL(yield)
 a67:	b8 16 00 00 00       	mov    $0x16,%eax
 a6c:	cd 40                	int    $0x40
 a6e:	c3                   	ret    

00000a6f <shutdown>:
SYSCALL(shutdown)
 a6f:	b8 17 00 00 00       	mov    $0x17,%eax
 a74:	cd 40                	int    $0x40
 a76:	c3                   	ret    

00000a77 <writecount>:
SYSCALL(writecount)
 a77:	b8 18 00 00 00       	mov    $0x18,%eax
 a7c:	cd 40                	int    $0x40
 a7e:	c3                   	ret    

00000a7f <setwritecount>:
SYSCALL(setwritecount)
 a7f:	b8 19 00 00 00       	mov    $0x19,%eax
 a84:	cd 40                	int    $0x40
 a86:	c3                   	ret    

00000a87 <settickets>:
SYSCALL(settickets)
 a87:	b8 1a 00 00 00       	mov    $0x1a,%eax
 a8c:	cd 40                	int    $0x40
 a8e:	c3                   	ret    

00000a8f <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 a8f:	b8 1b 00 00 00       	mov    $0x1b,%eax
 a94:	cd 40                	int    $0x40
 a96:	c3                   	ret    

00000a97 <getpagetableentry>:
SYSCALL(getpagetableentry)
 a97:	b8 1c 00 00 00       	mov    $0x1c,%eax
 a9c:	cd 40                	int    $0x40
 a9e:	c3                   	ret    

00000a9f <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 a9f:	b8 1d 00 00 00       	mov    $0x1d,%eax
 aa4:	cd 40                	int    $0x40
 aa6:	c3                   	ret    

00000aa7 <dumppagetable>:
 aa7:	b8 1e 00 00 00       	mov    $0x1e,%eax
 aac:	cd 40                	int    $0x40
 aae:	c3                   	ret    
 aaf:	90                   	nop

00000ab0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 ab0:	55                   	push   %ebp
 ab1:	89 e5                	mov    %esp,%ebp
 ab3:	83 ec 18             	sub    $0x18,%esp
 ab6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 ab9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 ac0:	00 
 ac1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 ac4:	89 54 24 04          	mov    %edx,0x4(%esp)
 ac8:	89 04 24             	mov    %eax,(%esp)
 acb:	e8 17 ff ff ff       	call   9e7 <write>
}
 ad0:	c9                   	leave  
 ad1:	c3                   	ret    

00000ad2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 ad2:	55                   	push   %ebp
 ad3:	89 e5                	mov    %esp,%ebp
 ad5:	57                   	push   %edi
 ad6:	56                   	push   %esi
 ad7:	53                   	push   %ebx
 ad8:	83 ec 2c             	sub    $0x2c,%esp
 adb:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 add:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 ae1:	0f 95 c3             	setne  %bl
 ae4:	89 d0                	mov    %edx,%eax
 ae6:	c1 e8 1f             	shr    $0x1f,%eax
 ae9:	84 c3                	test   %al,%bl
 aeb:	74 0b                	je     af8 <printint+0x26>
    neg = 1;
    x = -xx;
 aed:	f7 da                	neg    %edx
    neg = 1;
 aef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 af6:	eb 07                	jmp    aff <printint+0x2d>
  neg = 0;
 af8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 aff:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 b04:	8d 5e 01             	lea    0x1(%esi),%ebx
 b07:	89 d0                	mov    %edx,%eax
 b09:	ba 00 00 00 00       	mov    $0x0,%edx
 b0e:	f7 f1                	div    %ecx
 b10:	0f b6 92 17 15 00 00 	movzbl 0x1517(%edx),%edx
 b17:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 b1b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 b1d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 b1f:	85 c0                	test   %eax,%eax
 b21:	75 e1                	jne    b04 <printint+0x32>
  if(neg)
 b23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 b27:	74 16                	je     b3f <printint+0x6d>
    buf[i++] = '-';
 b29:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 b2e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 b31:	eb 0c                	jmp    b3f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 b33:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 b38:	89 f8                	mov    %edi,%eax
 b3a:	e8 71 ff ff ff       	call   ab0 <putc>
  while(--i >= 0)
 b3f:	83 eb 01             	sub    $0x1,%ebx
 b42:	79 ef                	jns    b33 <printint+0x61>
}
 b44:	83 c4 2c             	add    $0x2c,%esp
 b47:	5b                   	pop    %ebx
 b48:	5e                   	pop    %esi
 b49:	5f                   	pop    %edi
 b4a:	5d                   	pop    %ebp
 b4b:	c3                   	ret    

00000b4c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 b4c:	55                   	push   %ebp
 b4d:	89 e5                	mov    %esp,%ebp
 b4f:	57                   	push   %edi
 b50:	56                   	push   %esi
 b51:	53                   	push   %ebx
 b52:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 b55:	8d 45 10             	lea    0x10(%ebp),%eax
 b58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 b5b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 b60:	be 00 00 00 00       	mov    $0x0,%esi
 b65:	e9 23 01 00 00       	jmp    c8d <printf+0x141>
    c = fmt[i] & 0xff;
 b6a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 b6d:	85 ff                	test   %edi,%edi
 b6f:	75 19                	jne    b8a <printf+0x3e>
      if(c == '%'){
 b71:	83 f8 25             	cmp    $0x25,%eax
 b74:	0f 84 0b 01 00 00    	je     c85 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 b7a:	0f be d3             	movsbl %bl,%edx
 b7d:	8b 45 08             	mov    0x8(%ebp),%eax
 b80:	e8 2b ff ff ff       	call   ab0 <putc>
 b85:	e9 00 01 00 00       	jmp    c8a <printf+0x13e>
      }
    } else if(state == '%'){
 b8a:	83 ff 25             	cmp    $0x25,%edi
 b8d:	0f 85 f7 00 00 00    	jne    c8a <printf+0x13e>
      if(c == 'd'){
 b93:	83 f8 64             	cmp    $0x64,%eax
 b96:	75 26                	jne    bbe <printf+0x72>
        printint(fd, *ap, 10, 1);
 b98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b9b:	8b 10                	mov    (%eax),%edx
 b9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 ba4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 ba9:	8b 45 08             	mov    0x8(%ebp),%eax
 bac:	e8 21 ff ff ff       	call   ad2 <printint>
        ap++;
 bb1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 bb5:	66 bf 00 00          	mov    $0x0,%di
 bb9:	e9 cc 00 00 00       	jmp    c8a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 bbe:	83 f8 78             	cmp    $0x78,%eax
 bc1:	0f 94 c1             	sete   %cl
 bc4:	83 f8 70             	cmp    $0x70,%eax
 bc7:	0f 94 c2             	sete   %dl
 bca:	08 d1                	or     %dl,%cl
 bcc:	74 27                	je     bf5 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 bce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 bd1:	8b 10                	mov    (%eax),%edx
 bd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 bda:	b9 10 00 00 00       	mov    $0x10,%ecx
 bdf:	8b 45 08             	mov    0x8(%ebp),%eax
 be2:	e8 eb fe ff ff       	call   ad2 <printint>
        ap++;
 be7:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 beb:	bf 00 00 00 00       	mov    $0x0,%edi
 bf0:	e9 95 00 00 00       	jmp    c8a <printf+0x13e>
      } else if(c == 's'){
 bf5:	83 f8 73             	cmp    $0x73,%eax
 bf8:	75 37                	jne    c31 <printf+0xe5>
        s = (char*)*ap;
 bfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 bfd:	8b 18                	mov    (%eax),%ebx
        ap++;
 bff:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 c03:	85 db                	test   %ebx,%ebx
 c05:	75 19                	jne    c20 <printf+0xd4>
          s = "(null)";
 c07:	bb 10 15 00 00       	mov    $0x1510,%ebx
 c0c:	8b 7d 08             	mov    0x8(%ebp),%edi
 c0f:	eb 12                	jmp    c23 <printf+0xd7>
          putc(fd, *s);
 c11:	0f be d2             	movsbl %dl,%edx
 c14:	89 f8                	mov    %edi,%eax
 c16:	e8 95 fe ff ff       	call   ab0 <putc>
          s++;
 c1b:	83 c3 01             	add    $0x1,%ebx
 c1e:	eb 03                	jmp    c23 <printf+0xd7>
 c20:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 c23:	0f b6 13             	movzbl (%ebx),%edx
 c26:	84 d2                	test   %dl,%dl
 c28:	75 e7                	jne    c11 <printf+0xc5>
      state = 0;
 c2a:	bf 00 00 00 00       	mov    $0x0,%edi
 c2f:	eb 59                	jmp    c8a <printf+0x13e>
      } else if(c == 'c'){
 c31:	83 f8 63             	cmp    $0x63,%eax
 c34:	75 19                	jne    c4f <printf+0x103>
        putc(fd, *ap);
 c36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c39:	0f be 10             	movsbl (%eax),%edx
 c3c:	8b 45 08             	mov    0x8(%ebp),%eax
 c3f:	e8 6c fe ff ff       	call   ab0 <putc>
        ap++;
 c44:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 c48:	bf 00 00 00 00       	mov    $0x0,%edi
 c4d:	eb 3b                	jmp    c8a <printf+0x13e>
      } else if(c == '%'){
 c4f:	83 f8 25             	cmp    $0x25,%eax
 c52:	75 12                	jne    c66 <printf+0x11a>
        putc(fd, c);
 c54:	0f be d3             	movsbl %bl,%edx
 c57:	8b 45 08             	mov    0x8(%ebp),%eax
 c5a:	e8 51 fe ff ff       	call   ab0 <putc>
      state = 0;
 c5f:	bf 00 00 00 00       	mov    $0x0,%edi
 c64:	eb 24                	jmp    c8a <printf+0x13e>
        putc(fd, '%');
 c66:	ba 25 00 00 00       	mov    $0x25,%edx
 c6b:	8b 45 08             	mov    0x8(%ebp),%eax
 c6e:	e8 3d fe ff ff       	call   ab0 <putc>
        putc(fd, c);
 c73:	0f be d3             	movsbl %bl,%edx
 c76:	8b 45 08             	mov    0x8(%ebp),%eax
 c79:	e8 32 fe ff ff       	call   ab0 <putc>
      state = 0;
 c7e:	bf 00 00 00 00       	mov    $0x0,%edi
 c83:	eb 05                	jmp    c8a <printf+0x13e>
        state = '%';
 c85:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 c8a:	83 c6 01             	add    $0x1,%esi
 c8d:	89 f0                	mov    %esi,%eax
 c8f:	03 45 0c             	add    0xc(%ebp),%eax
 c92:	0f b6 18             	movzbl (%eax),%ebx
 c95:	84 db                	test   %bl,%bl
 c97:	0f 85 cd fe ff ff    	jne    b6a <printf+0x1e>
    }
  }
}
 c9d:	83 c4 1c             	add    $0x1c,%esp
 ca0:	5b                   	pop    %ebx
 ca1:	5e                   	pop    %esi
 ca2:	5f                   	pop    %edi
 ca3:	5d                   	pop    %ebp
 ca4:	c3                   	ret    
 ca5:	66 90                	xchg   %ax,%ax
 ca7:	66 90                	xchg   %ax,%ax
 ca9:	66 90                	xchg   %ax,%ax
 cab:	66 90                	xchg   %ax,%ax
 cad:	66 90                	xchg   %ax,%ax
 caf:	90                   	nop

00000cb0 <__divdi3>:
 cb0:	55                   	push   %ebp
 cb1:	57                   	push   %edi
 cb2:	56                   	push   %esi
 cb3:	83 ec 10             	sub    $0x10,%esp
 cb6:	8b 44 24 28          	mov    0x28(%esp),%eax
 cba:	8b 7c 24 24          	mov    0x24(%esp),%edi
 cbe:	8b 54 24 20          	mov    0x20(%esp),%edx
 cc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
 ccd:	8b 44 24 2c          	mov    0x2c(%esp),%eax
 cd1:	85 ff                	test   %edi,%edi
 cd3:	89 f9                	mov    %edi,%ecx
 cd5:	89 c5                	mov    %eax,%ebp
 cd7:	0f 88 9b 00 00 00    	js     d78 <__divdi3+0xc8>
 cdd:	85 ed                	test   %ebp,%ebp
 cdf:	8b 74 24 04          	mov    0x4(%esp),%esi
 ce3:	89 c7                	mov    %eax,%edi
 ce5:	0f 88 a9 00 00 00    	js     d94 <__divdi3+0xe4>
 ceb:	85 ff                	test   %edi,%edi
 ced:	89 cd                	mov    %ecx,%ebp
 cef:	89 54 24 08          	mov    %edx,0x8(%esp)
 cf3:	89 f8                	mov    %edi,%eax
 cf5:	89 d1                	mov    %edx,%ecx
 cf7:	89 74 24 04          	mov    %esi,0x4(%esp)
 cfb:	75 13                	jne    d10 <__divdi3+0x60>
 cfd:	39 ee                	cmp    %ebp,%esi
 cff:	76 37                	jbe    d38 <__divdi3+0x88>
 d01:	89 ea                	mov    %ebp,%edx
 d03:	89 c8                	mov    %ecx,%eax
 d05:	31 ed                	xor    %ebp,%ebp
 d07:	f7 f6                	div    %esi
 d09:	89 c1                	mov    %eax,%ecx
 d0b:	eb 0b                	jmp    d18 <__divdi3+0x68>
 d0d:	8d 76 00             	lea    0x0(%esi),%esi
 d10:	39 ef                	cmp    %ebp,%edi
 d12:	76 44                	jbe    d58 <__divdi3+0xa8>
 d14:	31 ed                	xor    %ebp,%ebp
 d16:	31 c9                	xor    %ecx,%ecx
 d18:	89 c8                	mov    %ecx,%eax
 d1a:	8b 0c 24             	mov    (%esp),%ecx
 d1d:	89 ea                	mov    %ebp,%edx
 d1f:	85 c9                	test   %ecx,%ecx
 d21:	74 07                	je     d2a <__divdi3+0x7a>
 d23:	f7 d8                	neg    %eax
 d25:	83 d2 00             	adc    $0x0,%edx
 d28:	f7 da                	neg    %edx
 d2a:	83 c4 10             	add    $0x10,%esp
 d2d:	5e                   	pop    %esi
 d2e:	5f                   	pop    %edi
 d2f:	5d                   	pop    %ebp
 d30:	c3                   	ret    
 d31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 d38:	85 f6                	test   %esi,%esi
 d3a:	75 0b                	jne    d47 <__divdi3+0x97>
 d3c:	b8 01 00 00 00       	mov    $0x1,%eax
 d41:	31 d2                	xor    %edx,%edx
 d43:	f7 f6                	div    %esi
 d45:	89 c6                	mov    %eax,%esi
 d47:	89 e8                	mov    %ebp,%eax
 d49:	31 d2                	xor    %edx,%edx
 d4b:	f7 f6                	div    %esi
 d4d:	89 c5                	mov    %eax,%ebp
 d4f:	89 c8                	mov    %ecx,%eax
 d51:	f7 f6                	div    %esi
 d53:	89 c1                	mov    %eax,%ecx
 d55:	eb c1                	jmp    d18 <__divdi3+0x68>
 d57:	90                   	nop
 d58:	0f bd ff             	bsr    %edi,%edi
 d5b:	83 f7 1f             	xor    $0x1f,%edi
 d5e:	75 48                	jne    da8 <__divdi3+0xf8>
 d60:	8b 7c 24 08          	mov    0x8(%esp),%edi
 d64:	39 7c 24 04          	cmp    %edi,0x4(%esp)
 d68:	76 04                	jbe    d6e <__divdi3+0xbe>
 d6a:	39 e8                	cmp    %ebp,%eax
 d6c:	73 a6                	jae    d14 <__divdi3+0x64>
 d6e:	31 ed                	xor    %ebp,%ebp
 d70:	b9 01 00 00 00       	mov    $0x1,%ecx
 d75:	eb a1                	jmp    d18 <__divdi3+0x68>
 d77:	90                   	nop
 d78:	f7 da                	neg    %edx
 d7a:	8b 74 24 04          	mov    0x4(%esp),%esi
 d7e:	89 c7                	mov    %eax,%edi
 d80:	83 d1 00             	adc    $0x0,%ecx
 d83:	f7 d9                	neg    %ecx
 d85:	85 ed                	test   %ebp,%ebp
 d87:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
 d8e:	0f 89 57 ff ff ff    	jns    ceb <__divdi3+0x3b>
 d94:	f7 de                	neg    %esi
 d96:	83 d7 00             	adc    $0x0,%edi
 d99:	f7 14 24             	notl   (%esp)
 d9c:	f7 df                	neg    %edi
 d9e:	e9 48 ff ff ff       	jmp    ceb <__divdi3+0x3b>
 da3:	90                   	nop
 da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 da8:	89 f9                	mov    %edi,%ecx
 daa:	8b 74 24 04          	mov    0x4(%esp),%esi
 dae:	d3 e0                	shl    %cl,%eax
 db0:	89 c2                	mov    %eax,%edx
 db2:	b8 20 00 00 00       	mov    $0x20,%eax
 db7:	29 f8                	sub    %edi,%eax
 db9:	89 c1                	mov    %eax,%ecx
 dbb:	d3 ee                	shr    %cl,%esi
 dbd:	89 f9                	mov    %edi,%ecx
 dbf:	89 74 24 0c          	mov    %esi,0xc(%esp)
 dc3:	8b 74 24 04          	mov    0x4(%esp),%esi
 dc7:	09 54 24 0c          	or     %edx,0xc(%esp)
 dcb:	89 ea                	mov    %ebp,%edx
 dcd:	d3 e6                	shl    %cl,%esi
 dcf:	89 c1                	mov    %eax,%ecx
 dd1:	89 74 24 04          	mov    %esi,0x4(%esp)
 dd5:	8b 74 24 08          	mov    0x8(%esp),%esi
 dd9:	d3 ea                	shr    %cl,%edx
 ddb:	89 f9                	mov    %edi,%ecx
 ddd:	d3 e5                	shl    %cl,%ebp
 ddf:	89 c1                	mov    %eax,%ecx
 de1:	d3 ee                	shr    %cl,%esi
 de3:	09 ee                	or     %ebp,%esi
 de5:	89 f0                	mov    %esi,%eax
 de7:	f7 74 24 0c          	divl   0xc(%esp)
 deb:	89 d5                	mov    %edx,%ebp
 ded:	89 c6                	mov    %eax,%esi
 def:	f7 64 24 04          	mull   0x4(%esp)
 df3:	39 d5                	cmp    %edx,%ebp
 df5:	89 54 24 04          	mov    %edx,0x4(%esp)
 df9:	72 1d                	jb     e18 <__divdi3+0x168>
 dfb:	8b 54 24 08          	mov    0x8(%esp),%edx
 dff:	89 f9                	mov    %edi,%ecx
 e01:	d3 e2                	shl    %cl,%edx
 e03:	39 c2                	cmp    %eax,%edx
 e05:	73 06                	jae    e0d <__divdi3+0x15d>
 e07:	3b 6c 24 04          	cmp    0x4(%esp),%ebp
 e0b:	74 0b                	je     e18 <__divdi3+0x168>
 e0d:	89 f1                	mov    %esi,%ecx
 e0f:	31 ed                	xor    %ebp,%ebp
 e11:	e9 02 ff ff ff       	jmp    d18 <__divdi3+0x68>
 e16:	66 90                	xchg   %ax,%ax
 e18:	8d 4e ff             	lea    -0x1(%esi),%ecx
 e1b:	31 ed                	xor    %ebp,%ebp
 e1d:	e9 f6 fe ff ff       	jmp    d18 <__divdi3+0x68>
