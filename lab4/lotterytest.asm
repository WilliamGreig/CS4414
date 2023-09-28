
_lotterytest:     file format elf32-i386


Disassembly of section .text:

00000000 <run_forever>:
    }
}

__attribute__((noreturn))
void run_forever() {
    while (1) {
   0:	eb fe                	jmp    0 <run_forever>

00000002 <yield_forever>:
void yield_forever() {
   2:	55                   	push   %ebp
   3:	89 e5                	mov    %esp,%ebp
   5:	83 ec 08             	sub    $0x8,%esp
        yield();
   8:	e8 e5 0a 00 00       	call   af2 <yield>
    while (1) {
   d:	eb f9                	jmp    8 <yield_forever+0x6>

0000000f <iowait_forever>:
        __asm__("");
    }
}

__attribute__((noreturn))
void iowait_forever() {
   f:	55                   	push   %ebp
  10:	89 e5                	mov    %esp,%ebp
  12:	83 ec 24             	sub    $0x24,%esp
    int fds[2];
    pipe(fds);
  15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  18:	50                   	push   %eax
  19:	e8 44 0a 00 00       	call   a62 <pipe>
  1e:	83 c4 10             	add    $0x10,%esp
    while (1) {
        char temp[1];
        read(fds[0], temp, 0);
  21:	83 ec 04             	sub    $0x4,%esp
  24:	6a 00                	push   $0x0
  26:	8d 45 ef             	lea    -0x11(%ebp),%eax
  29:	50                   	push   %eax
  2a:	ff 75 f0             	push   -0x10(%ebp)
  2d:	e8 38 0a 00 00       	call   a6a <read>
    while (1) {
  32:	83 c4 10             	add    $0x10,%esp
  35:	eb ea                	jmp    21 <iowait_forever+0x12>

00000037 <exit_fast>:
    }
}

__attribute__((noreturn))
void exit_fast() {
  37:	55                   	push   %ebp
  38:	89 e5                	mov    %esp,%ebp
  3a:	83 ec 08             	sub    $0x8,%esp
    exit();
  3d:	e8 10 0a 00 00       	call   a52 <exit>

00000042 <spawn>:
}


int spawn(int tickets, function_type function) {
  42:	55                   	push   %ebp
  43:	89 e5                	mov    %esp,%ebp
  45:	53                   	push   %ebx
  46:	83 ec 04             	sub    $0x4,%esp
    int pid = fork();
  49:	e8 fc 09 00 00       	call   a4a <fork>
    if (pid == 0) {
  4e:	85 c0                	test   %eax,%eax
  50:	74 0e                	je     60 <spawn+0x1e>
  52:	89 c3                	mov    %eax,%ebx
        settickets(tickets);
        yield();
        (*function)();
        exit();
    } else if (pid != -1) {
  54:	83 f8 ff             	cmp    $0xffffffff,%eax
  57:	74 1f                	je     78 <spawn+0x36>
        return pid;
    } else {
        printf(2, "error in fork\n");
        return -1;
    }
}
  59:	89 d8                	mov    %ebx,%eax
  5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  5e:	c9                   	leave  
  5f:	c3                   	ret    
        settickets(tickets);
  60:	83 ec 0c             	sub    $0xc,%esp
  63:	ff 75 08             	push   0x8(%ebp)
  66:	e8 a7 0a 00 00       	call   b12 <settickets>
        yield();
  6b:	e8 82 0a 00 00       	call   af2 <yield>
        (*function)();
  70:	ff 55 0c             	call   *0xc(%ebp)
        exit();
  73:	e8 da 09 00 00       	call   a52 <exit>
        printf(2, "error in fork\n");
  78:	83 ec 08             	sub    $0x8,%esp
  7b:	68 80 0e 00 00       	push   $0xe80
  80:	6a 02                	push   $0x2
  82:	e8 40 0b 00 00       	call   bc7 <printf>
        return -1;
  87:	83 c4 10             	add    $0x10,%esp
  8a:	eb cd                	jmp    59 <spawn+0x17>

0000008c <find_index_of_pid>:

int find_index_of_pid(int *list, int list_size, int pid) {
  8c:	55                   	push   %ebp
  8d:	89 e5                	mov    %esp,%ebp
  8f:	53                   	push   %ebx
  90:	8b 5d 08             	mov    0x8(%ebp),%ebx
  93:	8b 55 0c             	mov    0xc(%ebp),%edx
  96:	8b 4d 10             	mov    0x10(%ebp),%ecx
    for (int i = 0; i < list_size; ++i) {
  99:	b8 00 00 00 00       	mov    $0x0,%eax
  9e:	eb 03                	jmp    a3 <find_index_of_pid+0x17>
  a0:	83 c0 01             	add    $0x1,%eax
  a3:	39 d0                	cmp    %edx,%eax
  a5:	7d 07                	jge    ae <find_index_of_pid+0x22>
        if (list[i] == pid)
  a7:	39 0c 83             	cmp    %ecx,(%ebx,%eax,4)
  aa:	75 f4                	jne    a0 <find_index_of_pid+0x14>
  ac:	eb 05                	jmp    b3 <find_index_of_pid+0x27>
            return i;
    }
    return -1;
  ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  b6:	c9                   	leave  
  b7:	c3                   	ret    

000000b8 <wait_for_ticket_counts>:

void wait_for_ticket_counts(int num_children, int *pids, int *tickets) {
  b8:	55                   	push   %ebp
  b9:	89 e5                	mov    %esp,%ebp
  bb:	57                   	push   %edi
  bc:	56                   	push   %esi
  bd:	53                   	push   %ebx
  be:	81 ec 38 03 00 00    	sub    $0x338,%esp
  c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  c7:	8b 7d 10             	mov    0x10(%ebp),%edi
    /* temporarily lower our share to give other processes more of a chance to run
     * their settickets() call */
    settickets(NOT_AS_LARGE_TICKET_COUNT);
  ca:	68 10 27 00 00       	push   $0x2710
  cf:	e8 3e 0a 00 00       	call   b12 <settickets>
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
  d4:	83 c4 10             	add    $0x10,%esp
  d7:	c7 85 d0 fc ff ff 00 	movl   $0x0,-0x330(%ebp)
  de:	00 00 00 
  e1:	83 bd d0 fc ff ff 63 	cmpl   $0x63,-0x330(%ebp)
  e8:	7f 6c                	jg     156 <wait_for_ticket_counts+0x9e>
        yield();
  ea:	e8 03 0a 00 00       	call   af2 <yield>
        int done = 1;
        struct processes_info info;
        getprocessesinfo(&info);
  ef:	83 ec 0c             	sub    $0xc,%esp
  f2:	8d 85 e4 fc ff ff    	lea    -0x31c(%ebp),%eax
  f8:	50                   	push   %eax
  f9:	e8 1c 0a 00 00       	call   b1a <getprocessesinfo>
        for (int i = 0; i < num_children; ++i) {
  fe:	83 c4 10             	add    $0x10,%esp
 101:	bb 00 00 00 00       	mov    $0x0,%ebx
        int done = 1;
 106:	c7 85 d4 fc ff ff 01 	movl   $0x1,-0x32c(%ebp)
 10d:	00 00 00 
        for (int i = 0; i < num_children; ++i) {
 110:	eb 03                	jmp    115 <wait_for_ticket_counts+0x5d>
 112:	83 c3 01             	add    $0x1,%ebx
 115:	3b 5d 08             	cmp    0x8(%ebp),%ebx
 118:	7d 33                	jge    14d <wait_for_ticket_counts+0x95>
            int index = find_index_of_pid(info.pids, info.num_processes, pids[i]);
 11a:	83 ec 04             	sub    $0x4,%esp
 11d:	ff 34 9e             	push   (%esi,%ebx,4)
 120:	ff b5 e4 fc ff ff    	push   -0x31c(%ebp)
 126:	8d 85 e8 fc ff ff    	lea    -0x318(%ebp),%eax
 12c:	50                   	push   %eax
 12d:	e8 5a ff ff ff       	call   8c <find_index_of_pid>
 132:	83 c4 10             	add    $0x10,%esp
            if (info.tickets[index] != tickets[i]) done = 0;
 135:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
 138:	39 94 85 e8 fe ff ff 	cmp    %edx,-0x118(%ebp,%eax,4)
 13f:	74 d1                	je     112 <wait_for_ticket_counts+0x5a>
 141:	c7 85 d4 fc ff ff 00 	movl   $0x0,-0x32c(%ebp)
 148:	00 00 00 
 14b:	eb c5                	jmp    112 <wait_for_ticket_counts+0x5a>
        }
        if (done)
 14d:	83 bd d4 fc ff ff 00 	cmpl   $0x0,-0x32c(%ebp)
 154:	74 18                	je     16e <wait_for_ticket_counts+0xb6>
            break;
    }
    settickets(LARGE_TICKET_COUNT);
 156:	83 ec 0c             	sub    $0xc,%esp
 159:	68 a0 86 01 00       	push   $0x186a0
 15e:	e8 af 09 00 00       	call   b12 <settickets>
}
 163:	83 c4 10             	add    $0x10,%esp
 166:	8d 65 f4             	lea    -0xc(%ebp),%esp
 169:	5b                   	pop    %ebx
 16a:	5e                   	pop    %esi
 16b:	5f                   	pop    %edi
 16c:	5d                   	pop    %ebp
 16d:	c3                   	ret    
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
 16e:	83 85 d0 fc ff ff 01 	addl   $0x1,-0x330(%ebp)
 175:	e9 67 ff ff ff       	jmp    e1 <wait_for_ticket_counts+0x29>

0000017a <check>:

void check(struct test_case* test, int passed_p, const char *description) {
 17a:	55                   	push   %ebp
 17b:	89 e5                	mov    %esp,%ebp
 17d:	83 ec 08             	sub    $0x8,%esp
 180:	8b 55 08             	mov    0x8(%ebp),%edx
    test->total_tests++;
 183:	8b 42 04             	mov    0x4(%edx),%eax
 186:	83 c0 01             	add    $0x1,%eax
 189:	89 42 04             	mov    %eax,0x4(%edx)
    if (!passed_p) {
 18c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 190:	74 02                	je     194 <check+0x1a>
        test->errors++;
        printf(1, "*** TEST FAILURE: for scenario '%s': %s\n", test->name, description);
    }
}
 192:	c9                   	leave  
 193:	c3                   	ret    
        test->errors++;
 194:	8b 42 08             	mov    0x8(%edx),%eax
 197:	83 c0 01             	add    $0x1,%eax
 19a:	89 42 08             	mov    %eax,0x8(%edx)
        printf(1, "*** TEST FAILURE: for scenario '%s': %s\n", test->name, description);
 19d:	ff 75 10             	push   0x10(%ebp)
 1a0:	ff 32                	push   (%edx)
 1a2:	68 48 0f 00 00       	push   $0xf48
 1a7:	6a 01                	push   $0x1
 1a9:	e8 19 0a 00 00       	call   bc7 <printf>
 1ae:	83 c4 10             	add    $0x10,%esp
}
 1b1:	eb df                	jmp    192 <check+0x18>

000001b3 <execute_and_get_info>:

void execute_and_get_info(
        struct test_case* test, int *pids,
        struct processes_info *before,
        struct processes_info *after) {
 1b3:	55                   	push   %ebp
 1b4:	89 e5                	mov    %esp,%ebp
 1b6:	57                   	push   %edi
 1b7:	56                   	push   %esi
 1b8:	53                   	push   %ebx
 1b9:	83 ec 18             	sub    $0x18,%esp
 1bc:	8b 75 08             	mov    0x8(%ebp),%esi
    settickets(LARGE_TICKET_COUNT);
 1bf:	68 a0 86 01 00       	push   $0x186a0
 1c4:	e8 49 09 00 00       	call   b12 <settickets>
    for (int i = 0; i < test->num_children; ++i) {
 1c9:	83 c4 10             	add    $0x10,%esp
 1cc:	bb 00 00 00 00       	mov    $0x0,%ebx
 1d1:	eb 21                	jmp    1f4 <execute_and_get_info+0x41>
        pids[i] = spawn(test->tickets[i], test->functions[i]);
 1d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d6:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
 1d9:	83 ec 08             	sub    $0x8,%esp
 1dc:	ff b4 9e 94 01 00 00 	push   0x194(%esi,%ebx,4)
 1e3:	ff 74 9e 10          	push   0x10(%esi,%ebx,4)
 1e7:	e8 56 fe ff ff       	call   42 <spawn>
 1ec:	89 07                	mov    %eax,(%edi)
    for (int i = 0; i < test->num_children; ++i) {
 1ee:	83 c3 01             	add    $0x1,%ebx
 1f1:	83 c4 10             	add    $0x10,%esp
 1f4:	8b 46 0c             	mov    0xc(%esi),%eax
 1f7:	39 d8                	cmp    %ebx,%eax
 1f9:	7f d8                	jg     1d3 <execute_and_get_info+0x20>
    }
    wait_for_ticket_counts(test->num_children, pids, test->tickets);
 1fb:	8d 56 10             	lea    0x10(%esi),%edx
 1fe:	83 ec 04             	sub    $0x4,%esp
 201:	52                   	push   %edx
 202:	ff 75 0c             	push   0xc(%ebp)
 205:	50                   	push   %eax
 206:	e8 ad fe ff ff       	call   b8 <wait_for_ticket_counts>
    before->num_processes = after->num_processes = -1;
 20b:	8b 45 14             	mov    0x14(%ebp),%eax
 20e:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
 214:	8b 45 10             	mov    0x10(%ebp),%eax
 217:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    sleep(WARMUP_TIME);
 21d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
 224:	e8 b9 08 00 00       	call   ae2 <sleep>
    getprocessesinfo(before);
 229:	83 c4 04             	add    $0x4,%esp
 22c:	ff 75 10             	push   0x10(%ebp)
 22f:	e8 e6 08 00 00       	call   b1a <getprocessesinfo>
    sleep(SLEEP_TIME);
 234:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
 23b:	e8 a2 08 00 00       	call   ae2 <sleep>
    getprocessesinfo(after);
 240:	83 c4 04             	add    $0x4,%esp
 243:	ff 75 14             	push   0x14(%ebp)
 246:	e8 cf 08 00 00       	call   b1a <getprocessesinfo>
    for (int i = 0; i < test->num_children; ++i) {
 24b:	83 c4 10             	add    $0x10,%esp
 24e:	bb 00 00 00 00       	mov    $0x0,%ebx
 253:	8b 7d 0c             	mov    0xc(%ebp),%edi
 256:	eb 11                	jmp    269 <execute_and_get_info+0xb6>
        kill(pids[i]);
 258:	83 ec 0c             	sub    $0xc,%esp
 25b:	ff 34 9f             	push   (%edi,%ebx,4)
 25e:	e8 1f 08 00 00       	call   a82 <kill>
    for (int i = 0; i < test->num_children; ++i) {
 263:	83 c3 01             	add    $0x1,%ebx
 266:	83 c4 10             	add    $0x10,%esp
 269:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 26c:	7f ea                	jg     258 <execute_and_get_info+0xa5>
    }
    for (int i = 0; i < test->num_children; ++i) {
 26e:	bb 00 00 00 00       	mov    $0x0,%ebx
 273:	eb 08                	jmp    27d <execute_and_get_info+0xca>
        wait();
 275:	e8 e0 07 00 00       	call   a5a <wait>
    for (int i = 0; i < test->num_children; ++i) {
 27a:	83 c3 01             	add    $0x1,%ebx
 27d:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 280:	7f f3                	jg     275 <execute_and_get_info+0xc2>
    }
}
 282:	8d 65 f4             	lea    -0xc(%ebp),%esp
 285:	5b                   	pop    %ebx
 286:	5e                   	pop    %esi
 287:	5f                   	pop    %edi
 288:	5d                   	pop    %ebp
 289:	c3                   	ret    

0000028a <count_schedules>:

void count_schedules(
        struct test_case *test, int *pids,
        struct processes_info *before,
        struct processes_info *after) {
 28a:	55                   	push   %ebp
 28b:	89 e5                	mov    %esp,%ebp
 28d:	57                   	push   %edi
 28e:	56                   	push   %esi
 28f:	53                   	push   %ebx
 290:	83 ec 1c             	sub    $0x1c,%esp
 293:	8b 5d 08             	mov    0x8(%ebp),%ebx
    test->total_actual_schedules = 0;
 296:	c7 83 90 01 00 00 00 	movl   $0x0,0x190(%ebx)
 29d:	00 00 00 
    for (int i = 0; i < test->num_children; ++i) {
 2a0:	bf 00 00 00 00       	mov    $0x0,%edi
 2a5:	eb 4e                	jmp    2f5 <count_schedules+0x6b>
        int after_index = find_index_of_pid(after->pids, after->num_processes, pids[i]);
        check(test,
              before_index >= 0 && after_index >= 0,
              "subprocess's pid appeared in getprocessesinfo output");
        if (before_index >= 0 && after_index >= 0) {
            check(test,
 2a7:	8b 55 14             	mov    0x14(%ebp),%edx
 2aa:	3b 84 b2 04 02 00 00 	cmp    0x204(%edx,%esi,4),%eax
 2b1:	0f 84 c8 00 00 00    	je     37f <count_schedules+0xf5>
 2b7:	b8 00 00 00 00       	mov    $0x0,%eax
 2bc:	83 ec 04             	sub    $0x4,%esp
 2bf:	68 ac 0f 00 00       	push   $0xfac
 2c4:	50                   	push   %eax
 2c5:	53                   	push   %ebx
 2c6:	e8 af fe ff ff       	call   17a <check>
                  test->tickets[i] == before->tickets[before_index] &&
                  test->tickets[i] == after->tickets[after_index],
                  "subprocess assigned correct number of tickets");
            test->actual_schedules[i] = after->times_scheduled[after_index] - before->times_scheduled[before_index];
 2cb:	8b 45 14             	mov    0x14(%ebp),%eax
 2ce:	8b 84 b0 04 01 00 00 	mov    0x104(%eax,%esi,4),%eax
 2d5:	8b 75 10             	mov    0x10(%ebp),%esi
 2d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2db:	2b 84 96 04 01 00 00 	sub    0x104(%esi,%edx,4),%eax
 2e2:	89 84 bb 10 01 00 00 	mov    %eax,0x110(%ebx,%edi,4)
            test->total_actual_schedules += test->actual_schedules[i];
 2e9:	01 83 90 01 00 00    	add    %eax,0x190(%ebx)
 2ef:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < test->num_children; ++i) {
 2f2:	83 c7 01             	add    $0x1,%edi
 2f5:	39 7b 0c             	cmp    %edi,0xc(%ebx)
 2f8:	0f 8e 9b 00 00 00    	jle    399 <count_schedules+0x10f>
        int before_index = find_index_of_pid(before->pids, before->num_processes, pids[i]);
 2fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 301:	8b 34 b8             	mov    (%eax,%edi,4),%esi
 304:	8b 45 10             	mov    0x10(%ebp),%eax
 307:	83 c0 04             	add    $0x4,%eax
 30a:	83 ec 04             	sub    $0x4,%esp
 30d:	56                   	push   %esi
 30e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 311:	ff 31                	push   (%ecx)
 313:	50                   	push   %eax
 314:	e8 73 fd ff ff       	call   8c <find_index_of_pid>
 319:	83 c4 0c             	add    $0xc,%esp
 31c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        int after_index = find_index_of_pid(after->pids, after->num_processes, pids[i]);
 31f:	8b 4d 14             	mov    0x14(%ebp),%ecx
 322:	8d 41 04             	lea    0x4(%ecx),%eax
 325:	56                   	push   %esi
 326:	ff 31                	push   (%ecx)
 328:	50                   	push   %eax
 329:	e8 5e fd ff ff       	call   8c <find_index_of_pid>
 32e:	83 c4 0c             	add    $0xc,%esp
 331:	89 c6                	mov    %eax,%esi
              before_index >= 0 && after_index >= 0,
 333:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 336:	f7 d2                	not    %edx
 338:	c1 ea 1f             	shr    $0x1f,%edx
 33b:	f7 d0                	not    %eax
 33d:	c1 e8 1f             	shr    $0x1f,%eax
        check(test,
 340:	89 c1                	mov    %eax,%ecx
 342:	21 d1                	and    %edx,%ecx
 344:	88 4d e3             	mov    %cl,-0x1d(%ebp)
 347:	68 74 0f 00 00       	push   $0xf74
 34c:	21 d0                	and    %edx,%eax
 34e:	50                   	push   %eax
 34f:	53                   	push   %ebx
 350:	e8 25 fe ff ff       	call   17a <check>
        if (before_index >= 0 && after_index >= 0) {
 355:	83 c4 10             	add    $0x10,%esp
 358:	80 7d e3 00          	cmpb   $0x0,-0x1d(%ebp)
 35c:	74 2b                	je     389 <count_schedules+0xff>
                  test->tickets[i] == before->tickets[before_index] &&
 35e:	8b 44 bb 10          	mov    0x10(%ebx,%edi,4),%eax
            check(test,
 362:	8b 4d 10             	mov    0x10(%ebp),%ecx
 365:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 368:	3b 84 91 04 02 00 00 	cmp    0x204(%ecx,%edx,4),%eax
 36f:	0f 84 32 ff ff ff    	je     2a7 <count_schedules+0x1d>
 375:	b8 00 00 00 00       	mov    $0x0,%eax
 37a:	e9 3d ff ff ff       	jmp    2bc <count_schedules+0x32>
 37f:	b8 01 00 00 00       	mov    $0x1,%eax
 384:	e9 33 ff ff ff       	jmp    2bc <count_schedules+0x32>
        } else {
            test->actual_schedules[i] = -99999; // obviously bogus count that will fail checks later
 389:	c7 84 bb 10 01 00 00 	movl   $0xfffe7961,0x110(%ebx,%edi,4)
 390:	61 79 fe ff 
 394:	e9 59 ff ff ff       	jmp    2f2 <count_schedules+0x68>
        }
    }
}
 399:	8d 65 f4             	lea    -0xc(%ebp),%esp
 39c:	5b                   	pop    %ebx
 39d:	5e                   	pop    %esi
 39e:	5f                   	pop    %edi
 39f:	5d                   	pop    %ebp
 3a0:	c3                   	ret    

000003a1 <dump_test_timings>:

void dump_test_timings(struct test_case *test) {
 3a1:	55                   	push   %ebp
 3a2:	89 e5                	mov    %esp,%ebp
 3a4:	56                   	push   %esi
 3a5:	53                   	push   %ebx
 3a6:	8b 75 08             	mov    0x8(%ebp),%esi
    printf(1, "-----------------------------------------\n");
 3a9:	83 ec 08             	sub    $0x8,%esp
 3ac:	68 dc 0f 00 00       	push   $0xfdc
 3b1:	6a 01                	push   $0x1
 3b3:	e8 0f 08 00 00       	call   bc7 <printf>
    printf(1, "%s expected schedules ratios and observations\n", test->name);
 3b8:	83 c4 0c             	add    $0xc,%esp
 3bb:	ff 36                	push   (%esi)
 3bd:	68 08 10 00 00       	push   $0x1008
 3c2:	6a 01                	push   $0x1
 3c4:	e8 fe 07 00 00       	call   bc7 <printf>
    printf(1, "#\texpect\tobserve\t(description)\n");
 3c9:	83 c4 08             	add    $0x8,%esp
 3cc:	68 38 10 00 00       	push   $0x1038
 3d1:	6a 01                	push   $0x1
 3d3:	e8 ef 07 00 00       	call   bc7 <printf>
    for (int i = 0; i < test->num_children; ++i) {
 3d8:	83 c4 10             	add    $0x10,%esp
 3db:	bb 00 00 00 00       	mov    $0x0,%ebx
 3e0:	eb 2e                	jmp    410 <dump_test_timings+0x6f>
        const char *assigned_function = "(unknown)";
        if (test->functions[i] == yield_forever) {
            assigned_function = "yield_forever";
 3e2:	b8 8f 0e 00 00       	mov    $0xe8f,%eax
        } else if (test->functions[i] == iowait_forever) {
            assigned_function = "iowait_forever";
        } else if (test->functions[i] == exit_fast) {
            assigned_function = "exit_fast";
        }
        printf(1, "%d\t%d\t%d\t(assigned %d tickets; running %s)\n",
 3e7:	83 ec 04             	sub    $0x4,%esp
 3ea:	50                   	push   %eax
 3eb:	ff 74 9e 10          	push   0x10(%esi,%ebx,4)
 3ef:	ff b4 9e 10 01 00 00 	push   0x110(%esi,%ebx,4)
 3f6:	ff b4 9e 90 00 00 00 	push   0x90(%esi,%ebx,4)
 3fd:	53                   	push   %ebx
 3fe:	68 58 10 00 00       	push   $0x1058
 403:	6a 01                	push   $0x1
 405:	e8 bd 07 00 00       	call   bc7 <printf>
    for (int i = 0; i < test->num_children; ++i) {
 40a:	83 c3 01             	add    $0x1,%ebx
 40d:	83 c4 20             	add    $0x20,%esp
 410:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 413:	7e 3f                	jle    454 <dump_test_timings+0xb3>
        if (test->functions[i] == yield_forever) {
 415:	8b 84 9e 94 01 00 00 	mov    0x194(%esi,%ebx,4),%eax
 41c:	3d 02 00 00 00       	cmp    $0x2,%eax
 421:	74 bf                	je     3e2 <dump_test_timings+0x41>
        } else if (test->functions[i] == run_forever) {
 423:	3d 00 00 00 00       	cmp    $0x0,%eax
 428:	74 15                	je     43f <dump_test_timings+0x9e>
        } else if (test->functions[i] == iowait_forever) {
 42a:	3d 0f 00 00 00       	cmp    $0xf,%eax
 42f:	74 15                	je     446 <dump_test_timings+0xa5>
        } else if (test->functions[i] == exit_fast) {
 431:	3d 37 00 00 00       	cmp    $0x37,%eax
 436:	74 15                	je     44d <dump_test_timings+0xac>
        const char *assigned_function = "(unknown)";
 438:	b8 b8 0e 00 00       	mov    $0xeb8,%eax
 43d:	eb a8                	jmp    3e7 <dump_test_timings+0x46>
            assigned_function = "run_forever";
 43f:	b8 9d 0e 00 00       	mov    $0xe9d,%eax
 444:	eb a1                	jmp    3e7 <dump_test_timings+0x46>
            assigned_function = "iowait_forever";
 446:	b8 a9 0e 00 00       	mov    $0xea9,%eax
 44b:	eb 9a                	jmp    3e7 <dump_test_timings+0x46>
            assigned_function = "exit_fast";
 44d:	b8 c2 0e 00 00       	mov    $0xec2,%eax
 452:	eb 93                	jmp    3e7 <dump_test_timings+0x46>
            test->expect_schedules_unscaled[i],
            test->actual_schedules[i],
            test->tickets[i],
            assigned_function);
    }
    printf(1, "\nNOTE: the 'expect' values above represent the expected\n"
 454:	83 ec 08             	sub    $0x8,%esp
 457:	68 84 10 00 00       	push   $0x1084
 45c:	6a 01                	push   $0x1
 45e:	e8 64 07 00 00       	call   bc7 <printf>
              "      ratio of schedules between the processes. So, to compare\n"
              "      them to the observations by hand, multiply each expected\n"
              "      value by (sum of observed)/(sum of expected)\n");
    printf(1, "-----------------------------------------\n");
 463:	83 c4 08             	add    $0x8,%esp
 466:	68 dc 0f 00 00       	push   $0xfdc
 46b:	6a 01                	push   $0x1
 46d:	e8 55 07 00 00       	call   bc7 <printf>
}
 472:	83 c4 10             	add    $0x10,%esp
 475:	8d 65 f8             	lea    -0x8(%ebp),%esp
 478:	5b                   	pop    %ebx
 479:	5e                   	pop    %esi
 47a:	5d                   	pop    %ebp
 47b:	c3                   	ret    

0000047c <compare_schedules_chi_squared>:
    FIXED_POINT_BASE / 100 * 2612,
    FIXED_POINT_BASE / 100 * 2788,
    FIXED_POINT_BASE / 100 * 2959,
};

int compare_schedules_chi_squared(struct test_case *test) {
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	57                   	push   %edi
 480:	56                   	push   %esi
 481:	53                   	push   %ebx
 482:	83 ec 3c             	sub    $0x3c,%esp
 485:	8b 7d 08             	mov    0x8(%ebp),%edi
    if (test->num_children < 2) {
 488:	8b 47 0c             	mov    0xc(%edi),%eax
 48b:	89 45 dc             	mov    %eax,-0x24(%ebp)
 48e:	83 f8 01             	cmp    $0x1,%eax
 491:	0f 8e a8 01 00 00    	jle    63f <compare_schedules_chi_squared+0x1c3>
        return 1;
    }
    long long expect_schedules_total = 0;
    for (int i = 0; i < test->num_children; ++i) {
 497:	b9 00 00 00 00       	mov    $0x0,%ecx
    long long expect_schedules_total = 0;
 49c:	bb 00 00 00 00       	mov    $0x0,%ebx
 4a1:	be 00 00 00 00       	mov    $0x0,%esi
 4a6:	eb 0f                	jmp    4b7 <compare_schedules_chi_squared+0x3b>
        expect_schedules_total += test->expect_schedules_unscaled[i];
 4a8:	8b 84 8f 90 00 00 00 	mov    0x90(%edi,%ecx,4),%eax
 4af:	99                   	cltd   
 4b0:	01 c3                	add    %eax,%ebx
 4b2:	11 d6                	adc    %edx,%esi
    for (int i = 0; i < test->num_children; ++i) {
 4b4:	83 c1 01             	add    $0x1,%ecx
 4b7:	39 4d dc             	cmp    %ecx,-0x24(%ebp)
 4ba:	7f ec                	jg     4a8 <compare_schedules_chi_squared+0x2c>
       a better solution would be to use a statistical test that can handle this case,
       like Fisher's exact test.
    */
    long long delta = 0;
    int skipped = 0;
    for (int i = 0; i < test->num_children; ++i) {
 4bc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 4bf:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 4c2:	be 00 00 00 00       	mov    $0x0,%esi
    int skipped = 0;
 4c7:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
    long long delta = 0;
 4ce:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
 4d5:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 4dc:	eb 19                	jmp    4f7 <compare_schedules_chi_squared+0x7b>
            (int)(scaled_expected >> FIXED_POINT_COUNT),
            (int) expect_schedules_total,
            test->total_actual_schedules);
#endif
        if (scaled_expected == 0) {
            ++skipped;
 4de:	83 45 c4 01          	addl   $0x1,-0x3c(%ebp)
            continue;
 4e2:	eb 10                	jmp    4f4 <compare_schedules_chi_squared+0x78>
        if (scaled_expected > 0) {
            // cur_delta <<= FIXED_POINT_COUNT;
            cur_delta /= scaled_expected;
        } else {
            /* a huge number to make sure statistical test fails */
            cur_delta = FIXED_POINT_BASE * 100000LL;
 4e4:	b8 00 80 1a 06       	mov    $0x61a8000,%eax
 4e9:	ba 00 00 00 00       	mov    $0x0,%edx
        }
#ifdef DEBUG
        printf(1, "cur_delta = %x/%x\n", (int) cur_delta, (int) (cur_delta >> 32));
#endif
        delta += cur_delta;
 4ee:	01 45 c8             	add    %eax,-0x38(%ebp)
 4f1:	11 55 cc             	adc    %edx,-0x34(%ebp)
    for (int i = 0; i < test->num_children; ++i) {
 4f4:	83 c6 01             	add    $0x1,%esi
 4f7:	39 75 dc             	cmp    %esi,-0x24(%ebp)
 4fa:	0f 8e 9b 00 00 00    	jle    59b <compare_schedules_chi_squared+0x11f>
        long long scaled_expected = (test->expect_schedules_unscaled[i] << FIXED_POINT_COUNT) / expect_schedules_total
 500:	8b 84 b7 90 00 00 00 	mov    0x90(%edi,%esi,4),%eax
 507:	c1 e0 0a             	shl    $0xa,%eax
 50a:	99                   	cltd   
 50b:	ff 75 d4             	push   -0x2c(%ebp)
 50e:	ff 75 d0             	push   -0x30(%ebp)
 511:	52                   	push   %edx
 512:	50                   	push   %eax
 513:	e8 18 08 00 00       	call   d30 <__divdi3>
 518:	83 c4 10             	add    $0x10,%esp
 51b:	89 45 d8             	mov    %eax,-0x28(%ebp)
                             * test->total_actual_schedules;
 51e:	8b 9f 90 01 00 00    	mov    0x190(%edi),%ebx
 524:	89 5d e0             	mov    %ebx,-0x20(%ebp)
 527:	c1 fb 1f             	sar    $0x1f,%ebx
        long long scaled_expected = (test->expect_schedules_unscaled[i] << FIXED_POINT_COUNT) / expect_schedules_total
 52a:	89 d0                	mov    %edx,%eax
 52c:	0f af 45 e0          	imul   -0x20(%ebp),%eax
 530:	89 d9                	mov    %ebx,%ecx
 532:	8b 5d d8             	mov    -0x28(%ebp),%ebx
 535:	0f af cb             	imul   %ebx,%ecx
 538:	01 c1                	add    %eax,%ecx
 53a:	89 d8                	mov    %ebx,%eax
 53c:	f7 65 e0             	mull   -0x20(%ebp)
 53f:	89 45 e0             	mov    %eax,-0x20(%ebp)
 542:	89 55 e4             	mov    %edx,-0x1c(%ebp)
 545:	01 d1                	add    %edx,%ecx
 547:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
        if (scaled_expected == 0) {
 54a:	8b 45 e0             	mov    -0x20(%ebp),%eax
 54d:	09 c1                	or     %eax,%ecx
 54f:	74 8d                	je     4de <compare_schedules_chi_squared+0x62>
        long long cur_delta = scaled_expected - (test->actual_schedules[i] << FIXED_POINT_COUNT);
 551:	8b 84 b7 10 01 00 00 	mov    0x110(%edi,%esi,4),%eax
 558:	c1 e0 0a             	shl    $0xa,%eax
 55b:	99                   	cltd   
 55c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 55f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
 562:	29 c1                	sub    %eax,%ecx
 564:	19 d3                	sbb    %edx,%ebx
 566:	89 c8                	mov    %ecx,%eax
        cur_delta *= cur_delta;
 568:	0f af d9             	imul   %ecx,%ebx
 56b:	01 db                	add    %ebx,%ebx
 56d:	f7 e1                	mul    %ecx
 56f:	89 d1                	mov    %edx,%ecx
 571:	89 c2                	mov    %eax,%edx
 573:	01 d9                	add    %ebx,%ecx
        if (scaled_expected > 0) {
 575:	b8 00 00 00 00       	mov    $0x0,%eax
 57a:	3b 45 e0             	cmp    -0x20(%ebp),%eax
 57d:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
 580:	0f 8d 5e ff ff ff    	jge    4e4 <compare_schedules_chi_squared+0x68>
            cur_delta /= scaled_expected;
 586:	ff 75 e4             	push   -0x1c(%ebp)
 589:	ff 75 e0             	push   -0x20(%ebp)
 58c:	51                   	push   %ecx
 58d:	52                   	push   %edx
 58e:	e8 9d 07 00 00       	call   d30 <__divdi3>
 593:	83 c4 10             	add    $0x10,%esp
 596:	e9 53 ff ff ff       	jmp    4ee <compare_schedules_chi_squared+0x72>
    }
#ifdef DEBUG
    printf(1, "%s test statistic %d (rounded)\n", test->name, (int) ((delta + FIXED_POINT_BASE / 2) >> FIXED_POINT_COUNT));
#endif
    int degrees_of_freedom = test->num_children - 1 - skipped;
 59b:	8b 45 dc             	mov    -0x24(%ebp),%eax
 59e:	83 e8 01             	sub    $0x1,%eax
 5a1:	2b 45 c4             	sub    -0x3c(%ebp),%eax
    long long expected_value = chi_squared_thresholds[degrees_of_freedom - 1];
 5a4:	83 e8 01             	sub    $0x1,%eax
 5a7:	8b 14 c5 00 15 00 00 	mov    0x1500(,%eax,8),%edx
 5ae:	89 55 e0             	mov    %edx,-0x20(%ebp)
 5b1:	8b 34 c5 04 15 00 00 	mov    0x1504(,%eax,8),%esi
    int passed_threshold = delta < expected_value;
 5b8:	bb 01 00 00 00       	mov    $0x1,%ebx
 5bd:	89 d1                	mov    %edx,%ecx
 5bf:	8b 45 c8             	mov    -0x38(%ebp),%eax
 5c2:	8b 55 cc             	mov    -0x34(%ebp),%edx
 5c5:	39 c8                	cmp    %ecx,%eax
 5c7:	89 d0                	mov    %edx,%eax
 5c9:	19 f0                	sbb    %esi,%eax
 5cb:	7c 05                	jl     5d2 <compare_schedules_chi_squared+0x156>
 5cd:	bb 00 00 00 00       	mov    $0x0,%ebx
 5d2:	0f b6 db             	movzbl %bl,%ebx
    check(test, passed_threshold,
 5d5:	83 ec 04             	sub    $0x4,%esp
 5d8:	68 70 11 00 00       	push   $0x1170
 5dd:	53                   	push   %ebx
 5de:	57                   	push   %edi
 5df:	e8 96 fb ff ff       	call   17a <check>
          "distribution of schedules run passed chi-squared test "
          "for being same as expected");
    if (!passed_threshold) {
 5e4:	83 c4 10             	add    $0x10,%esp
 5e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 5ea:	8b 45 c8             	mov    -0x38(%ebp),%eax
 5ed:	8b 55 cc             	mov    -0x34(%ebp),%edx
 5f0:	39 c8                	cmp    %ecx,%eax
 5f2:	89 d0                	mov    %edx,%eax
 5f4:	19 f0                	sbb    %esi,%eax
 5f6:	7d 39                	jge    631 <compare_schedules_chi_squared+0x1b5>
        dump_test_timings(test);
    }
    check(test, test->total_actual_schedules >
 5f8:	8b 97 90 01 00 00    	mov    0x190(%edi),%edx
                (test->override_min_schedules == 0 ? MIN_SCHEDULES : test->override_min_schedules),
 5fe:	8b 87 14 02 00 00    	mov    0x214(%edi),%eax
 604:	85 c0                	test   %eax,%eax
 606:	75 05                	jne    60d <compare_schedules_chi_squared+0x191>
 608:	b8 d0 07 00 00       	mov    $0x7d0,%eax
    check(test, test->total_actual_schedules >
 60d:	83 ec 04             	sub    $0x4,%esp
 610:	68 c4 11 00 00       	push   $0x11c4
 615:	39 c2                	cmp    %eax,%edx
 617:	0f 9f c0             	setg   %al
 61a:	0f b6 c0             	movzbl %al,%eax
 61d:	50                   	push   %eax
 61e:	57                   	push   %edi
 61f:	e8 56 fb ff ff       	call   17a <check>
          "threads scheduled enough times to get significant sample\n"
          "if you are properly recording times_scheduled, then this might\n"
          "just mean that SLEEP_TIME in lotterytest.c should be increased\n"
          "to get a larger sample");
    return passed_threshold;
 624:	83 c4 10             	add    $0x10,%esp
}
 627:	89 d8                	mov    %ebx,%eax
 629:	8d 65 f4             	lea    -0xc(%ebp),%esp
 62c:	5b                   	pop    %ebx
 62d:	5e                   	pop    %esi
 62e:	5f                   	pop    %edi
 62f:	5d                   	pop    %ebp
 630:	c3                   	ret    
        dump_test_timings(test);
 631:	83 ec 0c             	sub    $0xc,%esp
 634:	57                   	push   %edi
 635:	e8 67 fd ff ff       	call   3a1 <dump_test_timings>
 63a:	83 c4 10             	add    $0x10,%esp
 63d:	eb b9                	jmp    5f8 <compare_schedules_chi_squared+0x17c>
        return 1;
 63f:	bb 01 00 00 00       	mov    $0x1,%ebx
 644:	eb e1                	jmp    627 <compare_schedules_chi_squared+0x1ab>

00000646 <compare_schedules_naive>:

   This hopefully will detect cases where a biased random
   number generator is in use but otherwise the implementation
   is generally okay.
 */
void compare_schedules_naive(struct test_case *test) {
 646:	55                   	push   %ebp
 647:	89 e5                	mov    %esp,%ebp
 649:	57                   	push   %edi
 64a:	56                   	push   %esi
 64b:	53                   	push   %ebx
 64c:	83 ec 3c             	sub    $0x3c,%esp
    if (test->num_children < 2) {
 64f:	8b 45 08             	mov    0x8(%ebp),%eax
 652:	8b 48 0c             	mov    0xc(%eax),%ecx
 655:	89 4d c0             	mov    %ecx,-0x40(%ebp)
 658:	83 f9 01             	cmp    $0x1,%ecx
 65b:	0f 8e 45 02 00 00    	jle    8a6 <compare_schedules_naive+0x260>
        return;
    }
    int expect_schedules_total = 0;
    for (int i = 0; i < test->num_children; ++i) {
 661:	b8 00 00 00 00       	mov    $0x0,%eax
    int expect_schedules_total = 0;
 666:	ba 00 00 00 00       	mov    $0x0,%edx
 66b:	8b 5d 08             	mov    0x8(%ebp),%ebx
 66e:	eb 0a                	jmp    67a <compare_schedules_naive+0x34>
        expect_schedules_total += test->expect_schedules_unscaled[i];
 670:	03 94 83 90 00 00 00 	add    0x90(%ebx,%eax,4),%edx
    for (int i = 0; i < test->num_children; ++i) {
 677:	83 c0 01             	add    $0x1,%eax
 67a:	39 c1                	cmp    %eax,%ecx
 67c:	7f f2                	jg     670 <compare_schedules_naive+0x2a>
    }
    int failed_any = 0;
    for (int i = 0; i < test->num_children; ++i) {
 67e:	89 55 bc             	mov    %edx,-0x44(%ebp)
 681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    int failed_any = 0;
 688:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
 68f:	eb 0b                	jmp    69c <compare_schedules_naive+0x56>
        long long scaled_expected = ((long long) test->expect_schedules_unscaled[i] * test->total_actual_schedules) / expect_schedules_total;
        int max_expected = scaled_expected * 11 / 10 + 10;
        int min_expected = scaled_expected * 9 / 10 - 10;
        int in_range = (test->actual_schedules[i] >= min_expected && test->actual_schedules[i] <= max_expected);
        if (!in_range) {
            failed_any = 1;
 691:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
    for (int i = 0; i < test->num_children; ++i) {
 698:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 69c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 69f:	39 7d c0             	cmp    %edi,-0x40(%ebp)
 6a2:	0f 8e de 01 00 00    	jle    886 <compare_schedules_naive+0x240>
        long long scaled_expected = ((long long) test->expect_schedules_unscaled[i] * test->total_actual_schedules) / expect_schedules_total;
 6a8:	8b 7d 08             	mov    0x8(%ebp),%edi
 6ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ae:	8b 94 87 90 00 00 00 	mov    0x90(%edi,%eax,4),%edx
 6b5:	89 d3                	mov    %edx,%ebx
 6b7:	c1 fb 1f             	sar    $0x1f,%ebx
 6ba:	8b 87 90 01 00 00    	mov    0x190(%edi),%eax
 6c0:	89 c7                	mov    %eax,%edi
 6c2:	c1 ff 1f             	sar    $0x1f,%edi
 6c5:	89 d9                	mov    %ebx,%ecx
 6c7:	0f af c8             	imul   %eax,%ecx
 6ca:	89 fb                	mov    %edi,%ebx
 6cc:	0f af da             	imul   %edx,%ebx
 6cf:	01 d9                	add    %ebx,%ecx
 6d1:	f7 e2                	mul    %edx
 6d3:	01 ca                	add    %ecx,%edx
 6d5:	8b 4d bc             	mov    -0x44(%ebp),%ecx
 6d8:	89 cb                	mov    %ecx,%ebx
 6da:	c1 fb 1f             	sar    $0x1f,%ebx
 6dd:	53                   	push   %ebx
 6de:	51                   	push   %ecx
 6df:	52                   	push   %edx
 6e0:	50                   	push   %eax
 6e1:	e8 4a 06 00 00       	call   d30 <__divdi3>
 6e6:	83 c4 10             	add    $0x10,%esp
 6e9:	89 c6                	mov    %eax,%esi
        int max_expected = scaled_expected * 11 / 10 + 10;
 6eb:	89 55 c8             	mov    %edx,-0x38(%ebp)
 6ee:	6b ca 0b             	imul   $0xb,%edx,%ecx
 6f1:	bb 0b 00 00 00       	mov    $0xb,%ebx
 6f6:	89 d8                	mov    %ebx,%eax
 6f8:	89 75 cc             	mov    %esi,-0x34(%ebp)
 6fb:	f7 e6                	mul    %esi
 6fd:	89 c6                	mov    %eax,%esi
 6ff:	89 d7                	mov    %edx,%edi
 701:	01 cf                	add    %ecx,%edi
 703:	89 f8                	mov    %edi,%eax
 705:	c1 f8 1f             	sar    $0x1f,%eax
 708:	89 45 e0             	mov    %eax,-0x20(%ebp)
 70b:	83 e0 03             	and    $0x3,%eax
 70e:	89 f2                	mov    %esi,%edx
 710:	81 e2 ff ff ff 0f    	and    $0xfffffff,%edx
 716:	89 f1                	mov    %esi,%ecx
 718:	89 fb                	mov    %edi,%ebx
 71a:	0f ac d9 1c          	shrd   $0x1c,%ebx,%ecx
 71e:	c1 eb 1c             	shr    $0x1c,%ebx
 721:	81 e1 ff ff ff 0f    	and    $0xfffffff,%ecx
 727:	01 d1                	add    %edx,%ecx
 729:	89 fa                	mov    %edi,%edx
 72b:	c1 ea 18             	shr    $0x18,%edx
 72e:	01 d1                	add    %edx,%ecx
 730:	01 c1                	add    %eax,%ecx
 732:	b8 cd cc cc cc       	mov    $0xcccccccd,%eax
 737:	f7 e1                	mul    %ecx
 739:	89 d3                	mov    %edx,%ebx
 73b:	c1 eb 02             	shr    $0x2,%ebx
 73e:	81 e2 fc ff ff 7f    	and    $0x7ffffffc,%edx
 744:	01 da                	add    %ebx,%edx
 746:	29 d1                	sub    %edx,%ecx
 748:	8b 45 e0             	mov    -0x20(%ebp),%eax
 74b:	83 e0 fc             	and    $0xfffffffc,%eax
 74e:	01 c8                	add    %ecx,%eax
 750:	89 c1                	mov    %eax,%ecx
 752:	89 c3                	mov    %eax,%ebx
 754:	c1 fb 1f             	sar    $0x1f,%ebx
 757:	89 f0                	mov    %esi,%eax
 759:	89 fa                	mov    %edi,%edx
 75b:	29 c8                	sub    %ecx,%eax
 75d:	19 da                	sbb    %ebx,%edx
 75f:	69 ca cd cc cc cc    	imul   $0xcccccccd,%edx,%ecx
 765:	69 d0 cc cc cc cc    	imul   $0xcccccccc,%eax,%edx
 76b:	01 d1                	add    %edx,%ecx
 76d:	bb cd cc cc cc       	mov    $0xcccccccd,%ebx
 772:	f7 e3                	mul    %ebx
 774:	01 ca                	add    %ecx,%edx
 776:	89 d1                	mov    %edx,%ecx
 778:	c1 f9 1f             	sar    $0x1f,%ecx
 77b:	89 ce                	mov    %ecx,%esi
 77d:	89 cb                	mov    %ecx,%ebx
 77f:	c1 fb 1f             	sar    $0x1f,%ebx
 782:	31 c6                	xor    %eax,%esi
 784:	89 75 d8             	mov    %esi,-0x28(%ebp)
 787:	89 d9                	mov    %ebx,%ecx
 789:	31 d1                	xor    %edx,%ecx
 78b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
 78e:	89 d1                	mov    %edx,%ecx
 790:	c1 e9 1f             	shr    $0x1f,%ecx
 793:	bb 00 00 00 00       	mov    $0x0,%ebx
 798:	01 c1                	add    %eax,%ecx
 79a:	11 d3                	adc    %edx,%ebx
 79c:	0f ac d9 01          	shrd   $0x1,%ebx,%ecx
 7a0:	d1 fb                	sar    %ebx
 7a2:	8d 51 0a             	lea    0xa(%ecx),%edx
 7a5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
        int min_expected = scaled_expected * 9 / 10 - 10;
 7a8:	6b 4d c8 09          	imul   $0x9,-0x38(%ebp),%ecx
 7ac:	bf 09 00 00 00       	mov    $0x9,%edi
 7b1:	89 f8                	mov    %edi,%eax
 7b3:	f7 65 cc             	mull   -0x34(%ebp)
 7b6:	89 c6                	mov    %eax,%esi
 7b8:	89 d7                	mov    %edx,%edi
 7ba:	01 cf                	add    %ecx,%edi
 7bc:	89 f8                	mov    %edi,%eax
 7be:	c1 f8 1f             	sar    $0x1f,%eax
 7c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
 7c4:	83 e0 03             	and    $0x3,%eax
 7c7:	89 f2                	mov    %esi,%edx
 7c9:	81 e2 ff ff ff 0f    	and    $0xfffffff,%edx
 7cf:	89 f1                	mov    %esi,%ecx
 7d1:	89 fb                	mov    %edi,%ebx
 7d3:	0f ac d9 1c          	shrd   $0x1c,%ebx,%ecx
 7d7:	c1 eb 1c             	shr    $0x1c,%ebx
 7da:	81 e1 ff ff ff 0f    	and    $0xfffffff,%ecx
 7e0:	01 d1                	add    %edx,%ecx
 7e2:	89 fa                	mov    %edi,%edx
 7e4:	c1 ea 18             	shr    $0x18,%edx
 7e7:	01 d1                	add    %edx,%ecx
 7e9:	01 c1                	add    %eax,%ecx
 7eb:	b8 cd cc cc cc       	mov    $0xcccccccd,%eax
 7f0:	f7 e1                	mul    %ecx
 7f2:	89 d3                	mov    %edx,%ebx
 7f4:	c1 eb 02             	shr    $0x2,%ebx
 7f7:	81 e2 fc ff ff 7f    	and    $0x7ffffffc,%edx
 7fd:	01 da                	add    %ebx,%edx
 7ff:	29 d1                	sub    %edx,%ecx
 801:	8b 45 e0             	mov    -0x20(%ebp),%eax
 804:	83 e0 fc             	and    $0xfffffffc,%eax
 807:	01 c8                	add    %ecx,%eax
 809:	89 c1                	mov    %eax,%ecx
 80b:	89 c3                	mov    %eax,%ebx
 80d:	c1 fb 1f             	sar    $0x1f,%ebx
 810:	89 f0                	mov    %esi,%eax
 812:	89 fa                	mov    %edi,%edx
 814:	29 c8                	sub    %ecx,%eax
 816:	19 da                	sbb    %ebx,%edx
 818:	69 ca cd cc cc cc    	imul   $0xcccccccd,%edx,%ecx
 81e:	69 d0 cc cc cc cc    	imul   $0xcccccccc,%eax,%edx
 824:	01 d1                	add    %edx,%ecx
 826:	bb cd cc cc cc       	mov    $0xcccccccd,%ebx
 82b:	f7 e3                	mul    %ebx
 82d:	01 ca                	add    %ecx,%edx
 82f:	89 d6                	mov    %edx,%esi
 831:	c1 fe 1f             	sar    $0x1f,%esi
 834:	89 f3                	mov    %esi,%ebx
 836:	c1 fb 1f             	sar    $0x1f,%ebx
 839:	31 c6                	xor    %eax,%esi
 83b:	89 75 d0             	mov    %esi,-0x30(%ebp)
 83e:	89 df                	mov    %ebx,%edi
 840:	31 d7                	xor    %edx,%edi
 842:	89 7d d4             	mov    %edi,-0x2c(%ebp)
 845:	89 d1                	mov    %edx,%ecx
 847:	c1 e9 1f             	shr    $0x1f,%ecx
 84a:	bb 00 00 00 00       	mov    $0x0,%ebx
 84f:	01 c1                	add    %eax,%ecx
 851:	11 d3                	adc    %edx,%ebx
 853:	0f ac d9 01          	shrd   $0x1,%ebx,%ecx
 857:	d1 fb                	sar    %ebx
 859:	83 e9 0a             	sub    $0xa,%ecx
        int in_range = (test->actual_schedules[i] >= min_expected && test->actual_schedules[i] <= max_expected);
 85c:	8b 7d 08             	mov    0x8(%ebp),%edi
 85f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 862:	8b 84 87 10 01 00 00 	mov    0x110(%edi,%eax,4),%eax
 869:	39 c8                	cmp    %ecx,%eax
 86b:	0f 8c 20 fe ff ff    	jl     691 <compare_schedules_naive+0x4b>
 871:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
 874:	0f 8e 1e fe ff ff    	jle    698 <compare_schedules_naive+0x52>
            failed_any = 1;
 87a:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
 881:	e9 12 fe ff ff       	jmp    698 <compare_schedules_naive+0x52>
        }
    }
    check(test, !failed_any, "schedule counts within +/- 10% or +/- 10 of expected");
 886:	83 ec 04             	sub    $0x4,%esp
 889:	68 94 12 00 00       	push   $0x1294
 88e:	8b 7d b8             	mov    -0x48(%ebp),%edi
 891:	89 f8                	mov    %edi,%eax
 893:	83 f0 01             	xor    $0x1,%eax
 896:	50                   	push   %eax
 897:	ff 75 08             	push   0x8(%ebp)
 89a:	e8 db f8 ff ff       	call   17a <check>
    if (!failed_any) {
 89f:	83 c4 10             	add    $0x10,%esp
 8a2:	85 ff                	test   %edi,%edi
 8a4:	74 08                	je     8ae <compare_schedules_naive+0x268>
        printf(1, "*** %s failed chi-squared test, but was w/in 10% of expected\n", test->name);
        printf(1, "*** a likely cause is bias in random number generation\n");
    }
}
 8a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8a9:	5b                   	pop    %ebx
 8aa:	5e                   	pop    %esi
 8ab:	5f                   	pop    %edi
 8ac:	5d                   	pop    %ebp
 8ad:	c3                   	ret    
        printf(1, "*** %s failed chi-squared test, but was w/in 10% of expected\n", test->name);
 8ae:	83 ec 04             	sub    $0x4,%esp
 8b1:	8b 45 08             	mov    0x8(%ebp),%eax
 8b4:	ff 30                	push   (%eax)
 8b6:	68 cc 12 00 00       	push   $0x12cc
 8bb:	6a 01                	push   $0x1
 8bd:	e8 05 03 00 00       	call   bc7 <printf>
        printf(1, "*** a likely cause is bias in random number generation\n");
 8c2:	83 c4 08             	add    $0x8,%esp
 8c5:	68 0c 13 00 00       	push   $0x130c
 8ca:	6a 01                	push   $0x1
 8cc:	e8 f6 02 00 00       	call   bc7 <printf>
 8d1:	83 c4 10             	add    $0x10,%esp
 8d4:	eb d0                	jmp    8a6 <compare_schedules_naive+0x260>

000008d6 <run_test_case>:

void run_test_case(struct test_case* test) {
 8d6:	55                   	push   %ebp
 8d7:	89 e5                	mov    %esp,%ebp
 8d9:	53                   	push   %ebx
 8da:	81 ec 94 06 00 00    	sub    $0x694,%esp
 8e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int pids[MAX_CHILDREN];
    test->total_tests = test->errors = 0;
 8e3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
 8ea:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
    struct processes_info before, after;
    execute_and_get_info(test, pids, &before, &after);
 8f1:	8d 85 70 f9 ff ff    	lea    -0x690(%ebp),%eax
 8f7:	50                   	push   %eax
 8f8:	8d 85 74 fc ff ff    	lea    -0x38c(%ebp),%eax
 8fe:	50                   	push   %eax
 8ff:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
 905:	50                   	push   %eax
 906:	53                   	push   %ebx
 907:	e8 a7 f8 ff ff       	call   1b3 <execute_and_get_info>
    check(test, 
          before.num_processes < NPROC && after.num_processes < NPROC &&
 90c:	8b 85 74 fc ff ff    	mov    -0x38c(%ebp),%eax
    check(test, 
 912:	83 c4 10             	add    $0x10,%esp
 915:	83 f8 3f             	cmp    $0x3f,%eax
 918:	7f 29                	jg     943 <run_test_case+0x6d>
          before.num_processes < NPROC && after.num_processes < NPROC &&
 91a:	8b 95 70 f9 ff ff    	mov    -0x690(%ebp),%edx
 920:	83 fa 3f             	cmp    $0x3f,%edx
 923:	0f 8f 86 00 00 00    	jg     9af <run_test_case+0xd9>
          before.num_processes > test->num_children && after.num_processes > test->num_children,
 929:	8b 4b 0c             	mov    0xc(%ebx),%ecx
          before.num_processes < NPROC && after.num_processes < NPROC &&
 92c:	39 c8                	cmp    %ecx,%eax
 92e:	0f 8e 82 00 00 00    	jle    9b6 <run_test_case+0xe0>
    check(test, 
 934:	39 ca                	cmp    %ecx,%edx
 936:	0f 8f 81 00 00 00    	jg     9bd <run_test_case+0xe7>
 93c:	b8 00 00 00 00       	mov    $0x0,%eax
 941:	eb 05                	jmp    948 <run_test_case+0x72>
 943:	b8 00 00 00 00       	mov    $0x0,%eax
 948:	83 ec 04             	sub    $0x4,%esp
 94b:	68 44 13 00 00       	push   $0x1344
 950:	50                   	push   %eax
 951:	53                   	push   %ebx
 952:	e8 23 f8 ff ff       	call   17a <check>
          "getprocessesinfo returned a reasonable number of processes");
    count_schedules(test, pids, &before, &after);
 957:	8d 85 70 f9 ff ff    	lea    -0x690(%ebp),%eax
 95d:	50                   	push   %eax
 95e:	8d 85 74 fc ff ff    	lea    -0x38c(%ebp),%eax
 964:	50                   	push   %eax
 965:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
 96b:	50                   	push   %eax
 96c:	53                   	push   %ebx
 96d:	e8 18 f9 ff ff       	call   28a <count_schedules>
    if (!compare_schedules_chi_squared(test)) {
 972:	83 c4 14             	add    $0x14,%esp
 975:	53                   	push   %ebx
 976:	e8 01 fb ff ff       	call   47c <compare_schedules_chi_squared>
 97b:	83 c4 10             	add    $0x10,%esp
 97e:	85 c0                	test   %eax,%eax
 980:	75 42                	jne    9c4 <run_test_case+0xee>
        compare_schedules_naive(test);
 982:	83 ec 0c             	sub    $0xc,%esp
 985:	53                   	push   %ebx
 986:	e8 bb fc ff ff       	call   646 <compare_schedules_naive>
 98b:	83 c4 10             	add    $0x10,%esp
    } else {
        check(test, 1, "assuming schedule counts approximately right given chi-squared test");
    }
    printf(1, "%s: passed %d of %d\n", test->name, test->total_tests - test->errors, test->total_tests);
 98e:	8b 43 04             	mov    0x4(%ebx),%eax
 991:	83 ec 0c             	sub    $0xc,%esp
 994:	50                   	push   %eax
 995:	2b 43 08             	sub    0x8(%ebx),%eax
 998:	50                   	push   %eax
 999:	ff 33                	push   (%ebx)
 99b:	68 cc 0e 00 00       	push   $0xecc
 9a0:	6a 01                	push   $0x1
 9a2:	e8 20 02 00 00       	call   bc7 <printf>
}
 9a7:	83 c4 20             	add    $0x20,%esp
 9aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 9ad:	c9                   	leave  
 9ae:	c3                   	ret    
    check(test, 
 9af:	b8 00 00 00 00       	mov    $0x0,%eax
 9b4:	eb 92                	jmp    948 <run_test_case+0x72>
 9b6:	b8 00 00 00 00       	mov    $0x0,%eax
 9bb:	eb 8b                	jmp    948 <run_test_case+0x72>
 9bd:	b8 01 00 00 00       	mov    $0x1,%eax
 9c2:	eb 84                	jmp    948 <run_test_case+0x72>
        check(test, 1, "assuming schedule counts approximately right given chi-squared test");
 9c4:	83 ec 04             	sub    $0x4,%esp
 9c7:	68 80 13 00 00       	push   $0x1380
 9cc:	6a 01                	push   $0x1
 9ce:	53                   	push   %ebx
 9cf:	e8 a6 f7 ff ff       	call   17a <check>
 9d4:	83 c4 10             	add    $0x10,%esp
 9d7:	eb b5                	jmp    98e <run_test_case+0xb8>

000009d9 <main>:

int main(int argc, char *argv[])
{
 9d9:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 9dd:	83 e4 f0             	and    $0xfffffff0,%esp
 9e0:	ff 71 fc             	push   -0x4(%ecx)
 9e3:	55                   	push   %ebp
 9e4:	89 e5                	mov    %esp,%ebp
 9e6:	57                   	push   %edi
 9e7:	56                   	push   %esi
 9e8:	53                   	push   %ebx
 9e9:	51                   	push   %ecx
 9ea:	83 ec 18             	sub    $0x18,%esp
    int total_tests = 0;
    int passed_tests = 0;
    for (int i = 0; tests[i].name; ++i) {
 9ed:	be 00 00 00 00       	mov    $0x0,%esi
    int passed_tests = 0;
 9f2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    int total_tests = 0;
 9f9:	bf 00 00 00 00       	mov    $0x0,%edi
    for (int i = 0; tests[i].name; ++i) {
 9fe:	eb 26                	jmp    a26 <main+0x4d>
        struct test_case *test = &tests[i];
 a00:	69 de 18 02 00 00    	imul   $0x218,%esi,%ebx
 a06:	81 c3 e0 15 00 00    	add    $0x15e0,%ebx
        run_test_case(test);
 a0c:	83 ec 0c             	sub    $0xc,%esp
 a0f:	53                   	push   %ebx
 a10:	e8 c1 fe ff ff       	call   8d6 <run_test_case>
        total_tests += test->total_tests;
 a15:	8b 43 04             	mov    0x4(%ebx),%eax
 a18:	01 c7                	add    %eax,%edi
        passed_tests += test->total_tests - test->errors;
 a1a:	2b 43 08             	sub    0x8(%ebx),%eax
 a1d:	01 45 e4             	add    %eax,-0x1c(%ebp)
    for (int i = 0; tests[i].name; ++i) {
 a20:	83 c6 01             	add    $0x1,%esi
 a23:	83 c4 10             	add    $0x10,%esp
 a26:	69 c6 18 02 00 00    	imul   $0x218,%esi,%eax
 a2c:	83 b8 e0 15 00 00 00 	cmpl   $0x0,0x15e0(%eax)
 a33:	75 cb                	jne    a00 <main+0x27>
    }
    printf(1, "overall: passed %d of %d tests attempted\n", passed_tests, total_tests);
 a35:	57                   	push   %edi
 a36:	ff 75 e4             	push   -0x1c(%ebp)
 a39:	68 c4 13 00 00       	push   $0x13c4
 a3e:	6a 01                	push   $0x1
 a40:	e8 82 01 00 00       	call   bc7 <printf>
    exit();
 a45:	e8 08 00 00 00       	call   a52 <exit>

00000a4a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 a4a:	b8 01 00 00 00       	mov    $0x1,%eax
 a4f:	cd 40                	int    $0x40
 a51:	c3                   	ret    

00000a52 <exit>:
SYSCALL(exit)
 a52:	b8 02 00 00 00       	mov    $0x2,%eax
 a57:	cd 40                	int    $0x40
 a59:	c3                   	ret    

00000a5a <wait>:
SYSCALL(wait)
 a5a:	b8 03 00 00 00       	mov    $0x3,%eax
 a5f:	cd 40                	int    $0x40
 a61:	c3                   	ret    

00000a62 <pipe>:
SYSCALL(pipe)
 a62:	b8 04 00 00 00       	mov    $0x4,%eax
 a67:	cd 40                	int    $0x40
 a69:	c3                   	ret    

00000a6a <read>:
SYSCALL(read)
 a6a:	b8 05 00 00 00       	mov    $0x5,%eax
 a6f:	cd 40                	int    $0x40
 a71:	c3                   	ret    

00000a72 <write>:
SYSCALL(write)
 a72:	b8 10 00 00 00       	mov    $0x10,%eax
 a77:	cd 40                	int    $0x40
 a79:	c3                   	ret    

00000a7a <close>:
SYSCALL(close)
 a7a:	b8 15 00 00 00       	mov    $0x15,%eax
 a7f:	cd 40                	int    $0x40
 a81:	c3                   	ret    

00000a82 <kill>:
SYSCALL(kill)
 a82:	b8 06 00 00 00       	mov    $0x6,%eax
 a87:	cd 40                	int    $0x40
 a89:	c3                   	ret    

00000a8a <exec>:
SYSCALL(exec)
 a8a:	b8 07 00 00 00       	mov    $0x7,%eax
 a8f:	cd 40                	int    $0x40
 a91:	c3                   	ret    

00000a92 <open>:
SYSCALL(open)
 a92:	b8 0f 00 00 00       	mov    $0xf,%eax
 a97:	cd 40                	int    $0x40
 a99:	c3                   	ret    

00000a9a <mknod>:
SYSCALL(mknod)
 a9a:	b8 11 00 00 00       	mov    $0x11,%eax
 a9f:	cd 40                	int    $0x40
 aa1:	c3                   	ret    

00000aa2 <unlink>:
SYSCALL(unlink)
 aa2:	b8 12 00 00 00       	mov    $0x12,%eax
 aa7:	cd 40                	int    $0x40
 aa9:	c3                   	ret    

00000aaa <fstat>:
SYSCALL(fstat)
 aaa:	b8 08 00 00 00       	mov    $0x8,%eax
 aaf:	cd 40                	int    $0x40
 ab1:	c3                   	ret    

00000ab2 <link>:
SYSCALL(link)
 ab2:	b8 13 00 00 00       	mov    $0x13,%eax
 ab7:	cd 40                	int    $0x40
 ab9:	c3                   	ret    

00000aba <mkdir>:
SYSCALL(mkdir)
 aba:	b8 14 00 00 00       	mov    $0x14,%eax
 abf:	cd 40                	int    $0x40
 ac1:	c3                   	ret    

00000ac2 <chdir>:
SYSCALL(chdir)
 ac2:	b8 09 00 00 00       	mov    $0x9,%eax
 ac7:	cd 40                	int    $0x40
 ac9:	c3                   	ret    

00000aca <dup>:
SYSCALL(dup)
 aca:	b8 0a 00 00 00       	mov    $0xa,%eax
 acf:	cd 40                	int    $0x40
 ad1:	c3                   	ret    

00000ad2 <getpid>:
SYSCALL(getpid)
 ad2:	b8 0b 00 00 00       	mov    $0xb,%eax
 ad7:	cd 40                	int    $0x40
 ad9:	c3                   	ret    

00000ada <sbrk>:
SYSCALL(sbrk)
 ada:	b8 0c 00 00 00       	mov    $0xc,%eax
 adf:	cd 40                	int    $0x40
 ae1:	c3                   	ret    

00000ae2 <sleep>:
SYSCALL(sleep)
 ae2:	b8 0d 00 00 00       	mov    $0xd,%eax
 ae7:	cd 40                	int    $0x40
 ae9:	c3                   	ret    

00000aea <uptime>:
SYSCALL(uptime)
 aea:	b8 0e 00 00 00       	mov    $0xe,%eax
 aef:	cd 40                	int    $0x40
 af1:	c3                   	ret    

00000af2 <yield>:
SYSCALL(yield)
 af2:	b8 16 00 00 00       	mov    $0x16,%eax
 af7:	cd 40                	int    $0x40
 af9:	c3                   	ret    

00000afa <shutdown>:
SYSCALL(shutdown)
 afa:	b8 17 00 00 00       	mov    $0x17,%eax
 aff:	cd 40                	int    $0x40
 b01:	c3                   	ret    

00000b02 <writecount>:
SYSCALL(writecount)
 b02:	b8 18 00 00 00       	mov    $0x18,%eax
 b07:	cd 40                	int    $0x40
 b09:	c3                   	ret    

00000b0a <setwritecount>:
SYSCALL(setwritecount)
 b0a:	b8 19 00 00 00       	mov    $0x19,%eax
 b0f:	cd 40                	int    $0x40
 b11:	c3                   	ret    

00000b12 <settickets>:
SYSCALL(settickets)
 b12:	b8 1a 00 00 00       	mov    $0x1a,%eax
 b17:	cd 40                	int    $0x40
 b19:	c3                   	ret    

00000b1a <getprocessesinfo>:
 b1a:	b8 1b 00 00 00       	mov    $0x1b,%eax
 b1f:	cd 40                	int    $0x40
 b21:	c3                   	ret    

00000b22 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 b22:	55                   	push   %ebp
 b23:	89 e5                	mov    %esp,%ebp
 b25:	83 ec 1c             	sub    $0x1c,%esp
 b28:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 b2b:	6a 01                	push   $0x1
 b2d:	8d 55 f4             	lea    -0xc(%ebp),%edx
 b30:	52                   	push   %edx
 b31:	50                   	push   %eax
 b32:	e8 3b ff ff ff       	call   a72 <write>
}
 b37:	83 c4 10             	add    $0x10,%esp
 b3a:	c9                   	leave  
 b3b:	c3                   	ret    

00000b3c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b3c:	55                   	push   %ebp
 b3d:	89 e5                	mov    %esp,%ebp
 b3f:	57                   	push   %edi
 b40:	56                   	push   %esi
 b41:	53                   	push   %ebx
 b42:	83 ec 2c             	sub    $0x2c,%esp
 b45:	89 45 d0             	mov    %eax,-0x30(%ebp)
 b48:	89 d0                	mov    %edx,%eax
 b4a:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b4c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 b50:	0f 95 c1             	setne  %cl
 b53:	c1 ea 1f             	shr    $0x1f,%edx
 b56:	84 d1                	test   %dl,%cl
 b58:	74 44                	je     b9e <printint+0x62>
    neg = 1;
    x = -xx;
 b5a:	f7 d8                	neg    %eax
 b5c:	89 c1                	mov    %eax,%ecx
    neg = 1;
 b5e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 b65:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 b6a:	89 c8                	mov    %ecx,%eax
 b6c:	ba 00 00 00 00       	mov    $0x0,%edx
 b71:	f7 f6                	div    %esi
 b73:	89 df                	mov    %ebx,%edi
 b75:	83 c3 01             	add    $0x1,%ebx
 b78:	0f b6 92 b0 15 00 00 	movzbl 0x15b0(%edx),%edx
 b7f:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 b83:	89 ca                	mov    %ecx,%edx
 b85:	89 c1                	mov    %eax,%ecx
 b87:	39 d6                	cmp    %edx,%esi
 b89:	76 df                	jbe    b6a <printint+0x2e>
  if(neg)
 b8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 b8f:	74 31                	je     bc2 <printint+0x86>
    buf[i++] = '-';
 b91:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 b96:	8d 5f 02             	lea    0x2(%edi),%ebx
 b99:	8b 75 d0             	mov    -0x30(%ebp),%esi
 b9c:	eb 17                	jmp    bb5 <printint+0x79>
    x = xx;
 b9e:	89 c1                	mov    %eax,%ecx
  neg = 0;
 ba0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 ba7:	eb bc                	jmp    b65 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 ba9:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 bae:	89 f0                	mov    %esi,%eax
 bb0:	e8 6d ff ff ff       	call   b22 <putc>
  while(--i >= 0)
 bb5:	83 eb 01             	sub    $0x1,%ebx
 bb8:	79 ef                	jns    ba9 <printint+0x6d>
}
 bba:	83 c4 2c             	add    $0x2c,%esp
 bbd:	5b                   	pop    %ebx
 bbe:	5e                   	pop    %esi
 bbf:	5f                   	pop    %edi
 bc0:	5d                   	pop    %ebp
 bc1:	c3                   	ret    
 bc2:	8b 75 d0             	mov    -0x30(%ebp),%esi
 bc5:	eb ee                	jmp    bb5 <printint+0x79>

00000bc7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 bc7:	55                   	push   %ebp
 bc8:	89 e5                	mov    %esp,%ebp
 bca:	57                   	push   %edi
 bcb:	56                   	push   %esi
 bcc:	53                   	push   %ebx
 bcd:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 bd0:	8d 45 10             	lea    0x10(%ebp),%eax
 bd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 bd6:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 bdb:	bb 00 00 00 00       	mov    $0x0,%ebx
 be0:	eb 14                	jmp    bf6 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 be2:	89 fa                	mov    %edi,%edx
 be4:	8b 45 08             	mov    0x8(%ebp),%eax
 be7:	e8 36 ff ff ff       	call   b22 <putc>
 bec:	eb 05                	jmp    bf3 <printf+0x2c>
      }
    } else if(state == '%'){
 bee:	83 fe 25             	cmp    $0x25,%esi
 bf1:	74 25                	je     c18 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 bf3:	83 c3 01             	add    $0x1,%ebx
 bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
 bf9:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 bfd:	84 c0                	test   %al,%al
 bff:	0f 84 20 01 00 00    	je     d25 <printf+0x15e>
    c = fmt[i] & 0xff;
 c05:	0f be f8             	movsbl %al,%edi
 c08:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 c0b:	85 f6                	test   %esi,%esi
 c0d:	75 df                	jne    bee <printf+0x27>
      if(c == '%'){
 c0f:	83 f8 25             	cmp    $0x25,%eax
 c12:	75 ce                	jne    be2 <printf+0x1b>
        state = '%';
 c14:	89 c6                	mov    %eax,%esi
 c16:	eb db                	jmp    bf3 <printf+0x2c>
      if(c == 'd'){
 c18:	83 f8 25             	cmp    $0x25,%eax
 c1b:	0f 84 cf 00 00 00    	je     cf0 <printf+0x129>
 c21:	0f 8c dd 00 00 00    	jl     d04 <printf+0x13d>
 c27:	83 f8 78             	cmp    $0x78,%eax
 c2a:	0f 8f d4 00 00 00    	jg     d04 <printf+0x13d>
 c30:	83 f8 63             	cmp    $0x63,%eax
 c33:	0f 8c cb 00 00 00    	jl     d04 <printf+0x13d>
 c39:	83 e8 63             	sub    $0x63,%eax
 c3c:	83 f8 15             	cmp    $0x15,%eax
 c3f:	0f 87 bf 00 00 00    	ja     d04 <printf+0x13d>
 c45:	ff 24 85 58 15 00 00 	jmp    *0x1558(,%eax,4)
        printint(fd, *ap, 10, 1);
 c4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 c4f:	8b 17                	mov    (%edi),%edx
 c51:	83 ec 0c             	sub    $0xc,%esp
 c54:	6a 01                	push   $0x1
 c56:	b9 0a 00 00 00       	mov    $0xa,%ecx
 c5b:	8b 45 08             	mov    0x8(%ebp),%eax
 c5e:	e8 d9 fe ff ff       	call   b3c <printint>
        ap++;
 c63:	83 c7 04             	add    $0x4,%edi
 c66:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 c69:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 c6c:	be 00 00 00 00       	mov    $0x0,%esi
 c71:	eb 80                	jmp    bf3 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 c73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 c76:	8b 17                	mov    (%edi),%edx
 c78:	83 ec 0c             	sub    $0xc,%esp
 c7b:	6a 00                	push   $0x0
 c7d:	b9 10 00 00 00       	mov    $0x10,%ecx
 c82:	8b 45 08             	mov    0x8(%ebp),%eax
 c85:	e8 b2 fe ff ff       	call   b3c <printint>
        ap++;
 c8a:	83 c7 04             	add    $0x4,%edi
 c8d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 c90:	83 c4 10             	add    $0x10,%esp
      state = 0;
 c93:	be 00 00 00 00       	mov    $0x0,%esi
 c98:	e9 56 ff ff ff       	jmp    bf3 <printf+0x2c>
        s = (char*)*ap;
 c9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 ca0:	8b 30                	mov    (%eax),%esi
        ap++;
 ca2:	83 c0 04             	add    $0x4,%eax
 ca5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 ca8:	85 f6                	test   %esi,%esi
 caa:	75 15                	jne    cc1 <printf+0xfa>
          s = "(null)";
 cac:	be 50 15 00 00       	mov    $0x1550,%esi
 cb1:	eb 0e                	jmp    cc1 <printf+0xfa>
          putc(fd, *s);
 cb3:	0f be d2             	movsbl %dl,%edx
 cb6:	8b 45 08             	mov    0x8(%ebp),%eax
 cb9:	e8 64 fe ff ff       	call   b22 <putc>
          s++;
 cbe:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 cc1:	0f b6 16             	movzbl (%esi),%edx
 cc4:	84 d2                	test   %dl,%dl
 cc6:	75 eb                	jne    cb3 <printf+0xec>
      state = 0;
 cc8:	be 00 00 00 00       	mov    $0x0,%esi
 ccd:	e9 21 ff ff ff       	jmp    bf3 <printf+0x2c>
        putc(fd, *ap);
 cd2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 cd5:	0f be 17             	movsbl (%edi),%edx
 cd8:	8b 45 08             	mov    0x8(%ebp),%eax
 cdb:	e8 42 fe ff ff       	call   b22 <putc>
        ap++;
 ce0:	83 c7 04             	add    $0x4,%edi
 ce3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 ce6:	be 00 00 00 00       	mov    $0x0,%esi
 ceb:	e9 03 ff ff ff       	jmp    bf3 <printf+0x2c>
        putc(fd, c);
 cf0:	89 fa                	mov    %edi,%edx
 cf2:	8b 45 08             	mov    0x8(%ebp),%eax
 cf5:	e8 28 fe ff ff       	call   b22 <putc>
      state = 0;
 cfa:	be 00 00 00 00       	mov    $0x0,%esi
 cff:	e9 ef fe ff ff       	jmp    bf3 <printf+0x2c>
        putc(fd, '%');
 d04:	ba 25 00 00 00       	mov    $0x25,%edx
 d09:	8b 45 08             	mov    0x8(%ebp),%eax
 d0c:	e8 11 fe ff ff       	call   b22 <putc>
        putc(fd, c);
 d11:	89 fa                	mov    %edi,%edx
 d13:	8b 45 08             	mov    0x8(%ebp),%eax
 d16:	e8 07 fe ff ff       	call   b22 <putc>
      state = 0;
 d1b:	be 00 00 00 00       	mov    $0x0,%esi
 d20:	e9 ce fe ff ff       	jmp    bf3 <printf+0x2c>
    }
  }
}
 d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
 d28:	5b                   	pop    %ebx
 d29:	5e                   	pop    %esi
 d2a:	5f                   	pop    %edi
 d2b:	5d                   	pop    %ebp
 d2c:	c3                   	ret    
 d2d:	66 90                	xchg   %ax,%ax
 d2f:	90                   	nop

00000d30 <__divdi3>:
 d30:	f3 0f 1e fb          	endbr32 
 d34:	55                   	push   %ebp
 d35:	57                   	push   %edi
 d36:	56                   	push   %esi
 d37:	53                   	push   %ebx
 d38:	83 ec 1c             	sub    $0x1c,%esp
 d3b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
 d3f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
 d43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
 d4a:	00 
 d4b:	8b 44 24 38          	mov    0x38(%esp),%eax
 d4f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
 d53:	89 0c 24             	mov    %ecx,(%esp)
 d56:	89 dd                	mov    %ebx,%ebp
 d58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 d5c:	85 db                	test   %ebx,%ebx
 d5e:	79 18                	jns    d78 <__divdi3+0x48>
 d60:	f7 d9                	neg    %ecx
 d62:	c7 44 24 08 ff ff ff 	movl   $0xffffffff,0x8(%esp)
 d69:	ff 
 d6a:	83 d3 00             	adc    $0x0,%ebx
 d6d:	89 0c 24             	mov    %ecx,(%esp)
 d70:	f7 db                	neg    %ebx
 d72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 d76:	89 dd                	mov    %ebx,%ebp
 d78:	89 d3                	mov    %edx,%ebx
 d7a:	85 d2                	test   %edx,%edx
 d7c:	79 0d                	jns    d8b <__divdi3+0x5b>
 d7e:	f7 d8                	neg    %eax
 d80:	f7 54 24 08          	notl   0x8(%esp)
 d84:	83 d2 00             	adc    $0x0,%edx
 d87:	f7 da                	neg    %edx
 d89:	89 d3                	mov    %edx,%ebx
 d8b:	89 c7                	mov    %eax,%edi
 d8d:	8b 04 24             	mov    (%esp),%eax
 d90:	85 db                	test   %ebx,%ebx
 d92:	75 14                	jne    da8 <__divdi3+0x78>
 d94:	39 ef                	cmp    %ebp,%edi
 d96:	76 58                	jbe    df0 <__divdi3+0xc0>
 d98:	89 ea                	mov    %ebp,%edx
 d9a:	31 f6                	xor    %esi,%esi
 d9c:	f7 f7                	div    %edi
 d9e:	89 c5                	mov    %eax,%ebp
 da0:	eb 0e                	jmp    db0 <__divdi3+0x80>
 da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 da8:	39 eb                	cmp    %ebp,%ebx
 daa:	76 24                	jbe    dd0 <__divdi3+0xa0>
 dac:	31 f6                	xor    %esi,%esi
 dae:	31 ed                	xor    %ebp,%ebp
 db0:	8b 4c 24 08          	mov    0x8(%esp),%ecx
 db4:	89 e8                	mov    %ebp,%eax
 db6:	89 f2                	mov    %esi,%edx
 db8:	85 c9                	test   %ecx,%ecx
 dba:	74 07                	je     dc3 <__divdi3+0x93>
 dbc:	f7 d8                	neg    %eax
 dbe:	83 d2 00             	adc    $0x0,%edx
 dc1:	f7 da                	neg    %edx
 dc3:	83 c4 1c             	add    $0x1c,%esp
 dc6:	5b                   	pop    %ebx
 dc7:	5e                   	pop    %esi
 dc8:	5f                   	pop    %edi
 dc9:	5d                   	pop    %ebp
 dca:	c3                   	ret    
 dcb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 dcf:	90                   	nop
 dd0:	0f bd f3             	bsr    %ebx,%esi
 dd3:	83 f6 1f             	xor    $0x1f,%esi
 dd6:	75 38                	jne    e10 <__divdi3+0xe0>
 dd8:	39 eb                	cmp    %ebp,%ebx
 dda:	72 07                	jb     de3 <__divdi3+0xb3>
 ddc:	31 ed                	xor    %ebp,%ebp
 dde:	3b 3c 24             	cmp    (%esp),%edi
 de1:	77 cd                	ja     db0 <__divdi3+0x80>
 de3:	bd 01 00 00 00       	mov    $0x1,%ebp
 de8:	eb c6                	jmp    db0 <__divdi3+0x80>
 dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 df0:	85 ff                	test   %edi,%edi
 df2:	75 0b                	jne    dff <__divdi3+0xcf>
 df4:	b8 01 00 00 00       	mov    $0x1,%eax
 df9:	31 d2                	xor    %edx,%edx
 dfb:	f7 f3                	div    %ebx
 dfd:	89 c7                	mov    %eax,%edi
 dff:	89 e8                	mov    %ebp,%eax
 e01:	31 d2                	xor    %edx,%edx
 e03:	f7 f7                	div    %edi
 e05:	89 c6                	mov    %eax,%esi
 e07:	8b 04 24             	mov    (%esp),%eax
 e0a:	f7 f7                	div    %edi
 e0c:	89 c5                	mov    %eax,%ebp
 e0e:	eb a0                	jmp    db0 <__divdi3+0x80>
 e10:	b8 20 00 00 00       	mov    $0x20,%eax
 e15:	89 f1                	mov    %esi,%ecx
 e17:	89 fa                	mov    %edi,%edx
 e19:	29 f0                	sub    %esi,%eax
 e1b:	d3 e3                	shl    %cl,%ebx
 e1d:	89 c1                	mov    %eax,%ecx
 e1f:	d3 ea                	shr    %cl,%edx
 e21:	89 f1                	mov    %esi,%ecx
 e23:	09 da                	or     %ebx,%edx
 e25:	d3 e7                	shl    %cl,%edi
 e27:	89 eb                	mov    %ebp,%ebx
 e29:	89 c1                	mov    %eax,%ecx
 e2b:	d3 eb                	shr    %cl,%ebx
 e2d:	89 54 24 0c          	mov    %edx,0xc(%esp)
 e31:	89 f1                	mov    %esi,%ecx
 e33:	8b 14 24             	mov    (%esp),%edx
 e36:	d3 e5                	shl    %cl,%ebp
 e38:	89 c1                	mov    %eax,%ecx
 e3a:	d3 ea                	shr    %cl,%edx
 e3c:	09 d5                	or     %edx,%ebp
 e3e:	89 da                	mov    %ebx,%edx
 e40:	89 e8                	mov    %ebp,%eax
 e42:	f7 74 24 0c          	divl   0xc(%esp)
 e46:	89 d3                	mov    %edx,%ebx
 e48:	89 c5                	mov    %eax,%ebp
 e4a:	f7 e7                	mul    %edi
 e4c:	39 d3                	cmp    %edx,%ebx
 e4e:	72 0f                	jb     e5f <__divdi3+0x12f>
 e50:	8b 3c 24             	mov    (%esp),%edi
 e53:	89 f1                	mov    %esi,%ecx
 e55:	d3 e7                	shl    %cl,%edi
 e57:	39 c7                	cmp    %eax,%edi
 e59:	73 07                	jae    e62 <__divdi3+0x132>
 e5b:	39 d3                	cmp    %edx,%ebx
 e5d:	75 03                	jne    e62 <__divdi3+0x132>
 e5f:	83 ed 01             	sub    $0x1,%ebp
 e62:	31 f6                	xor    %esi,%esi
 e64:	e9 47 ff ff ff       	jmp    db0 <__divdi3+0x80>
