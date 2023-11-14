
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <iputtest>:
int stdout = 1;

// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(void)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "iput test\n");
       6:	c7 44 24 04 38 3e 00 	movl   $0x3e38,0x4(%esp)
       d:	00 
       e:	a1 b4 55 00 00       	mov    0x55b4,%eax
      13:	89 04 24             	mov    %eax,(%esp)
      16:	e8 db 3a 00 00       	call   3af6 <printf>

  if(mkdir("iputdir") < 0){
      1b:	c7 04 24 cb 3d 00 00 	movl   $0x3dcb,(%esp)
      22:	e8 ca 39 00 00       	call   39f1 <mkdir>
      27:	85 c0                	test   %eax,%eax
      29:	79 1a                	jns    45 <iputtest+0x45>
    printf(stdout, "mkdir failed\n");
      2b:	c7 44 24 04 a4 3d 00 	movl   $0x3da4,0x4(%esp)
      32:	00 
      33:	a1 b4 55 00 00       	mov    0x55b4,%eax
      38:	89 04 24             	mov    %eax,(%esp)
      3b:	e8 b6 3a 00 00       	call   3af6 <printf>
    exit();
      40:	e8 44 39 00 00       	call   3989 <exit>
  }
  if(chdir("iputdir") < 0){
      45:	c7 04 24 cb 3d 00 00 	movl   $0x3dcb,(%esp)
      4c:	e8 a8 39 00 00       	call   39f9 <chdir>
      51:	85 c0                	test   %eax,%eax
      53:	79 1a                	jns    6f <iputtest+0x6f>
    printf(stdout, "chdir iputdir failed\n");
      55:	c7 44 24 04 b2 3d 00 	movl   $0x3db2,0x4(%esp)
      5c:	00 
      5d:	a1 b4 55 00 00       	mov    0x55b4,%eax
      62:	89 04 24             	mov    %eax,(%esp)
      65:	e8 8c 3a 00 00       	call   3af6 <printf>
    exit();
      6a:	e8 1a 39 00 00       	call   3989 <exit>
  }
  if(unlink("../iputdir") < 0){
      6f:	c7 04 24 c8 3d 00 00 	movl   $0x3dc8,(%esp)
      76:	e8 5e 39 00 00       	call   39d9 <unlink>
      7b:	85 c0                	test   %eax,%eax
      7d:	79 1a                	jns    99 <iputtest+0x99>
    printf(stdout, "unlink ../iputdir failed\n");
      7f:	c7 44 24 04 d3 3d 00 	movl   $0x3dd3,0x4(%esp)
      86:	00 
      87:	a1 b4 55 00 00       	mov    0x55b4,%eax
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 62 3a 00 00       	call   3af6 <printf>
    exit();
      94:	e8 f0 38 00 00       	call   3989 <exit>
  }
  if(chdir("/") < 0){
      99:	c7 04 24 ed 3d 00 00 	movl   $0x3ded,(%esp)
      a0:	e8 54 39 00 00       	call   39f9 <chdir>
      a5:	85 c0                	test   %eax,%eax
      a7:	79 1a                	jns    c3 <iputtest+0xc3>
    printf(stdout, "chdir / failed\n");
      a9:	c7 44 24 04 ef 3d 00 	movl   $0x3def,0x4(%esp)
      b0:	00 
      b1:	a1 b4 55 00 00       	mov    0x55b4,%eax
      b6:	89 04 24             	mov    %eax,(%esp)
      b9:	e8 38 3a 00 00       	call   3af6 <printf>
    exit();
      be:	e8 c6 38 00 00       	call   3989 <exit>
  }
  printf(stdout, "iput test ok\n");
      c3:	c7 44 24 04 70 3e 00 	movl   $0x3e70,0x4(%esp)
      ca:	00 
      cb:	a1 b4 55 00 00       	mov    0x55b4,%eax
      d0:	89 04 24             	mov    %eax,(%esp)
      d3:	e8 1e 3a 00 00       	call   3af6 <printf>
}
      d8:	c9                   	leave  
      d9:	c3                   	ret    

000000da <exitiputtest>:

// does exit() call iput(p->cwd) in a transaction?
void
exitiputtest(void)
{
      da:	55                   	push   %ebp
      db:	89 e5                	mov    %esp,%ebp
      dd:	83 ec 18             	sub    $0x18,%esp
  int pid;

  printf(stdout, "exitiput test\n");
      e0:	c7 44 24 04 ff 3d 00 	movl   $0x3dff,0x4(%esp)
      e7:	00 
      e8:	a1 b4 55 00 00       	mov    0x55b4,%eax
      ed:	89 04 24             	mov    %eax,(%esp)
      f0:	e8 01 3a 00 00       	call   3af6 <printf>

  pid = fork();
      f5:	e8 87 38 00 00       	call   3981 <fork>
  if(pid < 0){
      fa:	85 c0                	test   %eax,%eax
      fc:	79 1a                	jns    118 <exitiputtest+0x3e>
    printf(stdout, "fork failed\n");
      fe:	c7 44 24 04 e5 4c 00 	movl   $0x4ce5,0x4(%esp)
     105:	00 
     106:	a1 b4 55 00 00       	mov    0x55b4,%eax
     10b:	89 04 24             	mov    %eax,(%esp)
     10e:	e8 e3 39 00 00       	call   3af6 <printf>
    exit();
     113:	e8 71 38 00 00       	call   3989 <exit>
  }
  if(pid == 0){
     118:	85 c0                	test   %eax,%eax
     11a:	0f 85 83 00 00 00    	jne    1a3 <exitiputtest+0xc9>
    if(mkdir("iputdir") < 0){
     120:	c7 04 24 cb 3d 00 00 	movl   $0x3dcb,(%esp)
     127:	e8 c5 38 00 00       	call   39f1 <mkdir>
     12c:	85 c0                	test   %eax,%eax
     12e:	79 1a                	jns    14a <exitiputtest+0x70>
      printf(stdout, "mkdir failed\n");
     130:	c7 44 24 04 a4 3d 00 	movl   $0x3da4,0x4(%esp)
     137:	00 
     138:	a1 b4 55 00 00       	mov    0x55b4,%eax
     13d:	89 04 24             	mov    %eax,(%esp)
     140:	e8 b1 39 00 00       	call   3af6 <printf>
      exit();
     145:	e8 3f 38 00 00       	call   3989 <exit>
    }
    if(chdir("iputdir") < 0){
     14a:	c7 04 24 cb 3d 00 00 	movl   $0x3dcb,(%esp)
     151:	e8 a3 38 00 00       	call   39f9 <chdir>
     156:	85 c0                	test   %eax,%eax
     158:	79 1a                	jns    174 <exitiputtest+0x9a>
      printf(stdout, "child chdir failed\n");
     15a:	c7 44 24 04 0e 3e 00 	movl   $0x3e0e,0x4(%esp)
     161:	00 
     162:	a1 b4 55 00 00       	mov    0x55b4,%eax
     167:	89 04 24             	mov    %eax,(%esp)
     16a:	e8 87 39 00 00       	call   3af6 <printf>
      exit();
     16f:	e8 15 38 00 00       	call   3989 <exit>
    }
    if(unlink("../iputdir") < 0){
     174:	c7 04 24 c8 3d 00 00 	movl   $0x3dc8,(%esp)
     17b:	e8 59 38 00 00       	call   39d9 <unlink>
     180:	85 c0                	test   %eax,%eax
     182:	79 1a                	jns    19e <exitiputtest+0xc4>
      printf(stdout, "unlink ../iputdir failed\n");
     184:	c7 44 24 04 d3 3d 00 	movl   $0x3dd3,0x4(%esp)
     18b:	00 
     18c:	a1 b4 55 00 00       	mov    0x55b4,%eax
     191:	89 04 24             	mov    %eax,(%esp)
     194:	e8 5d 39 00 00       	call   3af6 <printf>
      exit();
     199:	e8 eb 37 00 00       	call   3989 <exit>
    }
    exit();
     19e:	e8 e6 37 00 00       	call   3989 <exit>
  }
  wait();
     1a3:	e8 e9 37 00 00       	call   3991 <wait>
  printf(stdout, "exitiput test ok\n");
     1a8:	c7 44 24 04 22 3e 00 	movl   $0x3e22,0x4(%esp)
     1af:	00 
     1b0:	a1 b4 55 00 00       	mov    0x55b4,%eax
     1b5:	89 04 24             	mov    %eax,(%esp)
     1b8:	e8 39 39 00 00       	call   3af6 <printf>
}
     1bd:	c9                   	leave  
     1be:	c3                   	ret    

000001bf <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
     1bf:	55                   	push   %ebp
     1c0:	89 e5                	mov    %esp,%ebp
     1c2:	83 ec 18             	sub    $0x18,%esp
  int pid;

  printf(stdout, "openiput test\n");
     1c5:	c7 44 24 04 34 3e 00 	movl   $0x3e34,0x4(%esp)
     1cc:	00 
     1cd:	a1 b4 55 00 00       	mov    0x55b4,%eax
     1d2:	89 04 24             	mov    %eax,(%esp)
     1d5:	e8 1c 39 00 00       	call   3af6 <printf>
  if(mkdir("oidir") < 0){
     1da:	c7 04 24 43 3e 00 00 	movl   $0x3e43,(%esp)
     1e1:	e8 0b 38 00 00       	call   39f1 <mkdir>
     1e6:	85 c0                	test   %eax,%eax
     1e8:	79 1a                	jns    204 <openiputtest+0x45>
    printf(stdout, "mkdir oidir failed\n");
     1ea:	c7 44 24 04 49 3e 00 	movl   $0x3e49,0x4(%esp)
     1f1:	00 
     1f2:	a1 b4 55 00 00       	mov    0x55b4,%eax
     1f7:	89 04 24             	mov    %eax,(%esp)
     1fa:	e8 f7 38 00 00       	call   3af6 <printf>
    exit();
     1ff:	e8 85 37 00 00       	call   3989 <exit>
  }
  pid = fork();
     204:	e8 78 37 00 00       	call   3981 <fork>
  if(pid < 0){
     209:	85 c0                	test   %eax,%eax
     20b:	79 1a                	jns    227 <openiputtest+0x68>
    printf(stdout, "fork failed\n");
     20d:	c7 44 24 04 e5 4c 00 	movl   $0x4ce5,0x4(%esp)
     214:	00 
     215:	a1 b4 55 00 00       	mov    0x55b4,%eax
     21a:	89 04 24             	mov    %eax,(%esp)
     21d:	e8 d4 38 00 00       	call   3af6 <printf>
    exit();
     222:	e8 62 37 00 00       	call   3989 <exit>
  }
  if(pid == 0){
     227:	85 c0                	test   %eax,%eax
     229:	75 37                	jne    262 <openiputtest+0xa3>
    int fd = open("oidir", O_RDWR);
     22b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     232:	00 
     233:	c7 04 24 43 3e 00 00 	movl   $0x3e43,(%esp)
     23a:	e8 8a 37 00 00       	call   39c9 <open>
    if(fd >= 0){
     23f:	85 c0                	test   %eax,%eax
     241:	78 1a                	js     25d <openiputtest+0x9e>
      printf(stdout, "open directory for write succeeded\n");
     243:	c7 44 24 04 c8 4d 00 	movl   $0x4dc8,0x4(%esp)
     24a:	00 
     24b:	a1 b4 55 00 00       	mov    0x55b4,%eax
     250:	89 04 24             	mov    %eax,(%esp)
     253:	e8 9e 38 00 00       	call   3af6 <printf>
      exit();
     258:	e8 2c 37 00 00       	call   3989 <exit>
    }
    exit();
     25d:	e8 27 37 00 00       	call   3989 <exit>
  }
  sleep(1);
     262:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     269:	e8 ab 37 00 00       	call   3a19 <sleep>
  if(unlink("oidir") != 0){
     26e:	c7 04 24 43 3e 00 00 	movl   $0x3e43,(%esp)
     275:	e8 5f 37 00 00       	call   39d9 <unlink>
     27a:	85 c0                	test   %eax,%eax
     27c:	74 1a                	je     298 <openiputtest+0xd9>
    printf(stdout, "unlink failed\n");
     27e:	c7 44 24 04 5d 3e 00 	movl   $0x3e5d,0x4(%esp)
     285:	00 
     286:	a1 b4 55 00 00       	mov    0x55b4,%eax
     28b:	89 04 24             	mov    %eax,(%esp)
     28e:	e8 63 38 00 00       	call   3af6 <printf>
    exit();
     293:	e8 f1 36 00 00       	call   3989 <exit>
  }
  wait();
     298:	e8 f4 36 00 00       	call   3991 <wait>
  printf(stdout, "openiput test ok\n");
     29d:	c7 44 24 04 6c 3e 00 	movl   $0x3e6c,0x4(%esp)
     2a4:	00 
     2a5:	a1 b4 55 00 00       	mov    0x55b4,%eax
     2aa:	89 04 24             	mov    %eax,(%esp)
     2ad:	e8 44 38 00 00       	call   3af6 <printf>
}
     2b2:	c9                   	leave  
     2b3:	c3                   	ret    

000002b4 <opentest>:

// simple file system tests

void
opentest(void)
{
     2b4:	55                   	push   %ebp
     2b5:	89 e5                	mov    %esp,%ebp
     2b7:	83 ec 18             	sub    $0x18,%esp
  int fd;

  printf(stdout, "open test\n");
     2ba:	c7 44 24 04 7e 3e 00 	movl   $0x3e7e,0x4(%esp)
     2c1:	00 
     2c2:	a1 b4 55 00 00       	mov    0x55b4,%eax
     2c7:	89 04 24             	mov    %eax,(%esp)
     2ca:	e8 27 38 00 00       	call   3af6 <printf>
  fd = open("echo", 0);
     2cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     2d6:	00 
     2d7:	c7 04 24 89 3e 00 00 	movl   $0x3e89,(%esp)
     2de:	e8 e6 36 00 00       	call   39c9 <open>
  if(fd < 0){
     2e3:	85 c0                	test   %eax,%eax
     2e5:	79 1a                	jns    301 <opentest+0x4d>
    printf(stdout, "open echo failed!\n");
     2e7:	c7 44 24 04 8e 3e 00 	movl   $0x3e8e,0x4(%esp)
     2ee:	00 
     2ef:	a1 b4 55 00 00       	mov    0x55b4,%eax
     2f4:	89 04 24             	mov    %eax,(%esp)
     2f7:	e8 fa 37 00 00       	call   3af6 <printf>
    exit();
     2fc:	e8 88 36 00 00       	call   3989 <exit>
  }
  close(fd);
     301:	89 04 24             	mov    %eax,(%esp)
     304:	e8 a8 36 00 00       	call   39b1 <close>
  fd = open("doesnotexist", 0);
     309:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     310:	00 
     311:	c7 04 24 a1 3e 00 00 	movl   $0x3ea1,(%esp)
     318:	e8 ac 36 00 00       	call   39c9 <open>
  if(fd >= 0){
     31d:	85 c0                	test   %eax,%eax
     31f:	78 1a                	js     33b <opentest+0x87>
    printf(stdout, "open doesnotexist succeeded!\n");
     321:	c7 44 24 04 ae 3e 00 	movl   $0x3eae,0x4(%esp)
     328:	00 
     329:	a1 b4 55 00 00       	mov    0x55b4,%eax
     32e:	89 04 24             	mov    %eax,(%esp)
     331:	e8 c0 37 00 00       	call   3af6 <printf>
    exit();
     336:	e8 4e 36 00 00       	call   3989 <exit>
  }
  printf(stdout, "open test ok\n");
     33b:	c7 44 24 04 cc 3e 00 	movl   $0x3ecc,0x4(%esp)
     342:	00 
     343:	a1 b4 55 00 00       	mov    0x55b4,%eax
     348:	89 04 24             	mov    %eax,(%esp)
     34b:	e8 a6 37 00 00       	call   3af6 <printf>
}
     350:	c9                   	leave  
     351:	c3                   	ret    

00000352 <writetest>:

void
writetest(void)
{
     352:	55                   	push   %ebp
     353:	89 e5                	mov    %esp,%ebp
     355:	56                   	push   %esi
     356:	53                   	push   %ebx
     357:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
     35a:	c7 44 24 04 da 3e 00 	movl   $0x3eda,0x4(%esp)
     361:	00 
     362:	a1 b4 55 00 00       	mov    0x55b4,%eax
     367:	89 04 24             	mov    %eax,(%esp)
     36a:	e8 87 37 00 00       	call   3af6 <printf>
  fd = open("small", O_CREATE|O_RDWR);
     36f:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     376:	00 
     377:	c7 04 24 eb 3e 00 00 	movl   $0x3eeb,(%esp)
     37e:	e8 46 36 00 00       	call   39c9 <open>
     383:	89 c6                	mov    %eax,%esi
  if(fd >= 0){
     385:	85 c0                	test   %eax,%eax
     387:	78 1f                	js     3a8 <writetest+0x56>
    printf(stdout, "creat small succeeded; ok\n");
     389:	c7 44 24 04 f1 3e 00 	movl   $0x3ef1,0x4(%esp)
     390:	00 
     391:	a1 b4 55 00 00       	mov    0x55b4,%eax
     396:	89 04 24             	mov    %eax,(%esp)
     399:	e8 58 37 00 00       	call   3af6 <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     39e:	bb 00 00 00 00       	mov    $0x0,%ebx
     3a3:	e9 93 00 00 00       	jmp    43b <writetest+0xe9>
    printf(stdout, "error: creat small failed!\n");
     3a8:	c7 44 24 04 0c 3f 00 	movl   $0x3f0c,0x4(%esp)
     3af:	00 
     3b0:	a1 b4 55 00 00       	mov    0x55b4,%eax
     3b5:	89 04 24             	mov    %eax,(%esp)
     3b8:	e8 39 37 00 00       	call   3af6 <printf>
    exit();
     3bd:	e8 c7 35 00 00       	call   3989 <exit>
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     3c2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     3c9:	00 
     3ca:	c7 44 24 04 28 3f 00 	movl   $0x3f28,0x4(%esp)
     3d1:	00 
     3d2:	89 34 24             	mov    %esi,(%esp)
     3d5:	e8 cf 35 00 00       	call   39a9 <write>
     3da:	83 f8 0a             	cmp    $0xa,%eax
     3dd:	74 1e                	je     3fd <writetest+0xab>
      printf(stdout, "error: write aa %d new file failed\n", i);
     3df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     3e3:	c7 44 24 04 ec 4d 00 	movl   $0x4dec,0x4(%esp)
     3ea:	00 
     3eb:	a1 b4 55 00 00       	mov    0x55b4,%eax
     3f0:	89 04 24             	mov    %eax,(%esp)
     3f3:	e8 fe 36 00 00       	call   3af6 <printf>
      exit();
     3f8:	e8 8c 35 00 00       	call   3989 <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     3fd:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     404:	00 
     405:	c7 44 24 04 33 3f 00 	movl   $0x3f33,0x4(%esp)
     40c:	00 
     40d:	89 34 24             	mov    %esi,(%esp)
     410:	e8 94 35 00 00       	call   39a9 <write>
     415:	83 f8 0a             	cmp    $0xa,%eax
     418:	74 1e                	je     438 <writetest+0xe6>
      printf(stdout, "error: write bb %d new file failed\n", i);
     41a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     41e:	c7 44 24 04 10 4e 00 	movl   $0x4e10,0x4(%esp)
     425:	00 
     426:	a1 b4 55 00 00       	mov    0x55b4,%eax
     42b:	89 04 24             	mov    %eax,(%esp)
     42e:	e8 c3 36 00 00       	call   3af6 <printf>
      exit();
     433:	e8 51 35 00 00       	call   3989 <exit>
  for(i = 0; i < 100; i++){
     438:	83 c3 01             	add    $0x1,%ebx
     43b:	83 fb 63             	cmp    $0x63,%ebx
     43e:	7e 82                	jle    3c2 <writetest+0x70>
    }
  }
  printf(stdout, "writes ok\n");
     440:	c7 44 24 04 3e 3f 00 	movl   $0x3f3e,0x4(%esp)
     447:	00 
     448:	a1 b4 55 00 00       	mov    0x55b4,%eax
     44d:	89 04 24             	mov    %eax,(%esp)
     450:	e8 a1 36 00 00       	call   3af6 <printf>
  close(fd);
     455:	89 34 24             	mov    %esi,(%esp)
     458:	e8 54 35 00 00       	call   39b1 <close>
  fd = open("small", O_RDONLY);
     45d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     464:	00 
     465:	c7 04 24 eb 3e 00 00 	movl   $0x3eeb,(%esp)
     46c:	e8 58 35 00 00       	call   39c9 <open>
     471:	89 c3                	mov    %eax,%ebx
  if(fd >= 0){
     473:	85 c0                	test   %eax,%eax
     475:	78 36                	js     4ad <writetest+0x15b>
    printf(stdout, "open small succeeded ok\n");
     477:	c7 44 24 04 49 3f 00 	movl   $0x3f49,0x4(%esp)
     47e:	00 
     47f:	a1 b4 55 00 00       	mov    0x55b4,%eax
     484:	89 04 24             	mov    %eax,(%esp)
     487:	e8 6a 36 00 00       	call   3af6 <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
     48c:	c7 44 24 08 d0 07 00 	movl   $0x7d0,0x8(%esp)
     493:	00 
     494:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
     49b:	00 
     49c:	89 1c 24             	mov    %ebx,(%esp)
     49f:	e8 fd 34 00 00       	call   39a1 <read>
  if(i == 2000){
     4a4:	3d d0 07 00 00       	cmp    $0x7d0,%eax
     4a9:	74 1c                	je     4c7 <writetest+0x175>
     4ab:	eb 49                	jmp    4f6 <writetest+0x1a4>
    printf(stdout, "error: open small failed!\n");
     4ad:	c7 44 24 04 62 3f 00 	movl   $0x3f62,0x4(%esp)
     4b4:	00 
     4b5:	a1 b4 55 00 00       	mov    0x55b4,%eax
     4ba:	89 04 24             	mov    %eax,(%esp)
     4bd:	e8 34 36 00 00       	call   3af6 <printf>
    exit();
     4c2:	e8 c2 34 00 00       	call   3989 <exit>
    printf(stdout, "read succeeded ok\n");
     4c7:	c7 44 24 04 7d 3f 00 	movl   $0x3f7d,0x4(%esp)
     4ce:	00 
     4cf:	a1 b4 55 00 00       	mov    0x55b4,%eax
     4d4:	89 04 24             	mov    %eax,(%esp)
     4d7:	e8 1a 36 00 00       	call   3af6 <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
     4dc:	89 1c 24             	mov    %ebx,(%esp)
     4df:	e8 cd 34 00 00       	call   39b1 <close>

  if(unlink("small") < 0){
     4e4:	c7 04 24 eb 3e 00 00 	movl   $0x3eeb,(%esp)
     4eb:	e8 e9 34 00 00       	call   39d9 <unlink>
     4f0:	85 c0                	test   %eax,%eax
     4f2:	79 36                	jns    52a <writetest+0x1d8>
     4f4:	eb 1a                	jmp    510 <writetest+0x1be>
    printf(stdout, "read failed\n");
     4f6:	c7 44 24 04 a9 42 00 	movl   $0x42a9,0x4(%esp)
     4fd:	00 
     4fe:	a1 b4 55 00 00       	mov    0x55b4,%eax
     503:	89 04 24             	mov    %eax,(%esp)
     506:	e8 eb 35 00 00       	call   3af6 <printf>
    exit();
     50b:	e8 79 34 00 00       	call   3989 <exit>
    printf(stdout, "unlink small failed\n");
     510:	c7 44 24 04 90 3f 00 	movl   $0x3f90,0x4(%esp)
     517:	00 
     518:	a1 b4 55 00 00       	mov    0x55b4,%eax
     51d:	89 04 24             	mov    %eax,(%esp)
     520:	e8 d1 35 00 00       	call   3af6 <printf>
    exit();
     525:	e8 5f 34 00 00       	call   3989 <exit>
  }
  printf(stdout, "small file test ok\n");
     52a:	c7 44 24 04 a5 3f 00 	movl   $0x3fa5,0x4(%esp)
     531:	00 
     532:	a1 b4 55 00 00       	mov    0x55b4,%eax
     537:	89 04 24             	mov    %eax,(%esp)
     53a:	e8 b7 35 00 00       	call   3af6 <printf>
}
     53f:	83 c4 10             	add    $0x10,%esp
     542:	5b                   	pop    %ebx
     543:	5e                   	pop    %esi
     544:	5d                   	pop    %ebp
     545:	c3                   	ret    

00000546 <writetest1>:

void
writetest1(void)
{
     546:	55                   	push   %ebp
     547:	89 e5                	mov    %esp,%ebp
     549:	56                   	push   %esi
     54a:	53                   	push   %ebx
     54b:	83 ec 10             	sub    $0x10,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
     54e:	c7 44 24 04 b9 3f 00 	movl   $0x3fb9,0x4(%esp)
     555:	00 
     556:	a1 b4 55 00 00       	mov    0x55b4,%eax
     55b:	89 04 24             	mov    %eax,(%esp)
     55e:	e8 93 35 00 00       	call   3af6 <printf>

  fd = open("big", O_CREATE|O_RDWR);
     563:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     56a:	00 
     56b:	c7 04 24 33 40 00 00 	movl   $0x4033,(%esp)
     572:	e8 52 34 00 00       	call   39c9 <open>
     577:	89 c6                	mov    %eax,%esi
  if(fd < 0){
     579:	85 c0                	test   %eax,%eax
     57b:	79 62                	jns    5df <writetest1+0x99>
    printf(stdout, "error: creat big failed!\n");
     57d:	c7 44 24 04 c9 3f 00 	movl   $0x3fc9,0x4(%esp)
     584:	00 
     585:	a1 b4 55 00 00       	mov    0x55b4,%eax
     58a:	89 04 24             	mov    %eax,(%esp)
     58d:	e8 64 35 00 00       	call   3af6 <printf>
    exit();
     592:	e8 f2 33 00 00       	call   3989 <exit>
  }

  for(i = 0; i < MAXFILE; i++){
    ((int*)buf)[0] = i;
     597:	89 1d a0 7d 00 00    	mov    %ebx,0x7da0
    if(write(fd, buf, 512) != 512){
     59d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     5a4:	00 
     5a5:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
     5ac:	00 
     5ad:	89 34 24             	mov    %esi,(%esp)
     5b0:	e8 f4 33 00 00       	call   39a9 <write>
     5b5:	3d 00 02 00 00       	cmp    $0x200,%eax
     5ba:	74 1e                	je     5da <writetest1+0x94>
      printf(stdout, "error: write big file failed\n", i);
     5bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     5c0:	c7 44 24 04 e3 3f 00 	movl   $0x3fe3,0x4(%esp)
     5c7:	00 
     5c8:	a1 b4 55 00 00       	mov    0x55b4,%eax
     5cd:	89 04 24             	mov    %eax,(%esp)
     5d0:	e8 21 35 00 00       	call   3af6 <printf>
      exit();
     5d5:	e8 af 33 00 00       	call   3989 <exit>
  for(i = 0; i < MAXFILE; i++){
     5da:	83 c3 01             	add    $0x1,%ebx
     5dd:	eb 05                	jmp    5e4 <writetest1+0x9e>
     5df:	bb 00 00 00 00       	mov    $0x0,%ebx
     5e4:	81 fb 8b 00 00 00    	cmp    $0x8b,%ebx
     5ea:	76 ab                	jbe    597 <writetest1+0x51>
    }
  }

  close(fd);
     5ec:	89 34 24             	mov    %esi,(%esp)
     5ef:	e8 bd 33 00 00       	call   39b1 <close>

  fd = open("big", O_RDONLY);
     5f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     5fb:	00 
     5fc:	c7 04 24 33 40 00 00 	movl   $0x4033,(%esp)
     603:	e8 c1 33 00 00       	call   39c9 <open>
     608:	89 c6                	mov    %eax,%esi
  if(fd < 0){
     60a:	85 c0                	test   %eax,%eax
     60c:	79 1a                	jns    628 <writetest1+0xe2>
    printf(stdout, "error: open big failed!\n");
     60e:	c7 44 24 04 01 40 00 	movl   $0x4001,0x4(%esp)
     615:	00 
     616:	a1 b4 55 00 00       	mov    0x55b4,%eax
     61b:	89 04 24             	mov    %eax,(%esp)
     61e:	e8 d3 34 00 00       	call   3af6 <printf>
    exit();
     623:	e8 61 33 00 00       	call   3989 <exit>
     628:	bb 00 00 00 00       	mov    $0x0,%ebx
  }

  n = 0;
  for(;;){
    i = read(fd, buf, 512);
     62d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     634:	00 
     635:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
     63c:	00 
     63d:	89 34 24             	mov    %esi,(%esp)
     640:	e8 5c 33 00 00       	call   39a1 <read>
    if(i == 0){
     645:	85 c0                	test   %eax,%eax
     647:	75 26                	jne    66f <writetest1+0x129>
      if(n == MAXFILE - 1){
     649:	81 fb 8b 00 00 00    	cmp    $0x8b,%ebx
     64f:	75 76                	jne    6c7 <writetest1+0x181>
        printf(stdout, "read only %d blocks from big", n);
     651:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     655:	c7 44 24 04 1a 40 00 	movl   $0x401a,0x4(%esp)
     65c:	00 
     65d:	a1 b4 55 00 00       	mov    0x55b4,%eax
     662:	89 04 24             	mov    %eax,(%esp)
     665:	e8 8c 34 00 00       	call   3af6 <printf>
        exit();
     66a:	e8 1a 33 00 00       	call   3989 <exit>
      }
      break;
    } else if(i != 512){
     66f:	3d 00 02 00 00       	cmp    $0x200,%eax
     674:	74 1e                	je     694 <writetest1+0x14e>
      printf(stdout, "read failed %d\n", i);
     676:	89 44 24 08          	mov    %eax,0x8(%esp)
     67a:	c7 44 24 04 37 40 00 	movl   $0x4037,0x4(%esp)
     681:	00 
     682:	a1 b4 55 00 00       	mov    0x55b4,%eax
     687:	89 04 24             	mov    %eax,(%esp)
     68a:	e8 67 34 00 00       	call   3af6 <printf>
      exit();
     68f:	e8 f5 32 00 00       	call   3989 <exit>
    }
    if(((int*)buf)[0] != n){
     694:	a1 a0 7d 00 00       	mov    0x7da0,%eax
     699:	39 d8                	cmp    %ebx,%eax
     69b:	74 22                	je     6bf <writetest1+0x179>
      printf(stdout, "read content of block %d is %d\n",
     69d:	89 44 24 0c          	mov    %eax,0xc(%esp)
     6a1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     6a5:	c7 44 24 04 34 4e 00 	movl   $0x4e34,0x4(%esp)
     6ac:	00 
     6ad:	a1 b4 55 00 00       	mov    0x55b4,%eax
     6b2:	89 04 24             	mov    %eax,(%esp)
     6b5:	e8 3c 34 00 00       	call   3af6 <printf>
             n, ((int*)buf)[0]);
      exit();
     6ba:	e8 ca 32 00 00       	call   3989 <exit>
    }
    n++;
     6bf:	83 c3 01             	add    $0x1,%ebx
  }
     6c2:	e9 66 ff ff ff       	jmp    62d <writetest1+0xe7>
  close(fd);
     6c7:	89 34 24             	mov    %esi,(%esp)
     6ca:	e8 e2 32 00 00       	call   39b1 <close>
  if(unlink("big") < 0){
     6cf:	c7 04 24 33 40 00 00 	movl   $0x4033,(%esp)
     6d6:	e8 fe 32 00 00       	call   39d9 <unlink>
     6db:	85 c0                	test   %eax,%eax
     6dd:	79 1a                	jns    6f9 <writetest1+0x1b3>
    printf(stdout, "unlink big failed\n");
     6df:	c7 44 24 04 47 40 00 	movl   $0x4047,0x4(%esp)
     6e6:	00 
     6e7:	a1 b4 55 00 00       	mov    0x55b4,%eax
     6ec:	89 04 24             	mov    %eax,(%esp)
     6ef:	e8 02 34 00 00       	call   3af6 <printf>
    exit();
     6f4:	e8 90 32 00 00       	call   3989 <exit>
  }
  printf(stdout, "big files ok\n");
     6f9:	c7 44 24 04 5a 40 00 	movl   $0x405a,0x4(%esp)
     700:	00 
     701:	a1 b4 55 00 00       	mov    0x55b4,%eax
     706:	89 04 24             	mov    %eax,(%esp)
     709:	e8 e8 33 00 00       	call   3af6 <printf>
}
     70e:	83 c4 10             	add    $0x10,%esp
     711:	5b                   	pop    %ebx
     712:	5e                   	pop    %esi
     713:	5d                   	pop    %ebp
     714:	c3                   	ret    

00000715 <createtest>:

void
createtest(void)
{
     715:	55                   	push   %ebp
     716:	89 e5                	mov    %esp,%ebp
     718:	53                   	push   %ebx
     719:	83 ec 14             	sub    $0x14,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     71c:	c7 44 24 04 54 4e 00 	movl   $0x4e54,0x4(%esp)
     723:	00 
     724:	a1 b4 55 00 00       	mov    0x55b4,%eax
     729:	89 04 24             	mov    %eax,(%esp)
     72c:	e8 c5 33 00 00       	call   3af6 <printf>

  name[0] = 'a';
     731:	c6 05 a0 9d 00 00 61 	movb   $0x61,0x9da0
  name[2] = '\0';
     738:	c6 05 a2 9d 00 00 00 	movb   $0x0,0x9da2
  for(i = 0; i < 52; i++){
     73f:	bb 00 00 00 00       	mov    $0x0,%ebx
     744:	eb 27                	jmp    76d <createtest+0x58>
    name[1] = '0' + i;
     746:	8d 43 30             	lea    0x30(%ebx),%eax
     749:	a2 a1 9d 00 00       	mov    %al,0x9da1
    fd = open(name, O_CREATE|O_RDWR);
     74e:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     755:	00 
     756:	c7 04 24 a0 9d 00 00 	movl   $0x9da0,(%esp)
     75d:	e8 67 32 00 00       	call   39c9 <open>
    close(fd);
     762:	89 04 24             	mov    %eax,(%esp)
     765:	e8 47 32 00 00       	call   39b1 <close>
  for(i = 0; i < 52; i++){
     76a:	83 c3 01             	add    $0x1,%ebx
     76d:	83 fb 33             	cmp    $0x33,%ebx
     770:	7e d4                	jle    746 <createtest+0x31>
  }
  name[0] = 'a';
     772:	c6 05 a0 9d 00 00 61 	movb   $0x61,0x9da0
  name[2] = '\0';
     779:	c6 05 a2 9d 00 00 00 	movb   $0x0,0x9da2
  for(i = 0; i < 52; i++){
     780:	bb 00 00 00 00       	mov    $0x0,%ebx
     785:	eb 17                	jmp    79e <createtest+0x89>
    name[1] = '0' + i;
     787:	8d 43 30             	lea    0x30(%ebx),%eax
     78a:	a2 a1 9d 00 00       	mov    %al,0x9da1
    unlink(name);
     78f:	c7 04 24 a0 9d 00 00 	movl   $0x9da0,(%esp)
     796:	e8 3e 32 00 00       	call   39d9 <unlink>
  for(i = 0; i < 52; i++){
     79b:	83 c3 01             	add    $0x1,%ebx
     79e:	83 fb 33             	cmp    $0x33,%ebx
     7a1:	7e e4                	jle    787 <createtest+0x72>
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     7a3:	c7 44 24 04 7c 4e 00 	movl   $0x4e7c,0x4(%esp)
     7aa:	00 
     7ab:	a1 b4 55 00 00       	mov    0x55b4,%eax
     7b0:	89 04 24             	mov    %eax,(%esp)
     7b3:	e8 3e 33 00 00       	call   3af6 <printf>
}
     7b8:	83 c4 14             	add    $0x14,%esp
     7bb:	5b                   	pop    %ebx
     7bc:	5d                   	pop    %ebp
     7bd:	c3                   	ret    

000007be <dirtest>:

void dirtest(void)
{
     7be:	55                   	push   %ebp
     7bf:	89 e5                	mov    %esp,%ebp
     7c1:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "mkdir test\n");
     7c4:	c7 44 24 04 68 40 00 	movl   $0x4068,0x4(%esp)
     7cb:	00 
     7cc:	a1 b4 55 00 00       	mov    0x55b4,%eax
     7d1:	89 04 24             	mov    %eax,(%esp)
     7d4:	e8 1d 33 00 00       	call   3af6 <printf>

  if(mkdir("dir0") < 0){
     7d9:	c7 04 24 74 40 00 00 	movl   $0x4074,(%esp)
     7e0:	e8 0c 32 00 00       	call   39f1 <mkdir>
     7e5:	85 c0                	test   %eax,%eax
     7e7:	79 1a                	jns    803 <dirtest+0x45>
    printf(stdout, "mkdir failed\n");
     7e9:	c7 44 24 04 a4 3d 00 	movl   $0x3da4,0x4(%esp)
     7f0:	00 
     7f1:	a1 b4 55 00 00       	mov    0x55b4,%eax
     7f6:	89 04 24             	mov    %eax,(%esp)
     7f9:	e8 f8 32 00 00       	call   3af6 <printf>
    exit();
     7fe:	e8 86 31 00 00       	call   3989 <exit>
  }

  if(chdir("dir0") < 0){
     803:	c7 04 24 74 40 00 00 	movl   $0x4074,(%esp)
     80a:	e8 ea 31 00 00       	call   39f9 <chdir>
     80f:	85 c0                	test   %eax,%eax
     811:	79 1a                	jns    82d <dirtest+0x6f>
    printf(stdout, "chdir dir0 failed\n");
     813:	c7 44 24 04 79 40 00 	movl   $0x4079,0x4(%esp)
     81a:	00 
     81b:	a1 b4 55 00 00       	mov    0x55b4,%eax
     820:	89 04 24             	mov    %eax,(%esp)
     823:	e8 ce 32 00 00       	call   3af6 <printf>
    exit();
     828:	e8 5c 31 00 00       	call   3989 <exit>
  }

  if(chdir("..") < 0){
     82d:	c7 04 24 19 46 00 00 	movl   $0x4619,(%esp)
     834:	e8 c0 31 00 00       	call   39f9 <chdir>
     839:	85 c0                	test   %eax,%eax
     83b:	79 1a                	jns    857 <dirtest+0x99>
    printf(stdout, "chdir .. failed\n");
     83d:	c7 44 24 04 8c 40 00 	movl   $0x408c,0x4(%esp)
     844:	00 
     845:	a1 b4 55 00 00       	mov    0x55b4,%eax
     84a:	89 04 24             	mov    %eax,(%esp)
     84d:	e8 a4 32 00 00       	call   3af6 <printf>
    exit();
     852:	e8 32 31 00 00       	call   3989 <exit>
  }

  if(unlink("dir0") < 0){
     857:	c7 04 24 74 40 00 00 	movl   $0x4074,(%esp)
     85e:	e8 76 31 00 00       	call   39d9 <unlink>
     863:	85 c0                	test   %eax,%eax
     865:	79 1a                	jns    881 <dirtest+0xc3>
    printf(stdout, "unlink dir0 failed\n");
     867:	c7 44 24 04 9d 40 00 	movl   $0x409d,0x4(%esp)
     86e:	00 
     86f:	a1 b4 55 00 00       	mov    0x55b4,%eax
     874:	89 04 24             	mov    %eax,(%esp)
     877:	e8 7a 32 00 00       	call   3af6 <printf>
    exit();
     87c:	e8 08 31 00 00       	call   3989 <exit>
  }
  printf(stdout, "mkdir test ok\n");
     881:	c7 44 24 04 b1 40 00 	movl   $0x40b1,0x4(%esp)
     888:	00 
     889:	a1 b4 55 00 00       	mov    0x55b4,%eax
     88e:	89 04 24             	mov    %eax,(%esp)
     891:	e8 60 32 00 00       	call   3af6 <printf>
}
     896:	c9                   	leave  
     897:	c3                   	ret    

00000898 <exectest>:

void
exectest(void)
{
     898:	55                   	push   %ebp
     899:	89 e5                	mov    %esp,%ebp
     89b:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "exec test\n");
     89e:	c7 44 24 04 c0 40 00 	movl   $0x40c0,0x4(%esp)
     8a5:	00 
     8a6:	a1 b4 55 00 00       	mov    0x55b4,%eax
     8ab:	89 04 24             	mov    %eax,(%esp)
     8ae:	e8 43 32 00 00       	call   3af6 <printf>
  if(exec("echo", echoargv) < 0){
     8b3:	c7 44 24 04 b8 55 00 	movl   $0x55b8,0x4(%esp)
     8ba:	00 
     8bb:	c7 04 24 89 3e 00 00 	movl   $0x3e89,(%esp)
     8c2:	e8 fa 30 00 00       	call   39c1 <exec>
     8c7:	85 c0                	test   %eax,%eax
     8c9:	79 1a                	jns    8e5 <exectest+0x4d>
    printf(stdout, "exec echo failed\n");
     8cb:	c7 44 24 04 cb 40 00 	movl   $0x40cb,0x4(%esp)
     8d2:	00 
     8d3:	a1 b4 55 00 00       	mov    0x55b4,%eax
     8d8:	89 04 24             	mov    %eax,(%esp)
     8db:	e8 16 32 00 00       	call   3af6 <printf>
    exit();
     8e0:	e8 a4 30 00 00       	call   3989 <exit>
  }
}
     8e5:	c9                   	leave  
     8e6:	c3                   	ret    

000008e7 <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     8e7:	55                   	push   %ebp
     8e8:	89 e5                	mov    %esp,%ebp
     8ea:	57                   	push   %edi
     8eb:	56                   	push   %esi
     8ec:	53                   	push   %ebx
     8ed:	83 ec 2c             	sub    $0x2c,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     8f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
     8f3:	89 04 24             	mov    %eax,(%esp)
     8f6:	e8 9e 30 00 00       	call   3999 <pipe>
     8fb:	85 c0                	test   %eax,%eax
     8fd:	74 19                	je     918 <pipe1+0x31>
    printf(1, "pipe() failed\n");
     8ff:	c7 44 24 04 dd 40 00 	movl   $0x40dd,0x4(%esp)
     906:	00 
     907:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     90e:	e8 e3 31 00 00       	call   3af6 <printf>
    exit();
     913:	e8 71 30 00 00       	call   3989 <exit>
  }
  pid = fork();
     918:	e8 64 30 00 00       	call   3981 <fork>
  seq = 0;
  if(pid == 0){
     91d:	85 c0                	test   %eax,%eax
     91f:	90                   	nop
     920:	75 79                	jne    99b <pipe1+0xb4>
    close(fds[0]);
     922:	8b 45 e0             	mov    -0x20(%ebp),%eax
     925:	89 04 24             	mov    %eax,(%esp)
     928:	e8 84 30 00 00       	call   39b1 <close>
    for(n = 0; n < 5; n++){
     92d:	be 00 00 00 00       	mov    $0x0,%esi
  seq = 0;
     932:	bb 00 00 00 00       	mov    $0x0,%ebx
    for(n = 0; n < 5; n++){
     937:	eb 58                	jmp    991 <pipe1+0xaa>
      for(i = 0; i < 1033; i++)
        buf[i] = seq++;
     939:	88 98 a0 7d 00 00    	mov    %bl,0x7da0(%eax)
      for(i = 0; i < 1033; i++)
     93f:	83 c0 01             	add    $0x1,%eax
        buf[i] = seq++;
     942:	8d 5b 01             	lea    0x1(%ebx),%ebx
     945:	eb 05                	jmp    94c <pipe1+0x65>
     947:	b8 00 00 00 00       	mov    $0x0,%eax
      for(i = 0; i < 1033; i++)
     94c:	3d 08 04 00 00       	cmp    $0x408,%eax
     951:	7e e6                	jle    939 <pipe1+0x52>
      if(write(fds[1], buf, 1033) != 1033){
     953:	c7 44 24 08 09 04 00 	movl   $0x409,0x8(%esp)
     95a:	00 
     95b:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
     962:	00 
     963:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     966:	89 04 24             	mov    %eax,(%esp)
     969:	e8 3b 30 00 00       	call   39a9 <write>
     96e:	3d 09 04 00 00       	cmp    $0x409,%eax
     973:	74 19                	je     98e <pipe1+0xa7>
        printf(1, "pipe1 oops 1\n");
     975:	c7 44 24 04 ec 40 00 	movl   $0x40ec,0x4(%esp)
     97c:	00 
     97d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     984:	e8 6d 31 00 00       	call   3af6 <printf>
        exit();
     989:	e8 fb 2f 00 00       	call   3989 <exit>
    for(n = 0; n < 5; n++){
     98e:	83 c6 01             	add    $0x1,%esi
     991:	83 fe 04             	cmp    $0x4,%esi
     994:	7e b1                	jle    947 <pipe1+0x60>
      }
    }
    exit();
     996:	e8 ee 2f 00 00       	call   3989 <exit>
  } else if(pid > 0){
     99b:	85 c0                	test   %eax,%eax
     99d:	0f 8e c7 00 00 00    	jle    a6a <pipe1+0x183>
    close(fds[1]);
     9a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     9a6:	89 04 24             	mov    %eax,(%esp)
     9a9:	e8 03 30 00 00       	call   39b1 <close>
    total = 0;
     9ae:	bf 00 00 00 00       	mov    $0x0,%edi
    cc = 1;
     9b3:	be 01 00 00 00       	mov    $0x1,%esi
  seq = 0;
     9b8:	bb 00 00 00 00       	mov    $0x0,%ebx
    while((n = read(fds[0], buf, cc)) > 0){
     9bd:	eb 45                	jmp    a04 <pipe1+0x11d>
      for(i = 0; i < n; i++){
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     9bf:	8d 4b 01             	lea    0x1(%ebx),%ecx
     9c2:	38 9a a0 7d 00 00    	cmp    %bl,0x7da0(%edx)
     9c8:	74 19                	je     9e3 <pipe1+0xfc>
          printf(1, "pipe1 oops 2\n");
     9ca:	c7 44 24 04 fa 40 00 	movl   $0x40fa,0x4(%esp)
     9d1:	00 
     9d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     9d9:	e8 18 31 00 00       	call   3af6 <printf>
     9de:	e9 a0 00 00 00       	jmp    a83 <pipe1+0x19c>
      for(i = 0; i < n; i++){
     9e3:	83 c2 01             	add    $0x1,%edx
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     9e6:	89 cb                	mov    %ecx,%ebx
     9e8:	eb 05                	jmp    9ef <pipe1+0x108>
     9ea:	ba 00 00 00 00       	mov    $0x0,%edx
      for(i = 0; i < n; i++){
     9ef:	39 c2                	cmp    %eax,%edx
     9f1:	7c cc                	jl     9bf <pipe1+0xd8>
          return;
        }
      }
      total += n;
     9f3:	01 c7                	add    %eax,%edi
      cc = cc * 2;
     9f5:	01 f6                	add    %esi,%esi
      if(cc > sizeof(buf))
     9f7:	81 fe 00 20 00 00    	cmp    $0x2000,%esi
     9fd:	76 05                	jbe    a04 <pipe1+0x11d>
        cc = sizeof(buf);
     9ff:	be 00 20 00 00       	mov    $0x2000,%esi
    while((n = read(fds[0], buf, cc)) > 0){
     a04:	89 74 24 08          	mov    %esi,0x8(%esp)
     a08:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
     a0f:	00 
     a10:	8b 45 e0             	mov    -0x20(%ebp),%eax
     a13:	89 04 24             	mov    %eax,(%esp)
     a16:	e8 86 2f 00 00       	call   39a1 <read>
     a1b:	85 c0                	test   %eax,%eax
     a1d:	7f cb                	jg     9ea <pipe1+0x103>
    }
    if(total != 5 * 1033){
     a1f:	81 ff 2d 14 00 00    	cmp    $0x142d,%edi
     a25:	74 1d                	je     a44 <pipe1+0x15d>
      printf(1, "pipe1 oops 3 total %d\n", total);
     a27:	89 7c 24 08          	mov    %edi,0x8(%esp)
     a2b:	c7 44 24 04 08 41 00 	movl   $0x4108,0x4(%esp)
     a32:	00 
     a33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a3a:	e8 b7 30 00 00       	call   3af6 <printf>
      exit();
     a3f:	e8 45 2f 00 00       	call   3989 <exit>
    }
    close(fds[0]);
     a44:	8b 45 e0             	mov    -0x20(%ebp),%eax
     a47:	89 04 24             	mov    %eax,(%esp)
     a4a:	e8 62 2f 00 00       	call   39b1 <close>
    wait();
     a4f:	e8 3d 2f 00 00       	call   3991 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
     a54:	c7 44 24 04 1f 41 00 	movl   $0x411f,0x4(%esp)
     a5b:	00 
     a5c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a63:	e8 8e 30 00 00       	call   3af6 <printf>
     a68:	eb 19                	jmp    a83 <pipe1+0x19c>
    printf(1, "fork() failed\n");
     a6a:	c7 44 24 04 29 41 00 	movl   $0x4129,0x4(%esp)
     a71:	00 
     a72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a79:	e8 78 30 00 00       	call   3af6 <printf>
    exit();
     a7e:	e8 06 2f 00 00       	call   3989 <exit>
}
     a83:	83 c4 2c             	add    $0x2c,%esp
     a86:	5b                   	pop    %ebx
     a87:	5e                   	pop    %esi
     a88:	5f                   	pop    %edi
     a89:	5d                   	pop    %ebp
     a8a:	c3                   	ret    

00000a8b <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     a8b:	55                   	push   %ebp
     a8c:	89 e5                	mov    %esp,%ebp
     a8e:	57                   	push   %edi
     a8f:	56                   	push   %esi
     a90:	53                   	push   %ebx
     a91:	83 ec 2c             	sub    $0x2c,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     a94:	c7 44 24 04 38 41 00 	movl   $0x4138,0x4(%esp)
     a9b:	00 
     a9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     aa3:	e8 4e 30 00 00       	call   3af6 <printf>
  pid1 = fork();
     aa8:	e8 d4 2e 00 00       	call   3981 <fork>
     aad:	89 c7                	mov    %eax,%edi
  if(pid1 == 0)
     aaf:	85 c0                	test   %eax,%eax
     ab1:	75 02                	jne    ab5 <preempt+0x2a>
     ab3:	eb fe                	jmp    ab3 <preempt+0x28>
    for(;;)
      ;

  pid2 = fork();
     ab5:	e8 c7 2e 00 00       	call   3981 <fork>
     aba:	89 c6                	mov    %eax,%esi
  if(pid2 == 0)
     abc:	85 c0                	test   %eax,%eax
     abe:	66 90                	xchg   %ax,%ax
     ac0:	75 02                	jne    ac4 <preempt+0x39>
     ac2:	eb fe                	jmp    ac2 <preempt+0x37>
    for(;;)
      ;

  pipe(pfds);
     ac4:	8d 45 e0             	lea    -0x20(%ebp),%eax
     ac7:	89 04 24             	mov    %eax,(%esp)
     aca:	e8 ca 2e 00 00       	call   3999 <pipe>
  pid3 = fork();
     acf:	e8 ad 2e 00 00       	call   3981 <fork>
     ad4:	89 c3                	mov    %eax,%ebx
  if(pid3 == 0){
     ad6:	85 c0                	test   %eax,%eax
     ad8:	75 4c                	jne    b26 <preempt+0x9b>
    close(pfds[0]);
     ada:	8b 45 e0             	mov    -0x20(%ebp),%eax
     add:	89 04 24             	mov    %eax,(%esp)
     ae0:	e8 cc 2e 00 00       	call   39b1 <close>
    if(write(pfds[1], "x", 1) != 1)
     ae5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     aec:	00 
     aed:	c7 44 24 04 fd 46 00 	movl   $0x46fd,0x4(%esp)
     af4:	00 
     af5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     af8:	89 04 24             	mov    %eax,(%esp)
     afb:	e8 a9 2e 00 00       	call   39a9 <write>
     b00:	83 f8 01             	cmp    $0x1,%eax
     b03:	74 14                	je     b19 <preempt+0x8e>
      printf(1, "preempt write error");
     b05:	c7 44 24 04 42 41 00 	movl   $0x4142,0x4(%esp)
     b0c:	00 
     b0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b14:	e8 dd 2f 00 00       	call   3af6 <printf>
    close(pfds[1]);
     b19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     b1c:	89 04 24             	mov    %eax,(%esp)
     b1f:	e8 8d 2e 00 00       	call   39b1 <close>
     b24:	eb fe                	jmp    b24 <preempt+0x99>
    for(;;)
      ;
  }

  close(pfds[1]);
     b26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     b29:	89 04 24             	mov    %eax,(%esp)
     b2c:	e8 80 2e 00 00       	call   39b1 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     b31:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
     b38:	00 
     b39:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
     b40:	00 
     b41:	8b 45 e0             	mov    -0x20(%ebp),%eax
     b44:	89 04 24             	mov    %eax,(%esp)
     b47:	e8 55 2e 00 00       	call   39a1 <read>
     b4c:	83 f8 01             	cmp    $0x1,%eax
     b4f:	74 16                	je     b67 <preempt+0xdc>
    printf(1, "preempt read error");
     b51:	c7 44 24 04 56 41 00 	movl   $0x4156,0x4(%esp)
     b58:	00 
     b59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b60:	e8 91 2f 00 00       	call   3af6 <printf>
     b65:	eb 72                	jmp    bd9 <preempt+0x14e>
    return;
  }
  close(pfds[0]);
     b67:	8b 45 e0             	mov    -0x20(%ebp),%eax
     b6a:	89 04 24             	mov    %eax,(%esp)
     b6d:	e8 3f 2e 00 00       	call   39b1 <close>
  printf(1, "kill... ");
     b72:	c7 44 24 04 69 41 00 	movl   $0x4169,0x4(%esp)
     b79:	00 
     b7a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b81:	e8 70 2f 00 00       	call   3af6 <printf>
  kill(pid1);
     b86:	89 3c 24             	mov    %edi,(%esp)
     b89:	e8 2b 2e 00 00       	call   39b9 <kill>
  kill(pid2);
     b8e:	89 34 24             	mov    %esi,(%esp)
     b91:	e8 23 2e 00 00       	call   39b9 <kill>
  kill(pid3);
     b96:	89 1c 24             	mov    %ebx,(%esp)
     b99:	e8 1b 2e 00 00       	call   39b9 <kill>
  printf(1, "wait... ");
     b9e:	c7 44 24 04 72 41 00 	movl   $0x4172,0x4(%esp)
     ba5:	00 
     ba6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     bad:	e8 44 2f 00 00       	call   3af6 <printf>
  wait();
     bb2:	e8 da 2d 00 00       	call   3991 <wait>
  wait();
     bb7:	e8 d5 2d 00 00       	call   3991 <wait>
     bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  wait();
     bc0:	e8 cc 2d 00 00       	call   3991 <wait>
  printf(1, "preempt ok\n");
     bc5:	c7 44 24 04 7b 41 00 	movl   $0x417b,0x4(%esp)
     bcc:	00 
     bcd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     bd4:	e8 1d 2f 00 00       	call   3af6 <printf>
}
     bd9:	83 c4 2c             	add    $0x2c,%esp
     bdc:	5b                   	pop    %ebx
     bdd:	5e                   	pop    %esi
     bde:	5f                   	pop    %edi
     bdf:	5d                   	pop    %ebp
     be0:	c3                   	ret    

00000be1 <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     be1:	55                   	push   %ebp
     be2:	89 e5                	mov    %esp,%ebp
     be4:	56                   	push   %esi
     be5:	53                   	push   %ebx
     be6:	83 ec 10             	sub    $0x10,%esp
  int i, pid;

  for(i = 0; i < 100; i++){
     be9:	be 00 00 00 00       	mov    $0x0,%esi
     bee:	eb 50                	jmp    c40 <exitwait+0x5f>
    pid = fork();
     bf0:	e8 8c 2d 00 00       	call   3981 <fork>
     bf5:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
     bf7:	85 c0                	test   %eax,%eax
     bf9:	79 16                	jns    c11 <exitwait+0x30>
      printf(1, "fork failed\n");
     bfb:	c7 44 24 04 e5 4c 00 	movl   $0x4ce5,0x4(%esp)
     c02:	00 
     c03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c0a:	e8 e7 2e 00 00       	call   3af6 <printf>
      return;
     c0f:	eb 48                	jmp    c59 <exitwait+0x78>
    }
    if(pid){
     c11:	85 c0                	test   %eax,%eax
     c13:	74 23                	je     c38 <exitwait+0x57>
      if(wait() != pid){
     c15:	e8 77 2d 00 00       	call   3991 <wait>
     c1a:	39 d8                	cmp    %ebx,%eax
     c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
     c20:	74 1b                	je     c3d <exitwait+0x5c>
        printf(1, "wait wrong pid\n");
     c22:	c7 44 24 04 87 41 00 	movl   $0x4187,0x4(%esp)
     c29:	00 
     c2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c31:	e8 c0 2e 00 00       	call   3af6 <printf>
        return;
     c36:	eb 21                	jmp    c59 <exitwait+0x78>
      }
    } else {
      exit();
     c38:	e8 4c 2d 00 00       	call   3989 <exit>
  for(i = 0; i < 100; i++){
     c3d:	83 c6 01             	add    $0x1,%esi
     c40:	83 fe 63             	cmp    $0x63,%esi
     c43:	7e ab                	jle    bf0 <exitwait+0xf>
    }
  }
  printf(1, "exitwait ok\n");
     c45:	c7 44 24 04 97 41 00 	movl   $0x4197,0x4(%esp)
     c4c:	00 
     c4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c54:	e8 9d 2e 00 00       	call   3af6 <printf>
}
     c59:	83 c4 10             	add    $0x10,%esp
     c5c:	5b                   	pop    %ebx
     c5d:	5e                   	pop    %esi
     c5e:	5d                   	pop    %ebp
     c5f:	c3                   	ret    

00000c60 <mem>:

void
mem(void)
{
     c60:	55                   	push   %ebp
     c61:	89 e5                	mov    %esp,%ebp
     c63:	57                   	push   %edi
     c64:	56                   	push   %esi
     c65:	53                   	push   %ebx
     c66:	83 ec 1c             	sub    $0x1c,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     c69:	c7 44 24 04 a4 41 00 	movl   $0x41a4,0x4(%esp)
     c70:	00 
     c71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c78:	e8 79 2e 00 00       	call   3af6 <printf>
  ppid = getpid();
     c7d:	e8 87 2d 00 00       	call   3a09 <getpid>
     c82:	89 c6                	mov    %eax,%esi
  if((pid = fork()) == 0){
     c84:	e8 f8 2c 00 00       	call   3981 <fork>
     c89:	85 c0                	test   %eax,%eax
     c8b:	74 0b                	je     c98 <mem+0x38>
     c8d:	8d 76 00             	lea    0x0(%esi),%esi
     c90:	eb 7f                	jmp    d11 <mem+0xb1>
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
     c92:	89 18                	mov    %ebx,(%eax)
      m1 = m2;
     c94:	89 c3                	mov    %eax,%ebx
     c96:	eb 05                	jmp    c9d <mem+0x3d>
     c98:	bb 00 00 00 00       	mov    $0x0,%ebx
    while((m2 = malloc(10001)) != 0){
     c9d:	c7 04 24 11 27 00 00 	movl   $0x2711,(%esp)
     ca4:	e8 73 30 00 00       	call   3d1c <malloc>
     ca9:	85 c0                	test   %eax,%eax
     cab:	75 e5                	jne    c92 <mem+0x32>
     cad:	eb 0c                	jmp    cbb <mem+0x5b>
    }
    while(m1){
      m2 = *(char**)m1;
     caf:	8b 3b                	mov    (%ebx),%edi
      free(m1);
     cb1:	89 1c 24             	mov    %ebx,(%esp)
     cb4:	e8 a3 2f 00 00       	call   3c5c <free>
      m1 = m2;
     cb9:	89 fb                	mov    %edi,%ebx
    while(m1){
     cbb:	85 db                	test   %ebx,%ebx
     cbd:	75 f0                	jne    caf <mem+0x4f>
    }
    m1 = malloc(1024*20);
     cbf:	c7 04 24 00 50 00 00 	movl   $0x5000,(%esp)
     cc6:	e8 51 30 00 00       	call   3d1c <malloc>
    if(m1 == 0){
     ccb:	85 c0                	test   %eax,%eax
     ccd:	75 21                	jne    cf0 <mem+0x90>
      printf(1, "couldn't allocate mem?!!\n");
     ccf:	c7 44 24 04 ae 41 00 	movl   $0x41ae,0x4(%esp)
     cd6:	00 
     cd7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     cde:	e8 13 2e 00 00       	call   3af6 <printf>
      kill(ppid);
     ce3:	89 34 24             	mov    %esi,(%esp)
     ce6:	e8 ce 2c 00 00       	call   39b9 <kill>
      exit();
     ceb:	e8 99 2c 00 00       	call   3989 <exit>
    }
    free(m1);
     cf0:	89 04 24             	mov    %eax,(%esp)
     cf3:	e8 64 2f 00 00       	call   3c5c <free>
    printf(1, "mem ok\n");
     cf8:	c7 44 24 04 c8 41 00 	movl   $0x41c8,0x4(%esp)
     cff:	00 
     d00:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d07:	e8 ea 2d 00 00       	call   3af6 <printf>
    exit();
     d0c:	e8 78 2c 00 00       	call   3989 <exit>
  } else {
    wait();
     d11:	e8 7b 2c 00 00       	call   3991 <wait>
  }
}
     d16:	83 c4 1c             	add    $0x1c,%esp
     d19:	5b                   	pop    %ebx
     d1a:	5e                   	pop    %esi
     d1b:	5f                   	pop    %edi
     d1c:	5d                   	pop    %ebp
     d1d:	c3                   	ret    

00000d1e <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     d1e:	55                   	push   %ebp
     d1f:	89 e5                	mov    %esp,%ebp
     d21:	57                   	push   %edi
     d22:	56                   	push   %esi
     d23:	53                   	push   %ebx
     d24:	83 ec 3c             	sub    $0x3c,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     d27:	c7 44 24 04 d0 41 00 	movl   $0x41d0,0x4(%esp)
     d2e:	00 
     d2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d36:	e8 bb 2d 00 00       	call   3af6 <printf>

  unlink("sharedfd");
     d3b:	c7 04 24 df 41 00 00 	movl   $0x41df,(%esp)
     d42:	e8 92 2c 00 00       	call   39d9 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     d47:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     d4e:	00 
     d4f:	c7 04 24 df 41 00 00 	movl   $0x41df,(%esp)
     d56:	e8 6e 2c 00 00       	call   39c9 <open>
     d5b:	89 c6                	mov    %eax,%esi
  if(fd < 0){
     d5d:	85 c0                	test   %eax,%eax
     d5f:	79 19                	jns    d7a <sharedfd+0x5c>
    printf(1, "fstests: cannot open sharedfd for writing");
     d61:	c7 44 24 04 a4 4e 00 	movl   $0x4ea4,0x4(%esp)
     d68:	00 
     d69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d70:	e8 81 2d 00 00       	call   3af6 <printf>
    return;
     d75:	e9 67 01 00 00       	jmp    ee1 <sharedfd+0x1c3>
  }
  pid = fork();
     d7a:	e8 02 2c 00 00       	call   3981 <fork>
     d7f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
     d82:	85 c0                	test   %eax,%eax
     d84:	75 04                	jne    d8a <sharedfd+0x6c>
     d86:	b0 63                	mov    $0x63,%al
     d88:	eb 05                	jmp    d8f <sharedfd+0x71>
     d8a:	b8 70 00 00 00       	mov    $0x70,%eax
     d8f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     d96:	00 
     d97:	89 44 24 04          	mov    %eax,0x4(%esp)
     d9b:	8d 45 de             	lea    -0x22(%ebp),%eax
     d9e:	89 04 24             	mov    %eax,(%esp)
     da1:	e8 a8 2a 00 00       	call   384e <memset>
  for(i = 0; i < 1000; i++){
     da6:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     dab:	8d 7d de             	lea    -0x22(%ebp),%edi
  for(i = 0; i < 1000; i++){
     dae:	eb 32                	jmp    de2 <sharedfd+0xc4>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     db0:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     db7:	00 
     db8:	89 7c 24 04          	mov    %edi,0x4(%esp)
     dbc:	89 34 24             	mov    %esi,(%esp)
     dbf:	e8 e5 2b 00 00       	call   39a9 <write>
     dc4:	83 f8 0a             	cmp    $0xa,%eax
     dc7:	74 16                	je     ddf <sharedfd+0xc1>
      printf(1, "fstests: write sharedfd failed\n");
     dc9:	c7 44 24 04 d0 4e 00 	movl   $0x4ed0,0x4(%esp)
     dd0:	00 
     dd1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     dd8:	e8 19 2d 00 00       	call   3af6 <printf>
      break;
     ddd:	eb 0b                	jmp    dea <sharedfd+0xcc>
  for(i = 0; i < 1000; i++){
     ddf:	83 c3 01             	add    $0x1,%ebx
     de2:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
     de8:	7e c6                	jle    db0 <sharedfd+0x92>
    }
  }
  if(pid == 0)
     dea:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
     dee:	75 05                	jne    df5 <sharedfd+0xd7>
    exit();
     df0:	e8 94 2b 00 00       	call   3989 <exit>
  else
    wait();
     df5:	e8 97 2b 00 00       	call   3991 <wait>
  close(fd);
     dfa:	89 34 24             	mov    %esi,(%esp)
     dfd:	e8 af 2b 00 00       	call   39b1 <close>
  fd = open("sharedfd", 0);
     e02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     e09:	00 
     e0a:	c7 04 24 df 41 00 00 	movl   $0x41df,(%esp)
     e11:	e8 b3 2b 00 00       	call   39c9 <open>
     e16:	89 c7                	mov    %eax,%edi
  if(fd < 0){
     e18:	85 c0                	test   %eax,%eax
     e1a:	79 3f                	jns    e5b <sharedfd+0x13d>
    printf(1, "fstests: cannot open sharedfd for reading\n");
     e1c:	c7 44 24 04 f0 4e 00 	movl   $0x4ef0,0x4(%esp)
     e23:	00 
     e24:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e2b:	e8 c6 2c 00 00       	call   3af6 <printf>
    return;
     e30:	e9 ac 00 00 00       	jmp    ee1 <sharedfd+0x1c3>
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
      if(buf[i] == 'c')
     e35:	0f b6 54 05 de       	movzbl -0x22(%ebp,%eax,1),%edx
     e3a:	80 fa 63             	cmp    $0x63,%dl
     e3d:	75 03                	jne    e42 <sharedfd+0x124>
        nc++;
     e3f:	83 c3 01             	add    $0x1,%ebx
      if(buf[i] == 'p')
     e42:	80 fa 70             	cmp    $0x70,%dl
     e45:	75 03                	jne    e4a <sharedfd+0x12c>
        np++;
     e47:	83 c6 01             	add    $0x1,%esi
    for(i = 0; i < sizeof(buf); i++){
     e4a:	83 c0 01             	add    $0x1,%eax
     e4d:	eb 05                	jmp    e54 <sharedfd+0x136>
     e4f:	b8 00 00 00 00       	mov    $0x0,%eax
     e54:	83 f8 09             	cmp    $0x9,%eax
     e57:	76 dc                	jbe    e35 <sharedfd+0x117>
     e59:	eb 0a                	jmp    e65 <sharedfd+0x147>
     e5b:	be 00 00 00 00       	mov    $0x0,%esi
     e60:	bb 00 00 00 00       	mov    $0x0,%ebx
  while((n = read(fd, buf, sizeof(buf))) > 0){
     e65:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     e6c:	00 
     e6d:	8d 45 de             	lea    -0x22(%ebp),%eax
     e70:	89 44 24 04          	mov    %eax,0x4(%esp)
     e74:	89 3c 24             	mov    %edi,(%esp)
     e77:	e8 25 2b 00 00       	call   39a1 <read>
     e7c:	85 c0                	test   %eax,%eax
     e7e:	7f cf                	jg     e4f <sharedfd+0x131>
    }
  }
  close(fd);
     e80:	89 3c 24             	mov    %edi,(%esp)
     e83:	e8 29 2b 00 00       	call   39b1 <close>
  unlink("sharedfd");
     e88:	c7 04 24 df 41 00 00 	movl   $0x41df,(%esp)
     e8f:	e8 45 2b 00 00       	call   39d9 <unlink>
  if(nc == 10000 && np == 10000){
     e94:	81 fb 10 27 00 00    	cmp    $0x2710,%ebx
     e9a:	0f 94 c2             	sete   %dl
     e9d:	81 fe 10 27 00 00    	cmp    $0x2710,%esi
     ea3:	0f 94 c0             	sete   %al
     ea6:	84 c2                	test   %al,%dl
     ea8:	74 16                	je     ec0 <sharedfd+0x1a2>
    printf(1, "sharedfd ok\n");
     eaa:	c7 44 24 04 e8 41 00 	movl   $0x41e8,0x4(%esp)
     eb1:	00 
     eb2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     eb9:	e8 38 2c 00 00       	call   3af6 <printf>
     ebe:	eb 21                	jmp    ee1 <sharedfd+0x1c3>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
     ec0:	89 74 24 0c          	mov    %esi,0xc(%esp)
     ec4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     ec8:	c7 44 24 04 f5 41 00 	movl   $0x41f5,0x4(%esp)
     ecf:	00 
     ed0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ed7:	e8 1a 2c 00 00       	call   3af6 <printf>
    exit();
     edc:	e8 a8 2a 00 00       	call   3989 <exit>
  }
}
     ee1:	83 c4 3c             	add    $0x3c,%esp
     ee4:	5b                   	pop    %ebx
     ee5:	5e                   	pop    %esi
     ee6:	5f                   	pop    %edi
     ee7:	5d                   	pop    %ebp
     ee8:	c3                   	ret    

00000ee9 <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
     ee9:	55                   	push   %ebp
     eea:	89 e5                	mov    %esp,%ebp
     eec:	57                   	push   %edi
     eed:	56                   	push   %esi
     eee:	53                   	push   %ebx
     eef:	83 ec 3c             	sub    $0x3c,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
     ef2:	c7 45 d8 0a 42 00 00 	movl   $0x420a,-0x28(%ebp)
     ef9:	c7 45 dc 53 43 00 00 	movl   $0x4353,-0x24(%ebp)
     f00:	c7 45 e0 57 43 00 00 	movl   $0x4357,-0x20(%ebp)
     f07:	c7 45 e4 0d 42 00 00 	movl   $0x420d,-0x1c(%ebp)
  char *fname;

  printf(1, "fourfiles test\n");
     f0e:	c7 44 24 04 10 42 00 	movl   $0x4210,0x4(%esp)
     f15:	00 
     f16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f1d:	e8 d4 2b 00 00       	call   3af6 <printf>

  for(pi = 0; pi < 4; pi++){
     f22:	bb 00 00 00 00       	mov    $0x0,%ebx
     f27:	e9 d3 00 00 00       	jmp    fff <fourfiles+0x116>
    fname = names[pi];
     f2c:	8b 74 9d d8          	mov    -0x28(%ebp,%ebx,4),%esi
    unlink(fname);
     f30:	89 34 24             	mov    %esi,(%esp)
     f33:	e8 a1 2a 00 00       	call   39d9 <unlink>

    pid = fork();
     f38:	e8 44 2a 00 00       	call   3981 <fork>
    if(pid < 0){
     f3d:	85 c0                	test   %eax,%eax
     f3f:	79 19                	jns    f5a <fourfiles+0x71>
      printf(1, "fork failed\n");
     f41:	c7 44 24 04 e5 4c 00 	movl   $0x4ce5,0x4(%esp)
     f48:	00 
     f49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f50:	e8 a1 2b 00 00       	call   3af6 <printf>
      exit();
     f55:	e8 2f 2a 00 00       	call   3989 <exit>
    }

    if(pid == 0){
     f5a:	85 c0                	test   %eax,%eax
     f5c:	0f 85 9a 00 00 00    	jne    ffc <fourfiles+0x113>
      fd = open(fname, O_CREATE | O_RDWR);
     f62:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     f69:	00 
     f6a:	89 34 24             	mov    %esi,(%esp)
     f6d:	e8 57 2a 00 00       	call   39c9 <open>
     f72:	89 c6                	mov    %eax,%esi
      if(fd < 0){
     f74:	85 c0                	test   %eax,%eax
     f76:	79 19                	jns    f91 <fourfiles+0xa8>
        printf(1, "create failed\n");
     f78:	c7 44 24 04 ab 44 00 	movl   $0x44ab,0x4(%esp)
     f7f:	00 
     f80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f87:	e8 6a 2b 00 00       	call   3af6 <printf>
        exit();
     f8c:	e8 f8 29 00 00       	call   3989 <exit>
      }

      memset(buf, '0'+pi, 512);
     f91:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     f98:	00 
     f99:	83 c3 30             	add    $0x30,%ebx
     f9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     fa0:	c7 04 24 a0 7d 00 00 	movl   $0x7da0,(%esp)
     fa7:	e8 a2 28 00 00       	call   384e <memset>
      for(i = 0; i < 12; i++){
     fac:	bb 00 00 00 00       	mov    $0x0,%ebx
     fb1:	eb 3f                	jmp    ff2 <fourfiles+0x109>
        if((n = write(fd, buf, 500)) != 500){
     fb3:	c7 44 24 08 f4 01 00 	movl   $0x1f4,0x8(%esp)
     fba:	00 
     fbb:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
     fc2:	00 
     fc3:	89 34 24             	mov    %esi,(%esp)
     fc6:	e8 de 29 00 00       	call   39a9 <write>
     fcb:	3d f4 01 00 00       	cmp    $0x1f4,%eax
     fd0:	74 1d                	je     fef <fourfiles+0x106>
          printf(1, "write failed %d\n", n);
     fd2:	89 44 24 08          	mov    %eax,0x8(%esp)
     fd6:	c7 44 24 04 20 42 00 	movl   $0x4220,0x4(%esp)
     fdd:	00 
     fde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fe5:	e8 0c 2b 00 00       	call   3af6 <printf>
          exit();
     fea:	e8 9a 29 00 00       	call   3989 <exit>
      for(i = 0; i < 12; i++){
     fef:	83 c3 01             	add    $0x1,%ebx
     ff2:	83 fb 0b             	cmp    $0xb,%ebx
     ff5:	7e bc                	jle    fb3 <fourfiles+0xca>
        }
      }
      exit();
     ff7:	e8 8d 29 00 00       	call   3989 <exit>
  for(pi = 0; pi < 4; pi++){
     ffc:	83 c3 01             	add    $0x1,%ebx
     fff:	83 fb 03             	cmp    $0x3,%ebx
    1002:	0f 8e 24 ff ff ff    	jle    f2c <fourfiles+0x43>
    1008:	bb 00 00 00 00       	mov    $0x0,%ebx
    100d:	eb 08                	jmp    1017 <fourfiles+0x12e>
    }
  }

  for(pi = 0; pi < 4; pi++){
    wait();
    100f:	e8 7d 29 00 00       	call   3991 <wait>
  for(pi = 0; pi < 4; pi++){
    1014:	83 c3 01             	add    $0x1,%ebx
    1017:	83 fb 03             	cmp    $0x3,%ebx
    101a:	7e f3                	jle    100f <fourfiles+0x126>
    101c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    1023:	e9 b2 00 00 00       	jmp    10da <fourfiles+0x1f1>
  }

  for(i = 0; i < 2; i++){
    fname = names[i];
    1028:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
    102b:	8b 44 9d d8          	mov    -0x28(%ebp,%ebx,4),%eax
    102f:	89 45 d0             	mov    %eax,-0x30(%ebp)
    fd = open(fname, 0);
    1032:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1039:	00 
    103a:	89 04 24             	mov    %eax,(%esp)
    103d:	e8 87 29 00 00       	call   39c9 <open>
    1042:	89 c6                	mov    %eax,%esi
    total = 0;
    1044:	bf 00 00 00 00       	mov    $0x0,%edi
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
        if(buf[j] != '0'+i){
    1049:	8d 5b 30             	lea    0x30(%ebx),%ebx
    while((n = read(fd, buf, sizeof(buf))) > 0){
    104c:	eb 34                	jmp    1082 <fourfiles+0x199>
        if(buf[j] != '0'+i){
    104e:	0f be 8a a0 7d 00 00 	movsbl 0x7da0(%edx),%ecx
    1055:	39 d9                	cmp    %ebx,%ecx
    1057:	74 19                	je     1072 <fourfiles+0x189>
          printf(1, "wrong char\n");
    1059:	c7 44 24 04 31 42 00 	movl   $0x4231,0x4(%esp)
    1060:	00 
    1061:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1068:	e8 89 2a 00 00       	call   3af6 <printf>
          exit();
    106d:	e8 17 29 00 00       	call   3989 <exit>
      for(j = 0; j < n; j++){
    1072:	83 c2 01             	add    $0x1,%edx
    1075:	eb 05                	jmp    107c <fourfiles+0x193>
    1077:	ba 00 00 00 00       	mov    $0x0,%edx
    107c:	39 c2                	cmp    %eax,%edx
    107e:	7c ce                	jl     104e <fourfiles+0x165>
        }
      }
      total += n;
    1080:	01 c7                	add    %eax,%edi
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1082:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1089:	00 
    108a:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
    1091:	00 
    1092:	89 34 24             	mov    %esi,(%esp)
    1095:	e8 07 29 00 00       	call   39a1 <read>
    109a:	85 c0                	test   %eax,%eax
    109c:	7f d9                	jg     1077 <fourfiles+0x18e>
    }
    close(fd);
    109e:	89 34 24             	mov    %esi,(%esp)
    10a1:	e8 0b 29 00 00       	call   39b1 <close>
    if(total != 12*500){
    10a6:	81 ff 70 17 00 00    	cmp    $0x1770,%edi
    10ac:	74 1d                	je     10cb <fourfiles+0x1e2>
      printf(1, "wrong length %d\n", total);
    10ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
    10b2:	c7 44 24 04 3d 42 00 	movl   $0x423d,0x4(%esp)
    10b9:	00 
    10ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10c1:	e8 30 2a 00 00       	call   3af6 <printf>
      exit();
    10c6:	e8 be 28 00 00       	call   3989 <exit>
    }
    unlink(fname);
    10cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
    10ce:	89 04 24             	mov    %eax,(%esp)
    10d1:	e8 03 29 00 00       	call   39d9 <unlink>
  for(i = 0; i < 2; i++){
    10d6:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
    10da:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
    10de:	0f 8e 44 ff ff ff    	jle    1028 <fourfiles+0x13f>
  }

  printf(1, "fourfiles ok\n");
    10e4:	c7 44 24 04 4e 42 00 	movl   $0x424e,0x4(%esp)
    10eb:	00 
    10ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10f3:	e8 fe 29 00 00       	call   3af6 <printf>
}
    10f8:	83 c4 3c             	add    $0x3c,%esp
    10fb:	5b                   	pop    %ebx
    10fc:	5e                   	pop    %esi
    10fd:	5f                   	pop    %edi
    10fe:	5d                   	pop    %ebp
    10ff:	c3                   	ret    

00001100 <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(void)
{
    1100:	55                   	push   %ebp
    1101:	89 e5                	mov    %esp,%ebp
    1103:	57                   	push   %edi
    1104:	56                   	push   %esi
    1105:	53                   	push   %ebx
    1106:	83 ec 3c             	sub    $0x3c,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");
    1109:	c7 44 24 04 5c 42 00 	movl   $0x425c,0x4(%esp)
    1110:	00 
    1111:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1118:	e8 d9 29 00 00       	call   3af6 <printf>

  for(pi = 0; pi < 4; pi++){
    111d:	bb 00 00 00 00       	mov    $0x0,%ebx
    1122:	e9 c6 00 00 00       	jmp    11ed <createdelete+0xed>
    pid = fork();
    1127:	e8 55 28 00 00       	call   3981 <fork>
    if(pid < 0){
    112c:	85 c0                	test   %eax,%eax
    112e:	79 19                	jns    1149 <createdelete+0x49>
      printf(1, "fork failed\n");
    1130:	c7 44 24 04 e5 4c 00 	movl   $0x4ce5,0x4(%esp)
    1137:	00 
    1138:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    113f:	e8 b2 29 00 00       	call   3af6 <printf>
      exit();
    1144:	e8 40 28 00 00       	call   3989 <exit>
    }

    if(pid == 0){
    1149:	85 c0                	test   %eax,%eax
    114b:	0f 85 99 00 00 00    	jne    11ea <createdelete+0xea>
      name[0] = 'p' + pi;
    1151:	83 c3 70             	add    $0x70,%ebx
    1154:	88 5d c8             	mov    %bl,-0x38(%ebp)
      name[2] = '\0';
    1157:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
      for(i = 0; i < N; i++){
    115b:	bb 00 00 00 00       	mov    $0x0,%ebx
        name[1] = '0' + i;
        fd = open(name, O_CREATE | O_RDWR);
    1160:	8d 75 c8             	lea    -0x38(%ebp),%esi
      for(i = 0; i < N; i++){
    1163:	eb 7b                	jmp    11e0 <createdelete+0xe0>
        name[1] = '0' + i;
    1165:	8d 43 30             	lea    0x30(%ebx),%eax
    1168:	88 45 c9             	mov    %al,-0x37(%ebp)
        fd = open(name, O_CREATE | O_RDWR);
    116b:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1172:	00 
    1173:	89 34 24             	mov    %esi,(%esp)
    1176:	e8 4e 28 00 00       	call   39c9 <open>
        if(fd < 0){
    117b:	85 c0                	test   %eax,%eax
    117d:	79 19                	jns    1198 <createdelete+0x98>
          printf(1, "create failed\n");
    117f:	c7 44 24 04 ab 44 00 	movl   $0x44ab,0x4(%esp)
    1186:	00 
    1187:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    118e:	e8 63 29 00 00       	call   3af6 <printf>
          exit();
    1193:	e8 f1 27 00 00       	call   3989 <exit>
        }
        close(fd);
    1198:	89 04 24             	mov    %eax,(%esp)
    119b:	e8 11 28 00 00       	call   39b1 <close>
        if(i > 0 && (i % 2 ) == 0){
    11a0:	85 db                	test   %ebx,%ebx
    11a2:	7e 39                	jle    11dd <createdelete+0xdd>
    11a4:	f6 c3 01             	test   $0x1,%bl
    11a7:	75 34                	jne    11dd <createdelete+0xdd>
          name[1] = '0' + (i / 2);
    11a9:	89 d8                	mov    %ebx,%eax
    11ab:	c1 e8 1f             	shr    $0x1f,%eax
    11ae:	01 d8                	add    %ebx,%eax
    11b0:	d1 f8                	sar    %eax
    11b2:	83 c0 30             	add    $0x30,%eax
    11b5:	88 45 c9             	mov    %al,-0x37(%ebp)
          if(unlink(name) < 0){
    11b8:	89 34 24             	mov    %esi,(%esp)
    11bb:	e8 19 28 00 00       	call   39d9 <unlink>
    11c0:	85 c0                	test   %eax,%eax
    11c2:	79 19                	jns    11dd <createdelete+0xdd>
            printf(1, "unlink failed\n");
    11c4:	c7 44 24 04 5d 3e 00 	movl   $0x3e5d,0x4(%esp)
    11cb:	00 
    11cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11d3:	e8 1e 29 00 00       	call   3af6 <printf>
            exit();
    11d8:	e8 ac 27 00 00       	call   3989 <exit>
      for(i = 0; i < N; i++){
    11dd:	83 c3 01             	add    $0x1,%ebx
    11e0:	83 fb 13             	cmp    $0x13,%ebx
    11e3:	7e 80                	jle    1165 <createdelete+0x65>
          }
        }
      }
      exit();
    11e5:	e8 9f 27 00 00       	call   3989 <exit>
  for(pi = 0; pi < 4; pi++){
    11ea:	83 c3 01             	add    $0x1,%ebx
    11ed:	83 fb 03             	cmp    $0x3,%ebx
    11f0:	0f 8e 31 ff ff ff    	jle    1127 <createdelete+0x27>
    11f6:	bb 00 00 00 00       	mov    $0x0,%ebx
    11fb:	eb 08                	jmp    1205 <createdelete+0x105>
    }
  }

  for(pi = 0; pi < 4; pi++){
    wait();
    11fd:	e8 8f 27 00 00       	call   3991 <wait>
  for(pi = 0; pi < 4; pi++){
    1202:	83 c3 01             	add    $0x1,%ebx
    1205:	83 fb 03             	cmp    $0x3,%ebx
    1208:	7e f3                	jle    11fd <createdelete+0xfd>
  }

  name[0] = name[1] = name[2] = 0;
    120a:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
    120e:	c6 45 c9 00          	movb   $0x0,-0x37(%ebp)
    1212:	c6 45 c8 00          	movb   $0x0,-0x38(%ebp)
  for(i = 0; i < N; i++){
    1216:	be 00 00 00 00       	mov    $0x0,%esi
    for(pi = 0; pi < 4; pi++){
      name[0] = 'p' + pi;
      name[1] = '0' + i;
      fd = open(name, 0);
    121b:	8d 7d c8             	lea    -0x38(%ebp),%edi
  for(i = 0; i < N; i++){
    121e:	e9 a4 00 00 00       	jmp    12c7 <createdelete+0x1c7>
      name[0] = 'p' + pi;
    1223:	8d 43 70             	lea    0x70(%ebx),%eax
    1226:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    1229:	0f b6 45 c7          	movzbl -0x39(%ebp),%eax
    122d:	88 45 c9             	mov    %al,-0x37(%ebp)
      fd = open(name, 0);
    1230:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1237:	00 
    1238:	89 3c 24             	mov    %edi,(%esp)
    123b:	e8 89 27 00 00       	call   39c9 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1240:	85 f6                	test   %esi,%esi
    1242:	0f 94 c1             	sete   %cl
    1245:	83 fe 09             	cmp    $0x9,%esi
    1248:	0f 9f c2             	setg   %dl
    124b:	08 d1                	or     %dl,%cl
    124d:	74 24                	je     1273 <createdelete+0x173>
    124f:	85 c0                	test   %eax,%eax
    1251:	79 20                	jns    1273 <createdelete+0x173>
        printf(1, "oops createdelete %s didn't exist\n", name);
    1253:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1256:	89 44 24 08          	mov    %eax,0x8(%esp)
    125a:	c7 44 24 04 1c 4f 00 	movl   $0x4f1c,0x4(%esp)
    1261:	00 
    1262:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1269:	e8 88 28 00 00       	call   3af6 <printf>
        exit();
    126e:	e8 16 27 00 00       	call   3989 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1273:	8d 56 ff             	lea    -0x1(%esi),%edx
    1276:	83 fa 08             	cmp    $0x8,%edx
    1279:	77 24                	ja     129f <createdelete+0x19f>
    127b:	85 c0                	test   %eax,%eax
    127d:	78 20                	js     129f <createdelete+0x19f>
        printf(1, "oops createdelete %s did exist\n", name);
    127f:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1282:	89 44 24 08          	mov    %eax,0x8(%esp)
    1286:	c7 44 24 04 40 4f 00 	movl   $0x4f40,0x4(%esp)
    128d:	00 
    128e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1295:	e8 5c 28 00 00       	call   3af6 <printf>
        exit();
    129a:	e8 ea 26 00 00       	call   3989 <exit>
      }
      if(fd >= 0)
    129f:	85 c0                	test   %eax,%eax
    12a1:	78 08                	js     12ab <createdelete+0x1ab>
        close(fd);
    12a3:	89 04 24             	mov    %eax,(%esp)
    12a6:	e8 06 27 00 00       	call   39b1 <close>
    for(pi = 0; pi < 4; pi++){
    12ab:	83 c3 01             	add    $0x1,%ebx
    12ae:	eb 0b                	jmp    12bb <createdelete+0x1bb>
    12b0:	bb 00 00 00 00       	mov    $0x0,%ebx
      name[1] = '0' + i;
    12b5:	8d 46 30             	lea    0x30(%esi),%eax
    12b8:	88 45 c7             	mov    %al,-0x39(%ebp)
    for(pi = 0; pi < 4; pi++){
    12bb:	83 fb 03             	cmp    $0x3,%ebx
    12be:	0f 8e 5f ff ff ff    	jle    1223 <createdelete+0x123>
  for(i = 0; i < N; i++){
    12c4:	83 c6 01             	add    $0x1,%esi
    12c7:	83 fe 13             	cmp    $0x13,%esi
    12ca:	7e e4                	jle    12b0 <createdelete+0x1b0>
    12cc:	bf 00 00 00 00       	mov    $0x0,%edi

  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
      name[0] = 'p' + i;
      name[1] = '0' + i;
      unlink(name);
    12d1:	8d 75 c8             	lea    -0x38(%ebp),%esi
    12d4:	eb 34                	jmp    130a <createdelete+0x20a>
      name[0] = 'p' + i;
    12d6:	0f b6 45 c7          	movzbl -0x39(%ebp),%eax
    12da:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    12dd:	0f b6 45 c6          	movzbl -0x3a(%ebp),%eax
    12e1:	88 45 c9             	mov    %al,-0x37(%ebp)
      unlink(name);
    12e4:	89 34 24             	mov    %esi,(%esp)
    12e7:	e8 ed 26 00 00       	call   39d9 <unlink>
    for(pi = 0; pi < 4; pi++){
    12ec:	83 c3 01             	add    $0x1,%ebx
    12ef:	eb 11                	jmp    1302 <createdelete+0x202>
    12f1:	bb 00 00 00 00       	mov    $0x0,%ebx
      name[0] = 'p' + i;
    12f6:	8d 47 70             	lea    0x70(%edi),%eax
    12f9:	88 45 c7             	mov    %al,-0x39(%ebp)
      name[1] = '0' + i;
    12fc:	8d 47 30             	lea    0x30(%edi),%eax
    12ff:	88 45 c6             	mov    %al,-0x3a(%ebp)
    for(pi = 0; pi < 4; pi++){
    1302:	83 fb 03             	cmp    $0x3,%ebx
    1305:	7e cf                	jle    12d6 <createdelete+0x1d6>
  for(i = 0; i < N; i++){
    1307:	83 c7 01             	add    $0x1,%edi
    130a:	83 ff 13             	cmp    $0x13,%edi
    130d:	7e e2                	jle    12f1 <createdelete+0x1f1>
    }
  }

  printf(1, "createdelete ok\n");
    130f:	c7 44 24 04 6f 42 00 	movl   $0x426f,0x4(%esp)
    1316:	00 
    1317:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    131e:	e8 d3 27 00 00       	call   3af6 <printf>
}
    1323:	83 c4 3c             	add    $0x3c,%esp
    1326:	5b                   	pop    %ebx
    1327:	5e                   	pop    %esi
    1328:	5f                   	pop    %edi
    1329:	5d                   	pop    %ebp
    132a:	c3                   	ret    

0000132b <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    132b:	55                   	push   %ebp
    132c:	89 e5                	mov    %esp,%ebp
    132e:	56                   	push   %esi
    132f:	53                   	push   %ebx
    1330:	83 ec 10             	sub    $0x10,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    1333:	c7 44 24 04 80 42 00 	movl   $0x4280,0x4(%esp)
    133a:	00 
    133b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1342:	e8 af 27 00 00       	call   3af6 <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    1347:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    134e:	00 
    134f:	c7 04 24 91 42 00 00 	movl   $0x4291,(%esp)
    1356:	e8 6e 26 00 00       	call   39c9 <open>
    135b:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    135d:	85 c0                	test   %eax,%eax
    135f:	79 19                	jns    137a <unlinkread+0x4f>
    printf(1, "create unlinkread failed\n");
    1361:	c7 44 24 04 9c 42 00 	movl   $0x429c,0x4(%esp)
    1368:	00 
    1369:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1370:	e8 81 27 00 00       	call   3af6 <printf>
    exit();
    1375:	e8 0f 26 00 00       	call   3989 <exit>
  }
  write(fd, "hello", 5);
    137a:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    1381:	00 
    1382:	c7 44 24 04 b6 42 00 	movl   $0x42b6,0x4(%esp)
    1389:	00 
    138a:	89 04 24             	mov    %eax,(%esp)
    138d:	e8 17 26 00 00       	call   39a9 <write>
  close(fd);
    1392:	89 1c 24             	mov    %ebx,(%esp)
    1395:	e8 17 26 00 00       	call   39b1 <close>

  fd = open("unlinkread", O_RDWR);
    139a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    13a1:	00 
    13a2:	c7 04 24 91 42 00 00 	movl   $0x4291,(%esp)
    13a9:	e8 1b 26 00 00       	call   39c9 <open>
    13ae:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    13b0:	85 c0                	test   %eax,%eax
    13b2:	79 19                	jns    13cd <unlinkread+0xa2>
    printf(1, "open unlinkread failed\n");
    13b4:	c7 44 24 04 bc 42 00 	movl   $0x42bc,0x4(%esp)
    13bb:	00 
    13bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13c3:	e8 2e 27 00 00       	call   3af6 <printf>
    exit();
    13c8:	e8 bc 25 00 00       	call   3989 <exit>
  }
  if(unlink("unlinkread") != 0){
    13cd:	c7 04 24 91 42 00 00 	movl   $0x4291,(%esp)
    13d4:	e8 00 26 00 00       	call   39d9 <unlink>
    13d9:	85 c0                	test   %eax,%eax
    13db:	74 19                	je     13f6 <unlinkread+0xcb>
    printf(1, "unlink unlinkread failed\n");
    13dd:	c7 44 24 04 d4 42 00 	movl   $0x42d4,0x4(%esp)
    13e4:	00 
    13e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13ec:	e8 05 27 00 00       	call   3af6 <printf>
    exit();
    13f1:	e8 93 25 00 00       	call   3989 <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    13f6:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    13fd:	00 
    13fe:	c7 04 24 91 42 00 00 	movl   $0x4291,(%esp)
    1405:	e8 bf 25 00 00       	call   39c9 <open>
    140a:	89 c6                	mov    %eax,%esi
  write(fd1, "yyy", 3);
    140c:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
    1413:	00 
    1414:	c7 44 24 04 ee 42 00 	movl   $0x42ee,0x4(%esp)
    141b:	00 
    141c:	89 04 24             	mov    %eax,(%esp)
    141f:	e8 85 25 00 00       	call   39a9 <write>
  close(fd1);
    1424:	89 34 24             	mov    %esi,(%esp)
    1427:	e8 85 25 00 00       	call   39b1 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    142c:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1433:	00 
    1434:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
    143b:	00 
    143c:	89 1c 24             	mov    %ebx,(%esp)
    143f:	e8 5d 25 00 00       	call   39a1 <read>
    1444:	83 f8 05             	cmp    $0x5,%eax
    1447:	74 19                	je     1462 <unlinkread+0x137>
    printf(1, "unlinkread read failed");
    1449:	c7 44 24 04 f2 42 00 	movl   $0x42f2,0x4(%esp)
    1450:	00 
    1451:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1458:	e8 99 26 00 00       	call   3af6 <printf>
    exit();
    145d:	e8 27 25 00 00       	call   3989 <exit>
  }
  if(buf[0] != 'h'){
    1462:	80 3d a0 7d 00 00 68 	cmpb   $0x68,0x7da0
    1469:	74 19                	je     1484 <unlinkread+0x159>
    printf(1, "unlinkread wrong data\n");
    146b:	c7 44 24 04 09 43 00 	movl   $0x4309,0x4(%esp)
    1472:	00 
    1473:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    147a:	e8 77 26 00 00       	call   3af6 <printf>
    exit();
    147f:	e8 05 25 00 00       	call   3989 <exit>
  }
  if(write(fd, buf, 10) != 10){
    1484:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    148b:	00 
    148c:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
    1493:	00 
    1494:	89 1c 24             	mov    %ebx,(%esp)
    1497:	e8 0d 25 00 00       	call   39a9 <write>
    149c:	83 f8 0a             	cmp    $0xa,%eax
    149f:	74 19                	je     14ba <unlinkread+0x18f>
    printf(1, "unlinkread write failed\n");
    14a1:	c7 44 24 04 20 43 00 	movl   $0x4320,0x4(%esp)
    14a8:	00 
    14a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14b0:	e8 41 26 00 00       	call   3af6 <printf>
    exit();
    14b5:	e8 cf 24 00 00       	call   3989 <exit>
  }
  close(fd);
    14ba:	89 1c 24             	mov    %ebx,(%esp)
    14bd:	e8 ef 24 00 00       	call   39b1 <close>
  unlink("unlinkread");
    14c2:	c7 04 24 91 42 00 00 	movl   $0x4291,(%esp)
    14c9:	e8 0b 25 00 00       	call   39d9 <unlink>
  printf(1, "unlinkread ok\n");
    14ce:	c7 44 24 04 39 43 00 	movl   $0x4339,0x4(%esp)
    14d5:	00 
    14d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14dd:	e8 14 26 00 00       	call   3af6 <printf>
}
    14e2:	83 c4 10             	add    $0x10,%esp
    14e5:	5b                   	pop    %ebx
    14e6:	5e                   	pop    %esi
    14e7:	5d                   	pop    %ebp
    14e8:	c3                   	ret    

000014e9 <linktest>:

void
linktest(void)
{
    14e9:	55                   	push   %ebp
    14ea:	89 e5                	mov    %esp,%ebp
    14ec:	53                   	push   %ebx
    14ed:	83 ec 14             	sub    $0x14,%esp
  int fd;

  printf(1, "linktest\n");
    14f0:	c7 44 24 04 48 43 00 	movl   $0x4348,0x4(%esp)
    14f7:	00 
    14f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14ff:	e8 f2 25 00 00       	call   3af6 <printf>

  unlink("lf1");
    1504:	c7 04 24 52 43 00 00 	movl   $0x4352,(%esp)
    150b:	e8 c9 24 00 00       	call   39d9 <unlink>
  unlink("lf2");
    1510:	c7 04 24 56 43 00 00 	movl   $0x4356,(%esp)
    1517:	e8 bd 24 00 00       	call   39d9 <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    151c:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1523:	00 
    1524:	c7 04 24 52 43 00 00 	movl   $0x4352,(%esp)
    152b:	e8 99 24 00 00       	call   39c9 <open>
    1530:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1532:	85 c0                	test   %eax,%eax
    1534:	79 19                	jns    154f <linktest+0x66>
    printf(1, "create lf1 failed\n");
    1536:	c7 44 24 04 5a 43 00 	movl   $0x435a,0x4(%esp)
    153d:	00 
    153e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1545:	e8 ac 25 00 00       	call   3af6 <printf>
    exit();
    154a:	e8 3a 24 00 00       	call   3989 <exit>
  }
  if(write(fd, "hello", 5) != 5){
    154f:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    1556:	00 
    1557:	c7 44 24 04 b6 42 00 	movl   $0x42b6,0x4(%esp)
    155e:	00 
    155f:	89 04 24             	mov    %eax,(%esp)
    1562:	e8 42 24 00 00       	call   39a9 <write>
    1567:	83 f8 05             	cmp    $0x5,%eax
    156a:	74 19                	je     1585 <linktest+0x9c>
    printf(1, "write lf1 failed\n");
    156c:	c7 44 24 04 6d 43 00 	movl   $0x436d,0x4(%esp)
    1573:	00 
    1574:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    157b:	e8 76 25 00 00       	call   3af6 <printf>
    exit();
    1580:	e8 04 24 00 00       	call   3989 <exit>
  }
  close(fd);
    1585:	89 1c 24             	mov    %ebx,(%esp)
    1588:	e8 24 24 00 00       	call   39b1 <close>

  if(link("lf1", "lf2") < 0){
    158d:	c7 44 24 04 56 43 00 	movl   $0x4356,0x4(%esp)
    1594:	00 
    1595:	c7 04 24 52 43 00 00 	movl   $0x4352,(%esp)
    159c:	e8 48 24 00 00       	call   39e9 <link>
    15a1:	85 c0                	test   %eax,%eax
    15a3:	79 19                	jns    15be <linktest+0xd5>
    printf(1, "link lf1 lf2 failed\n");
    15a5:	c7 44 24 04 7f 43 00 	movl   $0x437f,0x4(%esp)
    15ac:	00 
    15ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15b4:	e8 3d 25 00 00       	call   3af6 <printf>
    exit();
    15b9:	e8 cb 23 00 00       	call   3989 <exit>
  }
  unlink("lf1");
    15be:	c7 04 24 52 43 00 00 	movl   $0x4352,(%esp)
    15c5:	e8 0f 24 00 00       	call   39d9 <unlink>

  if(open("lf1", 0) >= 0){
    15ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    15d1:	00 
    15d2:	c7 04 24 52 43 00 00 	movl   $0x4352,(%esp)
    15d9:	e8 eb 23 00 00       	call   39c9 <open>
    15de:	85 c0                	test   %eax,%eax
    15e0:	78 19                	js     15fb <linktest+0x112>
    printf(1, "unlinked lf1 but it is still there!\n");
    15e2:	c7 44 24 04 60 4f 00 	movl   $0x4f60,0x4(%esp)
    15e9:	00 
    15ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15f1:	e8 00 25 00 00       	call   3af6 <printf>
    exit();
    15f6:	e8 8e 23 00 00       	call   3989 <exit>
  }

  fd = open("lf2", 0);
    15fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1602:	00 
    1603:	c7 04 24 56 43 00 00 	movl   $0x4356,(%esp)
    160a:	e8 ba 23 00 00       	call   39c9 <open>
    160f:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1611:	85 c0                	test   %eax,%eax
    1613:	79 19                	jns    162e <linktest+0x145>
    printf(1, "open lf2 failed\n");
    1615:	c7 44 24 04 94 43 00 	movl   $0x4394,0x4(%esp)
    161c:	00 
    161d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1624:	e8 cd 24 00 00       	call   3af6 <printf>
    exit();
    1629:	e8 5b 23 00 00       	call   3989 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    162e:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1635:	00 
    1636:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
    163d:	00 
    163e:	89 04 24             	mov    %eax,(%esp)
    1641:	e8 5b 23 00 00       	call   39a1 <read>
    1646:	83 f8 05             	cmp    $0x5,%eax
    1649:	74 19                	je     1664 <linktest+0x17b>
    printf(1, "read lf2 failed\n");
    164b:	c7 44 24 04 a5 43 00 	movl   $0x43a5,0x4(%esp)
    1652:	00 
    1653:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    165a:	e8 97 24 00 00       	call   3af6 <printf>
    exit();
    165f:	e8 25 23 00 00       	call   3989 <exit>
  }
  close(fd);
    1664:	89 1c 24             	mov    %ebx,(%esp)
    1667:	e8 45 23 00 00       	call   39b1 <close>

  if(link("lf2", "lf2") >= 0){
    166c:	c7 44 24 04 56 43 00 	movl   $0x4356,0x4(%esp)
    1673:	00 
    1674:	c7 04 24 56 43 00 00 	movl   $0x4356,(%esp)
    167b:	e8 69 23 00 00       	call   39e9 <link>
    1680:	85 c0                	test   %eax,%eax
    1682:	78 19                	js     169d <linktest+0x1b4>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    1684:	c7 44 24 04 b6 43 00 	movl   $0x43b6,0x4(%esp)
    168b:	00 
    168c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1693:	e8 5e 24 00 00       	call   3af6 <printf>
    exit();
    1698:	e8 ec 22 00 00       	call   3989 <exit>
  }

  unlink("lf2");
    169d:	c7 04 24 56 43 00 00 	movl   $0x4356,(%esp)
    16a4:	e8 30 23 00 00       	call   39d9 <unlink>
  if(link("lf2", "lf1") >= 0){
    16a9:	c7 44 24 04 52 43 00 	movl   $0x4352,0x4(%esp)
    16b0:	00 
    16b1:	c7 04 24 56 43 00 00 	movl   $0x4356,(%esp)
    16b8:	e8 2c 23 00 00       	call   39e9 <link>
    16bd:	85 c0                	test   %eax,%eax
    16bf:	78 19                	js     16da <linktest+0x1f1>
    printf(1, "link non-existant succeeded! oops\n");
    16c1:	c7 44 24 04 88 4f 00 	movl   $0x4f88,0x4(%esp)
    16c8:	00 
    16c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16d0:	e8 21 24 00 00       	call   3af6 <printf>
    exit();
    16d5:	e8 af 22 00 00       	call   3989 <exit>
  }

  if(link(".", "lf1") >= 0){
    16da:	c7 44 24 04 52 43 00 	movl   $0x4352,0x4(%esp)
    16e1:	00 
    16e2:	c7 04 24 1a 46 00 00 	movl   $0x461a,(%esp)
    16e9:	e8 fb 22 00 00       	call   39e9 <link>
    16ee:	85 c0                	test   %eax,%eax
    16f0:	78 19                	js     170b <linktest+0x222>
    printf(1, "link . lf1 succeeded! oops\n");
    16f2:	c7 44 24 04 d4 43 00 	movl   $0x43d4,0x4(%esp)
    16f9:	00 
    16fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1701:	e8 f0 23 00 00       	call   3af6 <printf>
    exit();
    1706:	e8 7e 22 00 00       	call   3989 <exit>
  }

  printf(1, "linktest ok\n");
    170b:	c7 44 24 04 f0 43 00 	movl   $0x43f0,0x4(%esp)
    1712:	00 
    1713:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    171a:	e8 d7 23 00 00       	call   3af6 <printf>
}
    171f:	83 c4 14             	add    $0x14,%esp
    1722:	5b                   	pop    %ebx
    1723:	5d                   	pop    %ebp
    1724:	c3                   	ret    

00001725 <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    1725:	55                   	push   %ebp
    1726:	89 e5                	mov    %esp,%ebp
    1728:	57                   	push   %edi
    1729:	56                   	push   %esi
    172a:	53                   	push   %ebx
    172b:	83 ec 5c             	sub    $0x5c,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    172e:	c7 44 24 04 fd 43 00 	movl   $0x43fd,0x4(%esp)
    1735:	00 
    1736:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    173d:	e8 b4 23 00 00       	call   3af6 <printf>
  file[0] = 'C';
    1742:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    1746:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    174a:	bb 00 00 00 00       	mov    $0x0,%ebx
    file[1] = '0' + i;
    unlink(file);
    174f:	8d 7d e5             	lea    -0x1b(%ebp),%edi
  for(i = 0; i < 40; i++){
    1752:	e9 c6 00 00 00       	jmp    181d <concreate+0xf8>
    file[1] = '0' + i;
    1757:	8d 43 30             	lea    0x30(%ebx),%eax
    175a:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    175d:	89 3c 24             	mov    %edi,(%esp)
    1760:	e8 74 22 00 00       	call   39d9 <unlink>
    pid = fork();
    1765:	e8 17 22 00 00       	call   3981 <fork>
    176a:	89 c6                	mov    %eax,%esi
    if(pid && (i % 3) == 1){
    176c:	85 c0                	test   %eax,%eax
    176e:	74 2e                	je     179e <concreate+0x79>
    1770:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1775:	89 d8                	mov    %ebx,%eax
    1777:	f7 ea                	imul   %edx
    1779:	89 d8                	mov    %ebx,%eax
    177b:	c1 f8 1f             	sar    $0x1f,%eax
    177e:	29 c2                	sub    %eax,%edx
    1780:	8d 04 52             	lea    (%edx,%edx,2),%eax
    1783:	89 da                	mov    %ebx,%edx
    1785:	29 c2                	sub    %eax,%edx
    1787:	83 fa 01             	cmp    $0x1,%edx
    178a:	75 12                	jne    179e <concreate+0x79>
      link("C0", file);
    178c:	89 7c 24 04          	mov    %edi,0x4(%esp)
    1790:	c7 04 24 0d 44 00 00 	movl   $0x440d,(%esp)
    1797:	e8 4d 22 00 00       	call   39e9 <link>
    179c:	eb 6e                	jmp    180c <concreate+0xe7>
    } else if(pid == 0 && (i % 5) == 1){
    179e:	85 f6                	test   %esi,%esi
    17a0:	75 2e                	jne    17d0 <concreate+0xab>
    17a2:	b8 67 66 66 66       	mov    $0x66666667,%eax
    17a7:	f7 eb                	imul   %ebx
    17a9:	d1 fa                	sar    %edx
    17ab:	89 d8                	mov    %ebx,%eax
    17ad:	c1 f8 1f             	sar    $0x1f,%eax
    17b0:	29 c2                	sub    %eax,%edx
    17b2:	8d 04 92             	lea    (%edx,%edx,4),%eax
    17b5:	89 da                	mov    %ebx,%edx
    17b7:	29 c2                	sub    %eax,%edx
    17b9:	83 fa 01             	cmp    $0x1,%edx
    17bc:	75 12                	jne    17d0 <concreate+0xab>
      link("C0", file);
    17be:	89 7c 24 04          	mov    %edi,0x4(%esp)
    17c2:	c7 04 24 0d 44 00 00 	movl   $0x440d,(%esp)
    17c9:	e8 1b 22 00 00       	call   39e9 <link>
    17ce:	eb 3c                	jmp    180c <concreate+0xe7>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    17d0:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    17d7:	00 
    17d8:	89 3c 24             	mov    %edi,(%esp)
    17db:	e8 e9 21 00 00       	call   39c9 <open>
      if(fd < 0){
    17e0:	85 c0                	test   %eax,%eax
    17e2:	79 20                	jns    1804 <concreate+0xdf>
        printf(1, "concreate create %s failed\n", file);
    17e4:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    17e7:	89 44 24 08          	mov    %eax,0x8(%esp)
    17eb:	c7 44 24 04 10 44 00 	movl   $0x4410,0x4(%esp)
    17f2:	00 
    17f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17fa:	e8 f7 22 00 00       	call   3af6 <printf>
        exit();
    17ff:	e8 85 21 00 00       	call   3989 <exit>
      }
      close(fd);
    1804:	89 04 24             	mov    %eax,(%esp)
    1807:	e8 a5 21 00 00       	call   39b1 <close>
    }
    if(pid == 0)
    180c:	85 f6                	test   %esi,%esi
    180e:	75 05                	jne    1815 <concreate+0xf0>
      exit();
    1810:	e8 74 21 00 00       	call   3989 <exit>
    else
      wait();
    1815:	e8 77 21 00 00       	call   3991 <wait>
  for(i = 0; i < 40; i++){
    181a:	83 c3 01             	add    $0x1,%ebx
    181d:	83 fb 27             	cmp    $0x27,%ebx
    1820:	0f 8e 31 ff ff ff    	jle    1757 <concreate+0x32>
  }

  memset(fa, 0, sizeof(fa));
    1826:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
    182d:	00 
    182e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1835:	00 
    1836:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1839:	89 04 24             	mov    %eax,(%esp)
    183c:	e8 0d 20 00 00       	call   384e <memset>
  fd = open(".", 0);
    1841:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1848:	00 
    1849:	c7 04 24 1a 46 00 00 	movl   $0x461a,(%esp)
    1850:	e8 74 21 00 00       	call   39c9 <open>
    1855:	89 c3                	mov    %eax,%ebx
  n = 0;
    1857:	bf 00 00 00 00       	mov    $0x0,%edi
  while(read(fd, &de, sizeof(de)) > 0){
    185c:	8d 75 ac             	lea    -0x54(%ebp),%esi
    185f:	eb 6e                	jmp    18cf <concreate+0x1aa>
    if(de.inum == 0)
    1861:	66 83 7d ac 00       	cmpw   $0x0,-0x54(%ebp)
    1866:	74 67                	je     18cf <concreate+0x1aa>
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    1868:	80 7d ae 43          	cmpb   $0x43,-0x52(%ebp)
    186c:	75 61                	jne    18cf <concreate+0x1aa>
    186e:	80 7d b0 00          	cmpb   $0x0,-0x50(%ebp)
    1872:	75 5b                	jne    18cf <concreate+0x1aa>
      i = de.name[1] - '0';
    1874:	0f be 45 af          	movsbl -0x51(%ebp),%eax
    1878:	83 e8 30             	sub    $0x30,%eax
      if(i < 0 || i >= sizeof(fa)){
    187b:	83 f8 27             	cmp    $0x27,%eax
    187e:	76 20                	jbe    18a0 <concreate+0x17b>
        printf(1, "concreate weird file %s\n", de.name);
    1880:	8d 45 ae             	lea    -0x52(%ebp),%eax
    1883:	89 44 24 08          	mov    %eax,0x8(%esp)
    1887:	c7 44 24 04 2c 44 00 	movl   $0x442c,0x4(%esp)
    188e:	00 
    188f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1896:	e8 5b 22 00 00       	call   3af6 <printf>
        exit();
    189b:	e8 e9 20 00 00       	call   3989 <exit>
      }
      if(fa[i]){
    18a0:	80 7c 05 bd 00       	cmpb   $0x0,-0x43(%ebp,%eax,1)
    18a5:	74 20                	je     18c7 <concreate+0x1a2>
        printf(1, "concreate duplicate file %s\n", de.name);
    18a7:	8d 45 ae             	lea    -0x52(%ebp),%eax
    18aa:	89 44 24 08          	mov    %eax,0x8(%esp)
    18ae:	c7 44 24 04 45 44 00 	movl   $0x4445,0x4(%esp)
    18b5:	00 
    18b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18bd:	e8 34 22 00 00       	call   3af6 <printf>
        exit();
    18c2:	e8 c2 20 00 00       	call   3989 <exit>
      }
      fa[i] = 1;
    18c7:	c6 44 05 bd 01       	movb   $0x1,-0x43(%ebp,%eax,1)
      n++;
    18cc:	83 c7 01             	add    $0x1,%edi
  while(read(fd, &de, sizeof(de)) > 0){
    18cf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    18d6:	00 
    18d7:	89 74 24 04          	mov    %esi,0x4(%esp)
    18db:	89 1c 24             	mov    %ebx,(%esp)
    18de:	e8 be 20 00 00       	call   39a1 <read>
    18e3:	85 c0                	test   %eax,%eax
    18e5:	0f 8f 76 ff ff ff    	jg     1861 <concreate+0x13c>
    }
  }
  close(fd);
    18eb:	89 1c 24             	mov    %ebx,(%esp)
    18ee:	e8 be 20 00 00       	call   39b1 <close>

  if(n != 40){
    18f3:	83 ff 28             	cmp    $0x28,%edi
    18f6:	0f 84 fe 00 00 00    	je     19fa <concreate+0x2d5>
    printf(1, "concreate not enough files in directory listing\n");
    18fc:	c7 44 24 04 ac 4f 00 	movl   $0x4fac,0x4(%esp)
    1903:	00 
    1904:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    190b:	e8 e6 21 00 00       	call   3af6 <printf>
    exit();
    1910:	e8 74 20 00 00       	call   3989 <exit>
  }

  for(i = 0; i < 40; i++){
    file[1] = '0' + i;
    1915:	8d 43 30             	lea    0x30(%ebx),%eax
    1918:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    191b:	e8 61 20 00 00       	call   3981 <fork>
    1920:	89 c6                	mov    %eax,%esi
    if(pid < 0){
    1922:	85 c0                	test   %eax,%eax
    1924:	79 19                	jns    193f <concreate+0x21a>
      printf(1, "fork failed\n");
    1926:	c7 44 24 04 e5 4c 00 	movl   $0x4ce5,0x4(%esp)
    192d:	00 
    192e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1935:	e8 bc 21 00 00       	call   3af6 <printf>
      exit();
    193a:	e8 4a 20 00 00       	call   3989 <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    193f:	b8 56 55 55 55       	mov    $0x55555556,%eax
    1944:	f7 eb                	imul   %ebx
    1946:	89 d8                	mov    %ebx,%eax
    1948:	c1 f8 1f             	sar    $0x1f,%eax
    194b:	29 c2                	sub    %eax,%edx
    194d:	8d 04 52             	lea    (%edx,%edx,2),%eax
    1950:	89 da                	mov    %ebx,%edx
    1952:	29 c2                	sub    %eax,%edx
    1954:	89 d0                	mov    %edx,%eax
    1956:	09 f0                	or     %esi,%eax
    1958:	74 09                	je     1963 <concreate+0x23e>
    195a:	83 fa 01             	cmp    $0x1,%edx
    195d:	75 66                	jne    19c5 <concreate+0x2a0>
       ((i % 3) == 1 && pid != 0)){
    195f:	85 f6                	test   %esi,%esi
    1961:	74 62                	je     19c5 <concreate+0x2a0>
      close(open(file, 0));
    1963:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    196a:	00 
    196b:	89 3c 24             	mov    %edi,(%esp)
    196e:	e8 56 20 00 00       	call   39c9 <open>
    1973:	89 04 24             	mov    %eax,(%esp)
    1976:	e8 36 20 00 00       	call   39b1 <close>
      close(open(file, 0));
    197b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1982:	00 
    1983:	89 3c 24             	mov    %edi,(%esp)
    1986:	e8 3e 20 00 00       	call   39c9 <open>
    198b:	89 04 24             	mov    %eax,(%esp)
    198e:	e8 1e 20 00 00       	call   39b1 <close>
      close(open(file, 0));
    1993:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    199a:	00 
    199b:	89 3c 24             	mov    %edi,(%esp)
    199e:	e8 26 20 00 00       	call   39c9 <open>
    19a3:	89 04 24             	mov    %eax,(%esp)
    19a6:	e8 06 20 00 00       	call   39b1 <close>
      close(open(file, 0));
    19ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    19b2:	00 
    19b3:	89 3c 24             	mov    %edi,(%esp)
    19b6:	e8 0e 20 00 00       	call   39c9 <open>
    19bb:	89 04 24             	mov    %eax,(%esp)
    19be:	e8 ee 1f 00 00       	call   39b1 <close>
    19c3:	eb 20                	jmp    19e5 <concreate+0x2c0>
    } else {
      unlink(file);
    19c5:	89 3c 24             	mov    %edi,(%esp)
    19c8:	e8 0c 20 00 00       	call   39d9 <unlink>
      unlink(file);
    19cd:	89 3c 24             	mov    %edi,(%esp)
    19d0:	e8 04 20 00 00       	call   39d9 <unlink>
      unlink(file);
    19d5:	89 3c 24             	mov    %edi,(%esp)
    19d8:	e8 fc 1f 00 00       	call   39d9 <unlink>
      unlink(file);
    19dd:	89 3c 24             	mov    %edi,(%esp)
    19e0:	e8 f4 1f 00 00       	call   39d9 <unlink>
    }
    if(pid == 0)
    19e5:	85 f6                	test   %esi,%esi
    19e7:	75 05                	jne    19ee <concreate+0x2c9>
      exit();
    19e9:	e8 9b 1f 00 00       	call   3989 <exit>
    19ee:	66 90                	xchg   %ax,%ax
    else
      wait();
    19f0:	e8 9c 1f 00 00       	call   3991 <wait>
  for(i = 0; i < 40; i++){
    19f5:	83 c3 01             	add    $0x1,%ebx
    19f8:	eb 08                	jmp    1a02 <concreate+0x2dd>
    19fa:	bb 00 00 00 00       	mov    $0x0,%ebx
      close(open(file, 0));
    19ff:	8d 7d e5             	lea    -0x1b(%ebp),%edi
  for(i = 0; i < 40; i++){
    1a02:	83 fb 27             	cmp    $0x27,%ebx
    1a05:	0f 8e 0a ff ff ff    	jle    1915 <concreate+0x1f0>
  }

  printf(1, "concreate ok\n");
    1a0b:	c7 44 24 04 62 44 00 	movl   $0x4462,0x4(%esp)
    1a12:	00 
    1a13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a1a:	e8 d7 20 00 00       	call   3af6 <printf>
}
    1a1f:	83 c4 5c             	add    $0x5c,%esp
    1a22:	5b                   	pop    %ebx
    1a23:	5e                   	pop    %esi
    1a24:	5f                   	pop    %edi
    1a25:	5d                   	pop    %ebp
    1a26:	c3                   	ret    

00001a27 <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    1a27:	55                   	push   %ebp
    1a28:	89 e5                	mov    %esp,%ebp
    1a2a:	57                   	push   %edi
    1a2b:	56                   	push   %esi
    1a2c:	53                   	push   %ebx
    1a2d:	83 ec 1c             	sub    $0x1c,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    1a30:	c7 44 24 04 70 44 00 	movl   $0x4470,0x4(%esp)
    1a37:	00 
    1a38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a3f:	e8 b2 20 00 00       	call   3af6 <printf>

  unlink("x");
    1a44:	c7 04 24 fd 46 00 00 	movl   $0x46fd,(%esp)
    1a4b:	e8 89 1f 00 00       	call   39d9 <unlink>
  pid = fork();
    1a50:	e8 2c 1f 00 00       	call   3981 <fork>
    1a55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(pid < 0){
    1a58:	85 c0                	test   %eax,%eax
    1a5a:	79 19                	jns    1a75 <linkunlink+0x4e>
    printf(1, "fork failed\n");
    1a5c:	c7 44 24 04 e5 4c 00 	movl   $0x4ce5,0x4(%esp)
    1a63:	00 
    1a64:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a6b:	e8 86 20 00 00       	call   3af6 <printf>
    exit();
    1a70:	e8 14 1f 00 00       	call   3989 <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    1a75:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    1a79:	74 07                	je     1a82 <linkunlink+0x5b>
    1a7b:	bb 01 00 00 00       	mov    $0x1,%ebx
    1a80:	eb 05                	jmp    1a87 <linkunlink+0x60>
    1a82:	bb 61 00 00 00       	mov    $0x61,%ebx
  for(i = 0; i < 100; i++){
    1a87:	be 00 00 00 00       	mov    $0x0,%esi
    x = x * 1103515245 + 12345;
    if((x % 3) == 0){
    1a8c:	bf ab aa aa aa       	mov    $0xaaaaaaab,%edi
  for(i = 0; i < 100; i++){
    1a91:	eb 64                	jmp    1af7 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1a93:	69 db 6d 4e c6 41    	imul   $0x41c64e6d,%ebx,%ebx
    1a99:	81 c3 39 30 00 00    	add    $0x3039,%ebx
    if((x % 3) == 0){
    1a9f:	89 d8                	mov    %ebx,%eax
    1aa1:	f7 e7                	mul    %edi
    1aa3:	d1 ea                	shr    %edx
    1aa5:	8d 04 52             	lea    (%edx,%edx,2),%eax
    1aa8:	89 da                	mov    %ebx,%edx
    1aaa:	29 c2                	sub    %eax,%edx
    1aac:	75 1e                	jne    1acc <linkunlink+0xa5>
      close(open("x", O_RDWR | O_CREATE));
    1aae:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1ab5:	00 
    1ab6:	c7 04 24 fd 46 00 00 	movl   $0x46fd,(%esp)
    1abd:	e8 07 1f 00 00       	call   39c9 <open>
    1ac2:	89 04 24             	mov    %eax,(%esp)
    1ac5:	e8 e7 1e 00 00       	call   39b1 <close>
    1aca:	eb 28                	jmp    1af4 <linkunlink+0xcd>
    } else if((x % 3) == 1){
    1acc:	83 fa 01             	cmp    $0x1,%edx
    1acf:	90                   	nop
    1ad0:	75 16                	jne    1ae8 <linkunlink+0xc1>
      link("cat", "x");
    1ad2:	c7 44 24 04 fd 46 00 	movl   $0x46fd,0x4(%esp)
    1ad9:	00 
    1ada:	c7 04 24 81 44 00 00 	movl   $0x4481,(%esp)
    1ae1:	e8 03 1f 00 00       	call   39e9 <link>
    1ae6:	eb 0c                	jmp    1af4 <linkunlink+0xcd>
    } else {
      unlink("x");
    1ae8:	c7 04 24 fd 46 00 00 	movl   $0x46fd,(%esp)
    1aef:	e8 e5 1e 00 00       	call   39d9 <unlink>
  for(i = 0; i < 100; i++){
    1af4:	83 c6 01             	add    $0x1,%esi
    1af7:	83 fe 63             	cmp    $0x63,%esi
    1afa:	7e 97                	jle    1a93 <linkunlink+0x6c>
    }
  }

  if(pid)
    1afc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    1b00:	74 1b                	je     1b1d <linkunlink+0xf6>
    wait();
    1b02:	e8 8a 1e 00 00       	call   3991 <wait>
  else
    exit();

  printf(1, "linkunlink ok\n");
    1b07:	c7 44 24 04 85 44 00 	movl   $0x4485,0x4(%esp)
    1b0e:	00 
    1b0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b16:	e8 db 1f 00 00       	call   3af6 <printf>
    1b1b:	eb 05                	jmp    1b22 <linkunlink+0xfb>
    exit();
    1b1d:	e8 67 1e 00 00       	call   3989 <exit>
}
    1b22:	83 c4 1c             	add    $0x1c,%esp
    1b25:	5b                   	pop    %ebx
    1b26:	5e                   	pop    %esi
    1b27:	5f                   	pop    %edi
    1b28:	5d                   	pop    %ebp
    1b29:	c3                   	ret    

00001b2a <bigdir>:

// directory that uses indirect blocks
void
bigdir(void)
{
    1b2a:	55                   	push   %ebp
    1b2b:	89 e5                	mov    %esp,%ebp
    1b2d:	56                   	push   %esi
    1b2e:	53                   	push   %ebx
    1b2f:	83 ec 20             	sub    $0x20,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    1b32:	c7 44 24 04 94 44 00 	movl   $0x4494,0x4(%esp)
    1b39:	00 
    1b3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b41:	e8 b0 1f 00 00       	call   3af6 <printf>
  unlink("bd");
    1b46:	c7 04 24 a1 44 00 00 	movl   $0x44a1,(%esp)
    1b4d:	e8 87 1e 00 00       	call   39d9 <unlink>

  fd = open("bd", O_CREATE);
    1b52:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    1b59:	00 
    1b5a:	c7 04 24 a1 44 00 00 	movl   $0x44a1,(%esp)
    1b61:	e8 63 1e 00 00       	call   39c9 <open>
  if(fd < 0){
    1b66:	85 c0                	test   %eax,%eax
    1b68:	79 19                	jns    1b83 <bigdir+0x59>
    printf(1, "bigdir create failed\n");
    1b6a:	c7 44 24 04 a4 44 00 	movl   $0x44a4,0x4(%esp)
    1b71:	00 
    1b72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b79:	e8 78 1f 00 00       	call   3af6 <printf>
    exit();
    1b7e:	e8 06 1e 00 00       	call   3989 <exit>
  }
  close(fd);
    1b83:	89 04 24             	mov    %eax,(%esp)
    1b86:	e8 26 1e 00 00       	call   39b1 <close>

  for(i = 0; i < 500; i++){
    1b8b:	bb 00 00 00 00       	mov    $0x0,%ebx
    name[0] = 'x';
    name[1] = '0' + (i / 64);
    name[2] = '0' + (i % 64);
    name[3] = '\0';
    if(link("bd", name) != 0){
    1b90:	8d 75 ee             	lea    -0x12(%ebp),%esi
  for(i = 0; i < 500; i++){
    1b93:	eb 61                	jmp    1bf6 <bigdir+0xcc>
    name[0] = 'x';
    1b95:	c6 45 ee 78          	movb   $0x78,-0x12(%ebp)
    name[1] = '0' + (i / 64);
    1b99:	8d 43 3f             	lea    0x3f(%ebx),%eax
    1b9c:	85 db                	test   %ebx,%ebx
    1b9e:	0f 49 c3             	cmovns %ebx,%eax
    1ba1:	c1 f8 06             	sar    $0x6,%eax
    1ba4:	83 c0 30             	add    $0x30,%eax
    1ba7:	88 45 ef             	mov    %al,-0x11(%ebp)
    name[2] = '0' + (i % 64);
    1baa:	89 d8                	mov    %ebx,%eax
    1bac:	c1 f8 1f             	sar    $0x1f,%eax
    1baf:	c1 e8 1a             	shr    $0x1a,%eax
    1bb2:	8d 14 03             	lea    (%ebx,%eax,1),%edx
    1bb5:	83 e2 3f             	and    $0x3f,%edx
    1bb8:	29 c2                	sub    %eax,%edx
    1bba:	89 d0                	mov    %edx,%eax
    1bbc:	83 c0 30             	add    $0x30,%eax
    1bbf:	88 45 f0             	mov    %al,-0x10(%ebp)
    name[3] = '\0';
    1bc2:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
    if(link("bd", name) != 0){
    1bc6:	89 74 24 04          	mov    %esi,0x4(%esp)
    1bca:	c7 04 24 a1 44 00 00 	movl   $0x44a1,(%esp)
    1bd1:	e8 13 1e 00 00       	call   39e9 <link>
    1bd6:	85 c0                	test   %eax,%eax
    1bd8:	74 19                	je     1bf3 <bigdir+0xc9>
      printf(1, "bigdir link failed\n");
    1bda:	c7 44 24 04 ba 44 00 	movl   $0x44ba,0x4(%esp)
    1be1:	00 
    1be2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1be9:	e8 08 1f 00 00       	call   3af6 <printf>
      exit();
    1bee:	e8 96 1d 00 00       	call   3989 <exit>
  for(i = 0; i < 500; i++){
    1bf3:	83 c3 01             	add    $0x1,%ebx
    1bf6:	81 fb f3 01 00 00    	cmp    $0x1f3,%ebx
    1bfc:	7e 97                	jle    1b95 <bigdir+0x6b>
    }
  }

  unlink("bd");
    1bfe:	c7 04 24 a1 44 00 00 	movl   $0x44a1,(%esp)
    1c05:	e8 cf 1d 00 00       	call   39d9 <unlink>
  for(i = 0; i < 500; i++){
    1c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
    name[0] = 'x';
    name[1] = '0' + (i / 64);
    name[2] = '0' + (i % 64);
    name[3] = '\0';
    if(unlink(name) != 0){
    1c0f:	8d 75 ee             	lea    -0x12(%ebp),%esi
  for(i = 0; i < 500; i++){
    1c12:	eb 59                	jmp    1c6d <bigdir+0x143>
    name[0] = 'x';
    1c14:	c6 45 ee 78          	movb   $0x78,-0x12(%ebp)
    name[1] = '0' + (i / 64);
    1c18:	8d 43 3f             	lea    0x3f(%ebx),%eax
    1c1b:	85 db                	test   %ebx,%ebx
    1c1d:	0f 49 c3             	cmovns %ebx,%eax
    1c20:	c1 f8 06             	sar    $0x6,%eax
    1c23:	83 c0 30             	add    $0x30,%eax
    1c26:	88 45 ef             	mov    %al,-0x11(%ebp)
    name[2] = '0' + (i % 64);
    1c29:	89 d8                	mov    %ebx,%eax
    1c2b:	c1 f8 1f             	sar    $0x1f,%eax
    1c2e:	c1 e8 1a             	shr    $0x1a,%eax
    1c31:	8d 14 03             	lea    (%ebx,%eax,1),%edx
    1c34:	83 e2 3f             	and    $0x3f,%edx
    1c37:	29 c2                	sub    %eax,%edx
    1c39:	89 d0                	mov    %edx,%eax
    1c3b:	83 c0 30             	add    $0x30,%eax
    1c3e:	88 45 f0             	mov    %al,-0x10(%ebp)
    name[3] = '\0';
    1c41:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
    if(unlink(name) != 0){
    1c45:	89 34 24             	mov    %esi,(%esp)
    1c48:	e8 8c 1d 00 00       	call   39d9 <unlink>
    1c4d:	85 c0                	test   %eax,%eax
    1c4f:	74 19                	je     1c6a <bigdir+0x140>
      printf(1, "bigdir unlink failed");
    1c51:	c7 44 24 04 ce 44 00 	movl   $0x44ce,0x4(%esp)
    1c58:	00 
    1c59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1c60:	e8 91 1e 00 00       	call   3af6 <printf>
      exit();
    1c65:	e8 1f 1d 00 00       	call   3989 <exit>
  for(i = 0; i < 500; i++){
    1c6a:	83 c3 01             	add    $0x1,%ebx
    1c6d:	81 fb f3 01 00 00    	cmp    $0x1f3,%ebx
    1c73:	7e 9f                	jle    1c14 <bigdir+0xea>
    }
  }

  printf(1, "bigdir ok\n");
    1c75:	c7 44 24 04 e3 44 00 	movl   $0x44e3,0x4(%esp)
    1c7c:	00 
    1c7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1c84:	e8 6d 1e 00 00       	call   3af6 <printf>
}
    1c89:	83 c4 20             	add    $0x20,%esp
    1c8c:	5b                   	pop    %ebx
    1c8d:	5e                   	pop    %esi
    1c8e:	5d                   	pop    %ebp
    1c8f:	c3                   	ret    

00001c90 <subdir>:

void
subdir(void)
{
    1c90:	55                   	push   %ebp
    1c91:	89 e5                	mov    %esp,%ebp
    1c93:	53                   	push   %ebx
    1c94:	83 ec 14             	sub    $0x14,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    1c97:	c7 44 24 04 ee 44 00 	movl   $0x44ee,0x4(%esp)
    1c9e:	00 
    1c9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ca6:	e8 4b 1e 00 00       	call   3af6 <printf>

  unlink("ff");
    1cab:	c7 04 24 77 45 00 00 	movl   $0x4577,(%esp)
    1cb2:	e8 22 1d 00 00       	call   39d9 <unlink>
  if(mkdir("dd") != 0){
    1cb7:	c7 04 24 14 46 00 00 	movl   $0x4614,(%esp)
    1cbe:	e8 2e 1d 00 00       	call   39f1 <mkdir>
    1cc3:	85 c0                	test   %eax,%eax
    1cc5:	74 19                	je     1ce0 <subdir+0x50>
    printf(1, "subdir mkdir dd failed\n");
    1cc7:	c7 44 24 04 fb 44 00 	movl   $0x44fb,0x4(%esp)
    1cce:	00 
    1ccf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1cd6:	e8 1b 1e 00 00       	call   3af6 <printf>
    exit();
    1cdb:	e8 a9 1c 00 00       	call   3989 <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    1ce0:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1ce7:	00 
    1ce8:	c7 04 24 4d 45 00 00 	movl   $0x454d,(%esp)
    1cef:	e8 d5 1c 00 00       	call   39c9 <open>
    1cf4:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1cf6:	85 c0                	test   %eax,%eax
    1cf8:	79 19                	jns    1d13 <subdir+0x83>
    printf(1, "create dd/ff failed\n");
    1cfa:	c7 44 24 04 13 45 00 	movl   $0x4513,0x4(%esp)
    1d01:	00 
    1d02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d09:	e8 e8 1d 00 00       	call   3af6 <printf>
    exit();
    1d0e:	e8 76 1c 00 00       	call   3989 <exit>
  }
  write(fd, "ff", 2);
    1d13:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    1d1a:	00 
    1d1b:	c7 44 24 04 77 45 00 	movl   $0x4577,0x4(%esp)
    1d22:	00 
    1d23:	89 04 24             	mov    %eax,(%esp)
    1d26:	e8 7e 1c 00 00       	call   39a9 <write>
  close(fd);
    1d2b:	89 1c 24             	mov    %ebx,(%esp)
    1d2e:	e8 7e 1c 00 00       	call   39b1 <close>

  if(unlink("dd") >= 0){
    1d33:	c7 04 24 14 46 00 00 	movl   $0x4614,(%esp)
    1d3a:	e8 9a 1c 00 00       	call   39d9 <unlink>
    1d3f:	85 c0                	test   %eax,%eax
    1d41:	78 19                	js     1d5c <subdir+0xcc>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    1d43:	c7 44 24 04 e0 4f 00 	movl   $0x4fe0,0x4(%esp)
    1d4a:	00 
    1d4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d52:	e8 9f 1d 00 00       	call   3af6 <printf>
    exit();
    1d57:	e8 2d 1c 00 00       	call   3989 <exit>
  }

  if(mkdir("/dd/dd") != 0){
    1d5c:	c7 04 24 28 45 00 00 	movl   $0x4528,(%esp)
    1d63:	e8 89 1c 00 00       	call   39f1 <mkdir>
    1d68:	85 c0                	test   %eax,%eax
    1d6a:	74 19                	je     1d85 <subdir+0xf5>
    printf(1, "subdir mkdir dd/dd failed\n");
    1d6c:	c7 44 24 04 2f 45 00 	movl   $0x452f,0x4(%esp)
    1d73:	00 
    1d74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d7b:	e8 76 1d 00 00       	call   3af6 <printf>
    exit();
    1d80:	e8 04 1c 00 00       	call   3989 <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    1d85:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1d8c:	00 
    1d8d:	c7 04 24 4a 45 00 00 	movl   $0x454a,(%esp)
    1d94:	e8 30 1c 00 00       	call   39c9 <open>
    1d99:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1d9b:	85 c0                	test   %eax,%eax
    1d9d:	79 19                	jns    1db8 <subdir+0x128>
    printf(1, "create dd/dd/ff failed\n");
    1d9f:	c7 44 24 04 53 45 00 	movl   $0x4553,0x4(%esp)
    1da6:	00 
    1da7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1dae:	e8 43 1d 00 00       	call   3af6 <printf>
    exit();
    1db3:	e8 d1 1b 00 00       	call   3989 <exit>
  }
  write(fd, "FF", 2);
    1db8:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    1dbf:	00 
    1dc0:	c7 44 24 04 6b 45 00 	movl   $0x456b,0x4(%esp)
    1dc7:	00 
    1dc8:	89 04 24             	mov    %eax,(%esp)
    1dcb:	e8 d9 1b 00 00       	call   39a9 <write>
  close(fd);
    1dd0:	89 1c 24             	mov    %ebx,(%esp)
    1dd3:	e8 d9 1b 00 00       	call   39b1 <close>

  fd = open("dd/dd/../ff", 0);
    1dd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1ddf:	00 
    1de0:	c7 04 24 6e 45 00 00 	movl   $0x456e,(%esp)
    1de7:	e8 dd 1b 00 00       	call   39c9 <open>
    1dec:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1dee:	85 c0                	test   %eax,%eax
    1df0:	79 19                	jns    1e0b <subdir+0x17b>
    printf(1, "open dd/dd/../ff failed\n");
    1df2:	c7 44 24 04 7a 45 00 	movl   $0x457a,0x4(%esp)
    1df9:	00 
    1dfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e01:	e8 f0 1c 00 00       	call   3af6 <printf>
    exit();
    1e06:	e8 7e 1b 00 00       	call   3989 <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    1e0b:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1e12:	00 
    1e13:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
    1e1a:	00 
    1e1b:	89 04 24             	mov    %eax,(%esp)
    1e1e:	e8 7e 1b 00 00       	call   39a1 <read>
  if(cc != 2 || buf[0] != 'f'){
    1e23:	83 f8 02             	cmp    $0x2,%eax
    1e26:	75 09                	jne    1e31 <subdir+0x1a1>
    1e28:	80 3d a0 7d 00 00 66 	cmpb   $0x66,0x7da0
    1e2f:	74 19                	je     1e4a <subdir+0x1ba>
    printf(1, "dd/dd/../ff wrong content\n");
    1e31:	c7 44 24 04 93 45 00 	movl   $0x4593,0x4(%esp)
    1e38:	00 
    1e39:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e40:	e8 b1 1c 00 00       	call   3af6 <printf>
    exit();
    1e45:	e8 3f 1b 00 00       	call   3989 <exit>
  }
  close(fd);
    1e4a:	89 1c 24             	mov    %ebx,(%esp)
    1e4d:	e8 5f 1b 00 00       	call   39b1 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    1e52:	c7 44 24 04 ae 45 00 	movl   $0x45ae,0x4(%esp)
    1e59:	00 
    1e5a:	c7 04 24 4a 45 00 00 	movl   $0x454a,(%esp)
    1e61:	e8 83 1b 00 00       	call   39e9 <link>
    1e66:	85 c0                	test   %eax,%eax
    1e68:	74 19                	je     1e83 <subdir+0x1f3>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    1e6a:	c7 44 24 04 08 50 00 	movl   $0x5008,0x4(%esp)
    1e71:	00 
    1e72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e79:	e8 78 1c 00 00       	call   3af6 <printf>
    exit();
    1e7e:	e8 06 1b 00 00       	call   3989 <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    1e83:	c7 04 24 4a 45 00 00 	movl   $0x454a,(%esp)
    1e8a:	e8 4a 1b 00 00       	call   39d9 <unlink>
    1e8f:	85 c0                	test   %eax,%eax
    1e91:	74 19                	je     1eac <subdir+0x21c>
    printf(1, "unlink dd/dd/ff failed\n");
    1e93:	c7 44 24 04 b9 45 00 	movl   $0x45b9,0x4(%esp)
    1e9a:	00 
    1e9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ea2:	e8 4f 1c 00 00       	call   3af6 <printf>
    exit();
    1ea7:	e8 dd 1a 00 00       	call   3989 <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1eac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1eb3:	00 
    1eb4:	c7 04 24 4a 45 00 00 	movl   $0x454a,(%esp)
    1ebb:	e8 09 1b 00 00       	call   39c9 <open>
    1ec0:	85 c0                	test   %eax,%eax
    1ec2:	78 19                	js     1edd <subdir+0x24d>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    1ec4:	c7 44 24 04 2c 50 00 	movl   $0x502c,0x4(%esp)
    1ecb:	00 
    1ecc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ed3:	e8 1e 1c 00 00       	call   3af6 <printf>
    exit();
    1ed8:	e8 ac 1a 00 00       	call   3989 <exit>
  }

  if(chdir("dd") != 0){
    1edd:	c7 04 24 14 46 00 00 	movl   $0x4614,(%esp)
    1ee4:	e8 10 1b 00 00       	call   39f9 <chdir>
    1ee9:	85 c0                	test   %eax,%eax
    1eeb:	74 19                	je     1f06 <subdir+0x276>
    printf(1, "chdir dd failed\n");
    1eed:	c7 44 24 04 d1 45 00 	movl   $0x45d1,0x4(%esp)
    1ef4:	00 
    1ef5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1efc:	e8 f5 1b 00 00       	call   3af6 <printf>
    exit();
    1f01:	e8 83 1a 00 00       	call   3989 <exit>
  }
  if(chdir("dd/../../dd") != 0){
    1f06:	c7 04 24 e2 45 00 00 	movl   $0x45e2,(%esp)
    1f0d:	e8 e7 1a 00 00       	call   39f9 <chdir>
    1f12:	85 c0                	test   %eax,%eax
    1f14:	74 19                	je     1f2f <subdir+0x29f>
    printf(1, "chdir dd/../../dd failed\n");
    1f16:	c7 44 24 04 ee 45 00 	movl   $0x45ee,0x4(%esp)
    1f1d:	00 
    1f1e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f25:	e8 cc 1b 00 00       	call   3af6 <printf>
    exit();
    1f2a:	e8 5a 1a 00 00       	call   3989 <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    1f2f:	c7 04 24 08 46 00 00 	movl   $0x4608,(%esp)
    1f36:	e8 be 1a 00 00       	call   39f9 <chdir>
    1f3b:	85 c0                	test   %eax,%eax
    1f3d:	74 19                	je     1f58 <subdir+0x2c8>
    printf(1, "chdir dd/../../dd failed\n");
    1f3f:	c7 44 24 04 ee 45 00 	movl   $0x45ee,0x4(%esp)
    1f46:	00 
    1f47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f4e:	e8 a3 1b 00 00       	call   3af6 <printf>
    exit();
    1f53:	e8 31 1a 00 00       	call   3989 <exit>
  }
  if(chdir("./..") != 0){
    1f58:	c7 04 24 17 46 00 00 	movl   $0x4617,(%esp)
    1f5f:	e8 95 1a 00 00       	call   39f9 <chdir>
    1f64:	85 c0                	test   %eax,%eax
    1f66:	74 19                	je     1f81 <subdir+0x2f1>
    printf(1, "chdir ./.. failed\n");
    1f68:	c7 44 24 04 1c 46 00 	movl   $0x461c,0x4(%esp)
    1f6f:	00 
    1f70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f77:	e8 7a 1b 00 00       	call   3af6 <printf>
    exit();
    1f7c:	e8 08 1a 00 00       	call   3989 <exit>
  }

  fd = open("dd/dd/ffff", 0);
    1f81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1f88:	00 
    1f89:	c7 04 24 ae 45 00 00 	movl   $0x45ae,(%esp)
    1f90:	e8 34 1a 00 00       	call   39c9 <open>
    1f95:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1f97:	85 c0                	test   %eax,%eax
    1f99:	79 19                	jns    1fb4 <subdir+0x324>
    printf(1, "open dd/dd/ffff failed\n");
    1f9b:	c7 44 24 04 2f 46 00 	movl   $0x462f,0x4(%esp)
    1fa2:	00 
    1fa3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1faa:	e8 47 1b 00 00       	call   3af6 <printf>
    exit();
    1faf:	e8 d5 19 00 00       	call   3989 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    1fb4:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1fbb:	00 
    1fbc:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
    1fc3:	00 
    1fc4:	89 04 24             	mov    %eax,(%esp)
    1fc7:	e8 d5 19 00 00       	call   39a1 <read>
    1fcc:	83 f8 02             	cmp    $0x2,%eax
    1fcf:	74 19                	je     1fea <subdir+0x35a>
    printf(1, "read dd/dd/ffff wrong len\n");
    1fd1:	c7 44 24 04 47 46 00 	movl   $0x4647,0x4(%esp)
    1fd8:	00 
    1fd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1fe0:	e8 11 1b 00 00       	call   3af6 <printf>
    exit();
    1fe5:	e8 9f 19 00 00       	call   3989 <exit>
  }
  close(fd);
    1fea:	89 1c 24             	mov    %ebx,(%esp)
    1fed:	e8 bf 19 00 00       	call   39b1 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1ff2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1ff9:	00 
    1ffa:	c7 04 24 4a 45 00 00 	movl   $0x454a,(%esp)
    2001:	e8 c3 19 00 00       	call   39c9 <open>
    2006:	85 c0                	test   %eax,%eax
    2008:	78 19                	js     2023 <subdir+0x393>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    200a:	c7 44 24 04 50 50 00 	movl   $0x5050,0x4(%esp)
    2011:	00 
    2012:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2019:	e8 d8 1a 00 00       	call   3af6 <printf>
    exit();
    201e:	e8 66 19 00 00       	call   3989 <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2023:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    202a:	00 
    202b:	c7 04 24 62 46 00 00 	movl   $0x4662,(%esp)
    2032:	e8 92 19 00 00       	call   39c9 <open>
    2037:	85 c0                	test   %eax,%eax
    2039:	78 19                	js     2054 <subdir+0x3c4>
    printf(1, "create dd/ff/ff succeeded!\n");
    203b:	c7 44 24 04 6b 46 00 	movl   $0x466b,0x4(%esp)
    2042:	00 
    2043:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    204a:	e8 a7 1a 00 00       	call   3af6 <printf>
    exit();
    204f:	e8 35 19 00 00       	call   3989 <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2054:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    205b:	00 
    205c:	c7 04 24 87 46 00 00 	movl   $0x4687,(%esp)
    2063:	e8 61 19 00 00       	call   39c9 <open>
    2068:	85 c0                	test   %eax,%eax
    206a:	78 19                	js     2085 <subdir+0x3f5>
    printf(1, "create dd/xx/ff succeeded!\n");
    206c:	c7 44 24 04 90 46 00 	movl   $0x4690,0x4(%esp)
    2073:	00 
    2074:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    207b:	e8 76 1a 00 00       	call   3af6 <printf>
    exit();
    2080:	e8 04 19 00 00       	call   3989 <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    2085:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    208c:	00 
    208d:	c7 04 24 14 46 00 00 	movl   $0x4614,(%esp)
    2094:	e8 30 19 00 00       	call   39c9 <open>
    2099:	85 c0                	test   %eax,%eax
    209b:	78 19                	js     20b6 <subdir+0x426>
    printf(1, "create dd succeeded!\n");
    209d:	c7 44 24 04 ac 46 00 	movl   $0x46ac,0x4(%esp)
    20a4:	00 
    20a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20ac:	e8 45 1a 00 00       	call   3af6 <printf>
    exit();
    20b1:	e8 d3 18 00 00       	call   3989 <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    20b6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    20bd:	00 
    20be:	c7 04 24 14 46 00 00 	movl   $0x4614,(%esp)
    20c5:	e8 ff 18 00 00       	call   39c9 <open>
    20ca:	85 c0                	test   %eax,%eax
    20cc:	78 19                	js     20e7 <subdir+0x457>
    printf(1, "open dd rdwr succeeded!\n");
    20ce:	c7 44 24 04 c2 46 00 	movl   $0x46c2,0x4(%esp)
    20d5:	00 
    20d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20dd:	e8 14 1a 00 00       	call   3af6 <printf>
    exit();
    20e2:	e8 a2 18 00 00       	call   3989 <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    20e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    20ee:	00 
    20ef:	c7 04 24 14 46 00 00 	movl   $0x4614,(%esp)
    20f6:	e8 ce 18 00 00       	call   39c9 <open>
    20fb:	85 c0                	test   %eax,%eax
    20fd:	78 19                	js     2118 <subdir+0x488>
    printf(1, "open dd wronly succeeded!\n");
    20ff:	c7 44 24 04 db 46 00 	movl   $0x46db,0x4(%esp)
    2106:	00 
    2107:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    210e:	e8 e3 19 00 00       	call   3af6 <printf>
    exit();
    2113:	e8 71 18 00 00       	call   3989 <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2118:	c7 44 24 04 f6 46 00 	movl   $0x46f6,0x4(%esp)
    211f:	00 
    2120:	c7 04 24 62 46 00 00 	movl   $0x4662,(%esp)
    2127:	e8 bd 18 00 00       	call   39e9 <link>
    212c:	85 c0                	test   %eax,%eax
    212e:	75 19                	jne    2149 <subdir+0x4b9>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    2130:	c7 44 24 04 78 50 00 	movl   $0x5078,0x4(%esp)
    2137:	00 
    2138:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    213f:	e8 b2 19 00 00       	call   3af6 <printf>
    exit();
    2144:	e8 40 18 00 00       	call   3989 <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2149:	c7 44 24 04 f6 46 00 	movl   $0x46f6,0x4(%esp)
    2150:	00 
    2151:	c7 04 24 87 46 00 00 	movl   $0x4687,(%esp)
    2158:	e8 8c 18 00 00       	call   39e9 <link>
    215d:	85 c0                	test   %eax,%eax
    215f:	75 19                	jne    217a <subdir+0x4ea>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    2161:	c7 44 24 04 9c 50 00 	movl   $0x509c,0x4(%esp)
    2168:	00 
    2169:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2170:	e8 81 19 00 00       	call   3af6 <printf>
    exit();
    2175:	e8 0f 18 00 00       	call   3989 <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    217a:	c7 44 24 04 ae 45 00 	movl   $0x45ae,0x4(%esp)
    2181:	00 
    2182:	c7 04 24 4d 45 00 00 	movl   $0x454d,(%esp)
    2189:	e8 5b 18 00 00       	call   39e9 <link>
    218e:	85 c0                	test   %eax,%eax
    2190:	75 19                	jne    21ab <subdir+0x51b>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    2192:	c7 44 24 04 c0 50 00 	movl   $0x50c0,0x4(%esp)
    2199:	00 
    219a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21a1:	e8 50 19 00 00       	call   3af6 <printf>
    exit();
    21a6:	e8 de 17 00 00       	call   3989 <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    21ab:	c7 04 24 62 46 00 00 	movl   $0x4662,(%esp)
    21b2:	e8 3a 18 00 00       	call   39f1 <mkdir>
    21b7:	85 c0                	test   %eax,%eax
    21b9:	75 19                	jne    21d4 <subdir+0x544>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    21bb:	c7 44 24 04 ff 46 00 	movl   $0x46ff,0x4(%esp)
    21c2:	00 
    21c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21ca:	e8 27 19 00 00       	call   3af6 <printf>
    exit();
    21cf:	e8 b5 17 00 00       	call   3989 <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    21d4:	c7 04 24 87 46 00 00 	movl   $0x4687,(%esp)
    21db:	e8 11 18 00 00       	call   39f1 <mkdir>
    21e0:	85 c0                	test   %eax,%eax
    21e2:	75 19                	jne    21fd <subdir+0x56d>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    21e4:	c7 44 24 04 1a 47 00 	movl   $0x471a,0x4(%esp)
    21eb:	00 
    21ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21f3:	e8 fe 18 00 00       	call   3af6 <printf>
    exit();
    21f8:	e8 8c 17 00 00       	call   3989 <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    21fd:	c7 04 24 ae 45 00 00 	movl   $0x45ae,(%esp)
    2204:	e8 e8 17 00 00       	call   39f1 <mkdir>
    2209:	85 c0                	test   %eax,%eax
    220b:	75 19                	jne    2226 <subdir+0x596>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    220d:	c7 44 24 04 35 47 00 	movl   $0x4735,0x4(%esp)
    2214:	00 
    2215:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    221c:	e8 d5 18 00 00       	call   3af6 <printf>
    exit();
    2221:	e8 63 17 00 00       	call   3989 <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    2226:	c7 04 24 87 46 00 00 	movl   $0x4687,(%esp)
    222d:	e8 a7 17 00 00       	call   39d9 <unlink>
    2232:	85 c0                	test   %eax,%eax
    2234:	75 19                	jne    224f <subdir+0x5bf>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    2236:	c7 44 24 04 52 47 00 	movl   $0x4752,0x4(%esp)
    223d:	00 
    223e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2245:	e8 ac 18 00 00       	call   3af6 <printf>
    exit();
    224a:	e8 3a 17 00 00       	call   3989 <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    224f:	c7 04 24 62 46 00 00 	movl   $0x4662,(%esp)
    2256:	e8 7e 17 00 00       	call   39d9 <unlink>
    225b:	85 c0                	test   %eax,%eax
    225d:	75 19                	jne    2278 <subdir+0x5e8>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    225f:	c7 44 24 04 6e 47 00 	movl   $0x476e,0x4(%esp)
    2266:	00 
    2267:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    226e:	e8 83 18 00 00       	call   3af6 <printf>
    exit();
    2273:	e8 11 17 00 00       	call   3989 <exit>
  }
  if(chdir("dd/ff") == 0){
    2278:	c7 04 24 4d 45 00 00 	movl   $0x454d,(%esp)
    227f:	e8 75 17 00 00       	call   39f9 <chdir>
    2284:	85 c0                	test   %eax,%eax
    2286:	75 19                	jne    22a1 <subdir+0x611>
    printf(1, "chdir dd/ff succeeded!\n");
    2288:	c7 44 24 04 8a 47 00 	movl   $0x478a,0x4(%esp)
    228f:	00 
    2290:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2297:	e8 5a 18 00 00       	call   3af6 <printf>
    exit();
    229c:	e8 e8 16 00 00       	call   3989 <exit>
  }
  if(chdir("dd/xx") == 0){
    22a1:	c7 04 24 f9 46 00 00 	movl   $0x46f9,(%esp)
    22a8:	e8 4c 17 00 00       	call   39f9 <chdir>
    22ad:	85 c0                	test   %eax,%eax
    22af:	75 19                	jne    22ca <subdir+0x63a>
    printf(1, "chdir dd/xx succeeded!\n");
    22b1:	c7 44 24 04 a2 47 00 	movl   $0x47a2,0x4(%esp)
    22b8:	00 
    22b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22c0:	e8 31 18 00 00       	call   3af6 <printf>
    exit();
    22c5:	e8 bf 16 00 00       	call   3989 <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    22ca:	c7 04 24 ae 45 00 00 	movl   $0x45ae,(%esp)
    22d1:	e8 03 17 00 00       	call   39d9 <unlink>
    22d6:	85 c0                	test   %eax,%eax
    22d8:	74 19                	je     22f3 <subdir+0x663>
    printf(1, "unlink dd/dd/ff failed\n");
    22da:	c7 44 24 04 b9 45 00 	movl   $0x45b9,0x4(%esp)
    22e1:	00 
    22e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22e9:	e8 08 18 00 00       	call   3af6 <printf>
    exit();
    22ee:	e8 96 16 00 00       	call   3989 <exit>
  }
  if(unlink("dd/ff") != 0){
    22f3:	c7 04 24 4d 45 00 00 	movl   $0x454d,(%esp)
    22fa:	e8 da 16 00 00       	call   39d9 <unlink>
    22ff:	85 c0                	test   %eax,%eax
    2301:	74 19                	je     231c <subdir+0x68c>
    printf(1, "unlink dd/ff failed\n");
    2303:	c7 44 24 04 ba 47 00 	movl   $0x47ba,0x4(%esp)
    230a:	00 
    230b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2312:	e8 df 17 00 00       	call   3af6 <printf>
    exit();
    2317:	e8 6d 16 00 00       	call   3989 <exit>
  }
  if(unlink("dd") == 0){
    231c:	c7 04 24 14 46 00 00 	movl   $0x4614,(%esp)
    2323:	e8 b1 16 00 00       	call   39d9 <unlink>
    2328:	85 c0                	test   %eax,%eax
    232a:	75 19                	jne    2345 <subdir+0x6b5>
    printf(1, "unlink non-empty dd succeeded!\n");
    232c:	c7 44 24 04 e4 50 00 	movl   $0x50e4,0x4(%esp)
    2333:	00 
    2334:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    233b:	e8 b6 17 00 00       	call   3af6 <printf>
    exit();
    2340:	e8 44 16 00 00       	call   3989 <exit>
  }
  if(unlink("dd/dd") < 0){
    2345:	c7 04 24 29 45 00 00 	movl   $0x4529,(%esp)
    234c:	e8 88 16 00 00       	call   39d9 <unlink>
    2351:	85 c0                	test   %eax,%eax
    2353:	79 19                	jns    236e <subdir+0x6de>
    printf(1, "unlink dd/dd failed\n");
    2355:	c7 44 24 04 cf 47 00 	movl   $0x47cf,0x4(%esp)
    235c:	00 
    235d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2364:	e8 8d 17 00 00       	call   3af6 <printf>
    exit();
    2369:	e8 1b 16 00 00       	call   3989 <exit>
  }
  if(unlink("dd") < 0){
    236e:	c7 04 24 14 46 00 00 	movl   $0x4614,(%esp)
    2375:	e8 5f 16 00 00       	call   39d9 <unlink>
    237a:	85 c0                	test   %eax,%eax
    237c:	79 19                	jns    2397 <subdir+0x707>
    printf(1, "unlink dd failed\n");
    237e:	c7 44 24 04 e4 47 00 	movl   $0x47e4,0x4(%esp)
    2385:	00 
    2386:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    238d:	e8 64 17 00 00       	call   3af6 <printf>
    exit();
    2392:	e8 f2 15 00 00       	call   3989 <exit>
  }

  printf(1, "subdir ok\n");
    2397:	c7 44 24 04 f6 47 00 	movl   $0x47f6,0x4(%esp)
    239e:	00 
    239f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23a6:	e8 4b 17 00 00       	call   3af6 <printf>
}
    23ab:	83 c4 14             	add    $0x14,%esp
    23ae:	5b                   	pop    %ebx
    23af:	5d                   	pop    %ebp
    23b0:	c3                   	ret    

000023b1 <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    23b1:	55                   	push   %ebp
    23b2:	89 e5                	mov    %esp,%ebp
    23b4:	57                   	push   %edi
    23b5:	56                   	push   %esi
    23b6:	53                   	push   %ebx
    23b7:	83 ec 1c             	sub    $0x1c,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    23ba:	c7 44 24 04 01 48 00 	movl   $0x4801,0x4(%esp)
    23c1:	00 
    23c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23c9:	e8 28 17 00 00       	call   3af6 <printf>

  unlink("bigwrite");
    23ce:	c7 04 24 10 48 00 00 	movl   $0x4810,(%esp)
    23d5:	e8 ff 15 00 00       	call   39d9 <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    23da:	be f3 01 00 00       	mov    $0x1f3,%esi
    23df:	e9 95 00 00 00       	jmp    2479 <bigwrite+0xc8>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    23e4:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    23eb:	00 
    23ec:	c7 04 24 10 48 00 00 	movl   $0x4810,(%esp)
    23f3:	e8 d1 15 00 00       	call   39c9 <open>
    23f8:	89 c7                	mov    %eax,%edi
    if(fd < 0){
    23fa:	85 c0                	test   %eax,%eax
    23fc:	79 57                	jns    2455 <bigwrite+0xa4>
      printf(1, "cannot create bigwrite\n");
    23fe:	c7 44 24 04 19 48 00 	movl   $0x4819,0x4(%esp)
    2405:	00 
    2406:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    240d:	e8 e4 16 00 00       	call   3af6 <printf>
      exit();
    2412:	e8 72 15 00 00       	call   3989 <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
      int cc = write(fd, buf, sz);
    2417:	89 74 24 08          	mov    %esi,0x8(%esp)
    241b:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
    2422:	00 
    2423:	89 3c 24             	mov    %edi,(%esp)
    2426:	e8 7e 15 00 00       	call   39a9 <write>
      if(cc != sz){
    242b:	39 f0                	cmp    %esi,%eax
    242d:	74 21                	je     2450 <bigwrite+0x9f>
        printf(1, "write(%d) ret %d\n", sz, cc);
    242f:	89 44 24 0c          	mov    %eax,0xc(%esp)
    2433:	89 74 24 08          	mov    %esi,0x8(%esp)
    2437:	c7 44 24 04 31 48 00 	movl   $0x4831,0x4(%esp)
    243e:	00 
    243f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2446:	e8 ab 16 00 00       	call   3af6 <printf>
        exit();
    244b:	e8 39 15 00 00       	call   3989 <exit>
    for(i = 0; i < 2; i++){
    2450:	83 c3 01             	add    $0x1,%ebx
    2453:	eb 05                	jmp    245a <bigwrite+0xa9>
    2455:	bb 00 00 00 00       	mov    $0x0,%ebx
    245a:	83 fb 01             	cmp    $0x1,%ebx
    245d:	7e b8                	jle    2417 <bigwrite+0x66>
      }
    }
    close(fd);
    245f:	89 3c 24             	mov    %edi,(%esp)
    2462:	e8 4a 15 00 00       	call   39b1 <close>
    unlink("bigwrite");
    2467:	c7 04 24 10 48 00 00 	movl   $0x4810,(%esp)
    246e:	e8 66 15 00 00       	call   39d9 <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    2473:	81 c6 d7 01 00 00    	add    $0x1d7,%esi
    2479:	81 fe ff 17 00 00    	cmp    $0x17ff,%esi
    247f:	0f 8e 5f ff ff ff    	jle    23e4 <bigwrite+0x33>
  }

  printf(1, "bigwrite ok\n");
    2485:	c7 44 24 04 43 48 00 	movl   $0x4843,0x4(%esp)
    248c:	00 
    248d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2494:	e8 5d 16 00 00       	call   3af6 <printf>
}
    2499:	83 c4 1c             	add    $0x1c,%esp
    249c:	5b                   	pop    %ebx
    249d:	5e                   	pop    %esi
    249e:	5f                   	pop    %edi
    249f:	5d                   	pop    %ebp
    24a0:	c3                   	ret    

000024a1 <bigfile>:

void
bigfile(void)
{
    24a1:	55                   	push   %ebp
    24a2:	89 e5                	mov    %esp,%ebp
    24a4:	57                   	push   %edi
    24a5:	56                   	push   %esi
    24a6:	53                   	push   %ebx
    24a7:	83 ec 1c             	sub    $0x1c,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    24aa:	c7 44 24 04 50 48 00 	movl   $0x4850,0x4(%esp)
    24b1:	00 
    24b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24b9:	e8 38 16 00 00       	call   3af6 <printf>

  unlink("bigfile");
    24be:	c7 04 24 6c 48 00 00 	movl   $0x486c,(%esp)
    24c5:	e8 0f 15 00 00       	call   39d9 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    24ca:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    24d1:	00 
    24d2:	c7 04 24 6c 48 00 00 	movl   $0x486c,(%esp)
    24d9:	e8 eb 14 00 00       	call   39c9 <open>
    24de:	89 c6                	mov    %eax,%esi
  if(fd < 0){
    24e0:	85 c0                	test   %eax,%eax
    24e2:	79 6e                	jns    2552 <bigfile+0xb1>
    printf(1, "cannot create bigfile");
    24e4:	c7 44 24 04 5e 48 00 	movl   $0x485e,0x4(%esp)
    24eb:	00 
    24ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24f3:	e8 fe 15 00 00       	call   3af6 <printf>
    exit();
    24f8:	e8 8c 14 00 00       	call   3989 <exit>
  }
  for(i = 0; i < 20; i++){
    memset(buf, i, 600);
    24fd:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    2504:	00 
    2505:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    2509:	c7 04 24 a0 7d 00 00 	movl   $0x7da0,(%esp)
    2510:	e8 39 13 00 00       	call   384e <memset>
    if(write(fd, buf, 600) != 600){
    2515:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    251c:	00 
    251d:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
    2524:	00 
    2525:	89 34 24             	mov    %esi,(%esp)
    2528:	e8 7c 14 00 00       	call   39a9 <write>
    252d:	3d 58 02 00 00       	cmp    $0x258,%eax
    2532:	74 19                	je     254d <bigfile+0xac>
      printf(1, "write bigfile failed\n");
    2534:	c7 44 24 04 74 48 00 	movl   $0x4874,0x4(%esp)
    253b:	00 
    253c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2543:	e8 ae 15 00 00       	call   3af6 <printf>
      exit();
    2548:	e8 3c 14 00 00       	call   3989 <exit>
  for(i = 0; i < 20; i++){
    254d:	83 c3 01             	add    $0x1,%ebx
    2550:	eb 05                	jmp    2557 <bigfile+0xb6>
    2552:	bb 00 00 00 00       	mov    $0x0,%ebx
    2557:	83 fb 13             	cmp    $0x13,%ebx
    255a:	7e a1                	jle    24fd <bigfile+0x5c>
    }
  }
  close(fd);
    255c:	89 34 24             	mov    %esi,(%esp)
    255f:	e8 4d 14 00 00       	call   39b1 <close>

  fd = open("bigfile", 0);
    2564:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    256b:	00 
    256c:	c7 04 24 6c 48 00 00 	movl   $0x486c,(%esp)
    2573:	e8 51 14 00 00       	call   39c9 <open>
    2578:	89 c7                	mov    %eax,%edi
  if(fd < 0){
    257a:	85 c0                	test   %eax,%eax
    257c:	79 19                	jns    2597 <bigfile+0xf6>
    printf(1, "cannot open bigfile\n");
    257e:	c7 44 24 04 8a 48 00 	movl   $0x488a,0x4(%esp)
    2585:	00 
    2586:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    258d:	e8 64 15 00 00       	call   3af6 <printf>
    exit();
    2592:	e8 f2 13 00 00       	call   3989 <exit>
    2597:	be 00 00 00 00       	mov    $0x0,%esi
    259c:	bb 00 00 00 00       	mov    $0x0,%ebx
  }
  total = 0;
  for(i = 0; ; i++){
    cc = read(fd, buf, 300);
    25a1:	c7 44 24 08 2c 01 00 	movl   $0x12c,0x8(%esp)
    25a8:	00 
    25a9:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
    25b0:	00 
    25b1:	89 3c 24             	mov    %edi,(%esp)
    25b4:	e8 e8 13 00 00       	call   39a1 <read>
    if(cc < 0){
    25b9:	85 c0                	test   %eax,%eax
    25bb:	79 19                	jns    25d6 <bigfile+0x135>
      printf(1, "read bigfile failed\n");
    25bd:	c7 44 24 04 9f 48 00 	movl   $0x489f,0x4(%esp)
    25c4:	00 
    25c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25cc:	e8 25 15 00 00       	call   3af6 <printf>
      exit();
    25d1:	e8 b3 13 00 00       	call   3989 <exit>
    }
    if(cc == 0)
    25d6:	85 c0                	test   %eax,%eax
    25d8:	74 62                	je     263c <bigfile+0x19b>
      break;
    if(cc != 300){
    25da:	3d 2c 01 00 00       	cmp    $0x12c,%eax
    25df:	74 19                	je     25fa <bigfile+0x159>
      printf(1, "short read bigfile\n");
    25e1:	c7 44 24 04 b4 48 00 	movl   $0x48b4,0x4(%esp)
    25e8:	00 
    25e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25f0:	e8 01 15 00 00       	call   3af6 <printf>
      exit();
    25f5:	e8 8f 13 00 00       	call   3989 <exit>
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    25fa:	0f be 0d a0 7d 00 00 	movsbl 0x7da0,%ecx
    2601:	89 da                	mov    %ebx,%edx
    2603:	c1 ea 1f             	shr    $0x1f,%edx
    2606:	01 da                	add    %ebx,%edx
    2608:	d1 fa                	sar    %edx
    260a:	39 d1                	cmp    %edx,%ecx
    260c:	75 0b                	jne    2619 <bigfile+0x178>
    260e:	0f be 0d cb 7e 00 00 	movsbl 0x7ecb,%ecx
    2615:	39 ca                	cmp    %ecx,%edx
    2617:	74 19                	je     2632 <bigfile+0x191>
      printf(1, "read bigfile wrong data\n");
    2619:	c7 44 24 04 c8 48 00 	movl   $0x48c8,0x4(%esp)
    2620:	00 
    2621:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2628:	e8 c9 14 00 00       	call   3af6 <printf>
      exit();
    262d:	e8 57 13 00 00       	call   3989 <exit>
    }
    total += cc;
    2632:	01 c6                	add    %eax,%esi
  for(i = 0; ; i++){
    2634:	83 c3 01             	add    $0x1,%ebx
  }
    2637:	e9 65 ff ff ff       	jmp    25a1 <bigfile+0x100>
  close(fd);
    263c:	89 3c 24             	mov    %edi,(%esp)
    263f:	e8 6d 13 00 00       	call   39b1 <close>
  if(total != 20*600){
    2644:	81 fe e0 2e 00 00    	cmp    $0x2ee0,%esi
    264a:	74 19                	je     2665 <bigfile+0x1c4>
    printf(1, "read bigfile wrong total\n");
    264c:	c7 44 24 04 e1 48 00 	movl   $0x48e1,0x4(%esp)
    2653:	00 
    2654:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    265b:	e8 96 14 00 00       	call   3af6 <printf>
    exit();
    2660:	e8 24 13 00 00       	call   3989 <exit>
  }
  unlink("bigfile");
    2665:	c7 04 24 6c 48 00 00 	movl   $0x486c,(%esp)
    266c:	e8 68 13 00 00       	call   39d9 <unlink>

  printf(1, "bigfile test ok\n");
    2671:	c7 44 24 04 fb 48 00 	movl   $0x48fb,0x4(%esp)
    2678:	00 
    2679:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2680:	e8 71 14 00 00       	call   3af6 <printf>
}
    2685:	83 c4 1c             	add    $0x1c,%esp
    2688:	5b                   	pop    %ebx
    2689:	5e                   	pop    %esi
    268a:	5f                   	pop    %edi
    268b:	5d                   	pop    %ebp
    268c:	c3                   	ret    

0000268d <fourteen>:

void
fourteen(void)
{
    268d:	55                   	push   %ebp
    268e:	89 e5                	mov    %esp,%ebp
    2690:	83 ec 18             	sub    $0x18,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    2693:	c7 44 24 04 0c 49 00 	movl   $0x490c,0x4(%esp)
    269a:	00 
    269b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26a2:	e8 4f 14 00 00       	call   3af6 <printf>

  if(mkdir("12345678901234") != 0){
    26a7:	c7 04 24 47 49 00 00 	movl   $0x4947,(%esp)
    26ae:	e8 3e 13 00 00       	call   39f1 <mkdir>
    26b3:	85 c0                	test   %eax,%eax
    26b5:	74 19                	je     26d0 <fourteen+0x43>
    printf(1, "mkdir 12345678901234 failed\n");
    26b7:	c7 44 24 04 1b 49 00 	movl   $0x491b,0x4(%esp)
    26be:	00 
    26bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26c6:	e8 2b 14 00 00       	call   3af6 <printf>
    exit();
    26cb:	e8 b9 12 00 00       	call   3989 <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    26d0:	c7 04 24 04 51 00 00 	movl   $0x5104,(%esp)
    26d7:	e8 15 13 00 00       	call   39f1 <mkdir>
    26dc:	85 c0                	test   %eax,%eax
    26de:	74 19                	je     26f9 <fourteen+0x6c>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    26e0:	c7 44 24 04 24 51 00 	movl   $0x5124,0x4(%esp)
    26e7:	00 
    26e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26ef:	e8 02 14 00 00       	call   3af6 <printf>
    exit();
    26f4:	e8 90 12 00 00       	call   3989 <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    26f9:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2700:	00 
    2701:	c7 04 24 54 51 00 00 	movl   $0x5154,(%esp)
    2708:	e8 bc 12 00 00       	call   39c9 <open>
  if(fd < 0){
    270d:	85 c0                	test   %eax,%eax
    270f:	79 19                	jns    272a <fourteen+0x9d>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    2711:	c7 44 24 04 84 51 00 	movl   $0x5184,0x4(%esp)
    2718:	00 
    2719:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2720:	e8 d1 13 00 00       	call   3af6 <printf>
    exit();
    2725:	e8 5f 12 00 00       	call   3989 <exit>
  }
  close(fd);
    272a:	89 04 24             	mov    %eax,(%esp)
    272d:	e8 7f 12 00 00       	call   39b1 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2732:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2739:	00 
    273a:	c7 04 24 c4 51 00 00 	movl   $0x51c4,(%esp)
    2741:	e8 83 12 00 00       	call   39c9 <open>
  if(fd < 0){
    2746:	85 c0                	test   %eax,%eax
    2748:	79 19                	jns    2763 <fourteen+0xd6>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    274a:	c7 44 24 04 f4 51 00 	movl   $0x51f4,0x4(%esp)
    2751:	00 
    2752:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2759:	e8 98 13 00 00       	call   3af6 <printf>
    exit();
    275e:	e8 26 12 00 00       	call   3989 <exit>
  }
  close(fd);
    2763:	89 04 24             	mov    %eax,(%esp)
    2766:	e8 46 12 00 00       	call   39b1 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    276b:	c7 04 24 38 49 00 00 	movl   $0x4938,(%esp)
    2772:	e8 7a 12 00 00       	call   39f1 <mkdir>
    2777:	85 c0                	test   %eax,%eax
    2779:	75 19                	jne    2794 <fourteen+0x107>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    277b:	c7 44 24 04 30 52 00 	movl   $0x5230,0x4(%esp)
    2782:	00 
    2783:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    278a:	e8 67 13 00 00       	call   3af6 <printf>
    exit();
    278f:	e8 f5 11 00 00       	call   3989 <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    2794:	c7 04 24 60 52 00 00 	movl   $0x5260,(%esp)
    279b:	e8 51 12 00 00       	call   39f1 <mkdir>
    27a0:	85 c0                	test   %eax,%eax
    27a2:	75 19                	jne    27bd <fourteen+0x130>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    27a4:	c7 44 24 04 80 52 00 	movl   $0x5280,0x4(%esp)
    27ab:	00 
    27ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27b3:	e8 3e 13 00 00       	call   3af6 <printf>
    exit();
    27b8:	e8 cc 11 00 00       	call   3989 <exit>
  }

  printf(1, "fourteen ok\n");
    27bd:	c7 44 24 04 56 49 00 	movl   $0x4956,0x4(%esp)
    27c4:	00 
    27c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27cc:	e8 25 13 00 00       	call   3af6 <printf>
}
    27d1:	c9                   	leave  
    27d2:	c3                   	ret    

000027d3 <rmdot>:

void
rmdot(void)
{
    27d3:	55                   	push   %ebp
    27d4:	89 e5                	mov    %esp,%ebp
    27d6:	83 ec 18             	sub    $0x18,%esp
  printf(1, "rmdot test\n");
    27d9:	c7 44 24 04 63 49 00 	movl   $0x4963,0x4(%esp)
    27e0:	00 
    27e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27e8:	e8 09 13 00 00       	call   3af6 <printf>
  if(mkdir("dots") != 0){
    27ed:	c7 04 24 6f 49 00 00 	movl   $0x496f,(%esp)
    27f4:	e8 f8 11 00 00       	call   39f1 <mkdir>
    27f9:	85 c0                	test   %eax,%eax
    27fb:	74 19                	je     2816 <rmdot+0x43>
    printf(1, "mkdir dots failed\n");
    27fd:	c7 44 24 04 74 49 00 	movl   $0x4974,0x4(%esp)
    2804:	00 
    2805:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    280c:	e8 e5 12 00 00       	call   3af6 <printf>
    exit();
    2811:	e8 73 11 00 00       	call   3989 <exit>
  }
  if(chdir("dots") != 0){
    2816:	c7 04 24 6f 49 00 00 	movl   $0x496f,(%esp)
    281d:	e8 d7 11 00 00       	call   39f9 <chdir>
    2822:	85 c0                	test   %eax,%eax
    2824:	74 19                	je     283f <rmdot+0x6c>
    printf(1, "chdir dots failed\n");
    2826:	c7 44 24 04 87 49 00 	movl   $0x4987,0x4(%esp)
    282d:	00 
    282e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2835:	e8 bc 12 00 00       	call   3af6 <printf>
    exit();
    283a:	e8 4a 11 00 00       	call   3989 <exit>
  }
  if(unlink(".") == 0){
    283f:	c7 04 24 1a 46 00 00 	movl   $0x461a,(%esp)
    2846:	e8 8e 11 00 00       	call   39d9 <unlink>
    284b:	85 c0                	test   %eax,%eax
    284d:	75 19                	jne    2868 <rmdot+0x95>
    printf(1, "rm . worked!\n");
    284f:	c7 44 24 04 9a 49 00 	movl   $0x499a,0x4(%esp)
    2856:	00 
    2857:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    285e:	e8 93 12 00 00       	call   3af6 <printf>
    exit();
    2863:	e8 21 11 00 00       	call   3989 <exit>
  }
  if(unlink("..") == 0){
    2868:	c7 04 24 19 46 00 00 	movl   $0x4619,(%esp)
    286f:	e8 65 11 00 00       	call   39d9 <unlink>
    2874:	85 c0                	test   %eax,%eax
    2876:	75 19                	jne    2891 <rmdot+0xbe>
    printf(1, "rm .. worked!\n");
    2878:	c7 44 24 04 a8 49 00 	movl   $0x49a8,0x4(%esp)
    287f:	00 
    2880:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2887:	e8 6a 12 00 00       	call   3af6 <printf>
    exit();
    288c:	e8 f8 10 00 00       	call   3989 <exit>
  }
  if(chdir("/") != 0){
    2891:	c7 04 24 ed 3d 00 00 	movl   $0x3ded,(%esp)
    2898:	e8 5c 11 00 00       	call   39f9 <chdir>
    289d:	85 c0                	test   %eax,%eax
    289f:	74 19                	je     28ba <rmdot+0xe7>
    printf(1, "chdir / failed\n");
    28a1:	c7 44 24 04 ef 3d 00 	movl   $0x3def,0x4(%esp)
    28a8:	00 
    28a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28b0:	e8 41 12 00 00       	call   3af6 <printf>
    exit();
    28b5:	e8 cf 10 00 00       	call   3989 <exit>
  }
  if(unlink("dots/.") == 0){
    28ba:	c7 04 24 b7 49 00 00 	movl   $0x49b7,(%esp)
    28c1:	e8 13 11 00 00       	call   39d9 <unlink>
    28c6:	85 c0                	test   %eax,%eax
    28c8:	75 19                	jne    28e3 <rmdot+0x110>
    printf(1, "unlink dots/. worked!\n");
    28ca:	c7 44 24 04 be 49 00 	movl   $0x49be,0x4(%esp)
    28d1:	00 
    28d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28d9:	e8 18 12 00 00       	call   3af6 <printf>
    exit();
    28de:	e8 a6 10 00 00       	call   3989 <exit>
  }
  if(unlink("dots/..") == 0){
    28e3:	c7 04 24 d5 49 00 00 	movl   $0x49d5,(%esp)
    28ea:	e8 ea 10 00 00       	call   39d9 <unlink>
    28ef:	85 c0                	test   %eax,%eax
    28f1:	75 19                	jne    290c <rmdot+0x139>
    printf(1, "unlink dots/.. worked!\n");
    28f3:	c7 44 24 04 dd 49 00 	movl   $0x49dd,0x4(%esp)
    28fa:	00 
    28fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2902:	e8 ef 11 00 00       	call   3af6 <printf>
    exit();
    2907:	e8 7d 10 00 00       	call   3989 <exit>
  }
  if(unlink("dots") != 0){
    290c:	c7 04 24 6f 49 00 00 	movl   $0x496f,(%esp)
    2913:	e8 c1 10 00 00       	call   39d9 <unlink>
    2918:	85 c0                	test   %eax,%eax
    291a:	74 19                	je     2935 <rmdot+0x162>
    printf(1, "unlink dots failed!\n");
    291c:	c7 44 24 04 f5 49 00 	movl   $0x49f5,0x4(%esp)
    2923:	00 
    2924:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    292b:	e8 c6 11 00 00       	call   3af6 <printf>
    exit();
    2930:	e8 54 10 00 00       	call   3989 <exit>
  }
  printf(1, "rmdot ok\n");
    2935:	c7 44 24 04 0a 4a 00 	movl   $0x4a0a,0x4(%esp)
    293c:	00 
    293d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2944:	e8 ad 11 00 00       	call   3af6 <printf>
}
    2949:	c9                   	leave  
    294a:	c3                   	ret    

0000294b <dirfile>:

void
dirfile(void)
{
    294b:	55                   	push   %ebp
    294c:	89 e5                	mov    %esp,%ebp
    294e:	53                   	push   %ebx
    294f:	83 ec 14             	sub    $0x14,%esp
  int fd;

  printf(1, "dir vs file\n");
    2952:	c7 44 24 04 14 4a 00 	movl   $0x4a14,0x4(%esp)
    2959:	00 
    295a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2961:	e8 90 11 00 00       	call   3af6 <printf>

  fd = open("dirfile", O_CREATE);
    2966:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    296d:	00 
    296e:	c7 04 24 21 4a 00 00 	movl   $0x4a21,(%esp)
    2975:	e8 4f 10 00 00       	call   39c9 <open>
  if(fd < 0){
    297a:	85 c0                	test   %eax,%eax
    297c:	79 19                	jns    2997 <dirfile+0x4c>
    printf(1, "create dirfile failed\n");
    297e:	c7 44 24 04 29 4a 00 	movl   $0x4a29,0x4(%esp)
    2985:	00 
    2986:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    298d:	e8 64 11 00 00       	call   3af6 <printf>
    exit();
    2992:	e8 f2 0f 00 00       	call   3989 <exit>
  }
  close(fd);
    2997:	89 04 24             	mov    %eax,(%esp)
    299a:	e8 12 10 00 00       	call   39b1 <close>
  if(chdir("dirfile") == 0){
    299f:	c7 04 24 21 4a 00 00 	movl   $0x4a21,(%esp)
    29a6:	e8 4e 10 00 00       	call   39f9 <chdir>
    29ab:	85 c0                	test   %eax,%eax
    29ad:	75 19                	jne    29c8 <dirfile+0x7d>
    printf(1, "chdir dirfile succeeded!\n");
    29af:	c7 44 24 04 40 4a 00 	movl   $0x4a40,0x4(%esp)
    29b6:	00 
    29b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29be:	e8 33 11 00 00       	call   3af6 <printf>
    exit();
    29c3:	e8 c1 0f 00 00       	call   3989 <exit>
  }
  fd = open("dirfile/xx", 0);
    29c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    29cf:	00 
    29d0:	c7 04 24 5a 4a 00 00 	movl   $0x4a5a,(%esp)
    29d7:	e8 ed 0f 00 00       	call   39c9 <open>
  if(fd >= 0){
    29dc:	85 c0                	test   %eax,%eax
    29de:	78 19                	js     29f9 <dirfile+0xae>
    printf(1, "create dirfile/xx succeeded!\n");
    29e0:	c7 44 24 04 65 4a 00 	movl   $0x4a65,0x4(%esp)
    29e7:	00 
    29e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29ef:	e8 02 11 00 00       	call   3af6 <printf>
    exit();
    29f4:	e8 90 0f 00 00       	call   3989 <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    29f9:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2a00:	00 
    2a01:	c7 04 24 5a 4a 00 00 	movl   $0x4a5a,(%esp)
    2a08:	e8 bc 0f 00 00       	call   39c9 <open>
  if(fd >= 0){
    2a0d:	85 c0                	test   %eax,%eax
    2a0f:	78 19                	js     2a2a <dirfile+0xdf>
    printf(1, "create dirfile/xx succeeded!\n");
    2a11:	c7 44 24 04 65 4a 00 	movl   $0x4a65,0x4(%esp)
    2a18:	00 
    2a19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a20:	e8 d1 10 00 00       	call   3af6 <printf>
    exit();
    2a25:	e8 5f 0f 00 00       	call   3989 <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    2a2a:	c7 04 24 5a 4a 00 00 	movl   $0x4a5a,(%esp)
    2a31:	e8 bb 0f 00 00       	call   39f1 <mkdir>
    2a36:	85 c0                	test   %eax,%eax
    2a38:	75 19                	jne    2a53 <dirfile+0x108>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    2a3a:	c7 44 24 04 83 4a 00 	movl   $0x4a83,0x4(%esp)
    2a41:	00 
    2a42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a49:	e8 a8 10 00 00       	call   3af6 <printf>
    exit();
    2a4e:	e8 36 0f 00 00       	call   3989 <exit>
  }
  if(unlink("dirfile/xx") == 0){
    2a53:	c7 04 24 5a 4a 00 00 	movl   $0x4a5a,(%esp)
    2a5a:	e8 7a 0f 00 00       	call   39d9 <unlink>
    2a5f:	85 c0                	test   %eax,%eax
    2a61:	75 19                	jne    2a7c <dirfile+0x131>
    printf(1, "unlink dirfile/xx succeeded!\n");
    2a63:	c7 44 24 04 a0 4a 00 	movl   $0x4aa0,0x4(%esp)
    2a6a:	00 
    2a6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a72:	e8 7f 10 00 00       	call   3af6 <printf>
    exit();
    2a77:	e8 0d 0f 00 00       	call   3989 <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    2a7c:	c7 44 24 04 5a 4a 00 	movl   $0x4a5a,0x4(%esp)
    2a83:	00 
    2a84:	c7 04 24 be 4a 00 00 	movl   $0x4abe,(%esp)
    2a8b:	e8 59 0f 00 00       	call   39e9 <link>
    2a90:	85 c0                	test   %eax,%eax
    2a92:	75 19                	jne    2aad <dirfile+0x162>
    printf(1, "link to dirfile/xx succeeded!\n");
    2a94:	c7 44 24 04 b4 52 00 	movl   $0x52b4,0x4(%esp)
    2a9b:	00 
    2a9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2aa3:	e8 4e 10 00 00       	call   3af6 <printf>
    exit();
    2aa8:	e8 dc 0e 00 00       	call   3989 <exit>
  }
  if(unlink("dirfile") != 0){
    2aad:	c7 04 24 21 4a 00 00 	movl   $0x4a21,(%esp)
    2ab4:	e8 20 0f 00 00       	call   39d9 <unlink>
    2ab9:	85 c0                	test   %eax,%eax
    2abb:	74 19                	je     2ad6 <dirfile+0x18b>
    printf(1, "unlink dirfile failed!\n");
    2abd:	c7 44 24 04 c5 4a 00 	movl   $0x4ac5,0x4(%esp)
    2ac4:	00 
    2ac5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2acc:	e8 25 10 00 00       	call   3af6 <printf>
    exit();
    2ad1:	e8 b3 0e 00 00       	call   3989 <exit>
  }

  fd = open(".", O_RDWR);
    2ad6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    2add:	00 
    2ade:	c7 04 24 1a 46 00 00 	movl   $0x461a,(%esp)
    2ae5:	e8 df 0e 00 00       	call   39c9 <open>
  if(fd >= 0){
    2aea:	85 c0                	test   %eax,%eax
    2aec:	78 19                	js     2b07 <dirfile+0x1bc>
    printf(1, "open . for writing succeeded!\n");
    2aee:	c7 44 24 04 d4 52 00 	movl   $0x52d4,0x4(%esp)
    2af5:	00 
    2af6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2afd:	e8 f4 0f 00 00       	call   3af6 <printf>
    exit();
    2b02:	e8 82 0e 00 00       	call   3989 <exit>
  }
  fd = open(".", 0);
    2b07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2b0e:	00 
    2b0f:	c7 04 24 1a 46 00 00 	movl   $0x461a,(%esp)
    2b16:	e8 ae 0e 00 00       	call   39c9 <open>
    2b1b:	89 c3                	mov    %eax,%ebx
  if(write(fd, "x", 1) > 0){
    2b1d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    2b24:	00 
    2b25:	c7 44 24 04 fd 46 00 	movl   $0x46fd,0x4(%esp)
    2b2c:	00 
    2b2d:	89 04 24             	mov    %eax,(%esp)
    2b30:	e8 74 0e 00 00       	call   39a9 <write>
    2b35:	85 c0                	test   %eax,%eax
    2b37:	7e 19                	jle    2b52 <dirfile+0x207>
    printf(1, "write . succeeded!\n");
    2b39:	c7 44 24 04 dd 4a 00 	movl   $0x4add,0x4(%esp)
    2b40:	00 
    2b41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b48:	e8 a9 0f 00 00       	call   3af6 <printf>
    exit();
    2b4d:	e8 37 0e 00 00       	call   3989 <exit>
  }
  close(fd);
    2b52:	89 1c 24             	mov    %ebx,(%esp)
    2b55:	e8 57 0e 00 00       	call   39b1 <close>

  printf(1, "dir vs file OK\n");
    2b5a:	c7 44 24 04 f1 4a 00 	movl   $0x4af1,0x4(%esp)
    2b61:	00 
    2b62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b69:	e8 88 0f 00 00       	call   3af6 <printf>
}
    2b6e:	83 c4 14             	add    $0x14,%esp
    2b71:	5b                   	pop    %ebx
    2b72:	5d                   	pop    %ebp
    2b73:	c3                   	ret    

00002b74 <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    2b74:	55                   	push   %ebp
    2b75:	89 e5                	mov    %esp,%ebp
    2b77:	53                   	push   %ebx
    2b78:	83 ec 14             	sub    $0x14,%esp
  int i, fd;

  printf(1, "empty file name\n");
    2b7b:	c7 44 24 04 01 4b 00 	movl   $0x4b01,0x4(%esp)
    2b82:	00 
    2b83:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b8a:	e8 67 0f 00 00       	call   3af6 <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2b8f:	bb 00 00 00 00       	mov    $0x0,%ebx
    2b94:	e9 c1 00 00 00       	jmp    2c5a <iref+0xe6>
    if(mkdir("irefd") != 0){
    2b99:	c7 04 24 12 4b 00 00 	movl   $0x4b12,(%esp)
    2ba0:	e8 4c 0e 00 00       	call   39f1 <mkdir>
    2ba5:	85 c0                	test   %eax,%eax
    2ba7:	74 19                	je     2bc2 <iref+0x4e>
      printf(1, "mkdir irefd failed\n");
    2ba9:	c7 44 24 04 18 4b 00 	movl   $0x4b18,0x4(%esp)
    2bb0:	00 
    2bb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bb8:	e8 39 0f 00 00       	call   3af6 <printf>
      exit();
    2bbd:	e8 c7 0d 00 00       	call   3989 <exit>
    }
    if(chdir("irefd") != 0){
    2bc2:	c7 04 24 12 4b 00 00 	movl   $0x4b12,(%esp)
    2bc9:	e8 2b 0e 00 00       	call   39f9 <chdir>
    2bce:	85 c0                	test   %eax,%eax
    2bd0:	74 19                	je     2beb <iref+0x77>
      printf(1, "chdir irefd failed\n");
    2bd2:	c7 44 24 04 2c 4b 00 	movl   $0x4b2c,0x4(%esp)
    2bd9:	00 
    2bda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2be1:	e8 10 0f 00 00       	call   3af6 <printf>
      exit();
    2be6:	e8 9e 0d 00 00       	call   3989 <exit>
    }

    mkdir("");
    2beb:	c7 04 24 c7 41 00 00 	movl   $0x41c7,(%esp)
    2bf2:	e8 fa 0d 00 00       	call   39f1 <mkdir>
    link("README", "");
    2bf7:	c7 44 24 04 c7 41 00 	movl   $0x41c7,0x4(%esp)
    2bfe:	00 
    2bff:	c7 04 24 be 4a 00 00 	movl   $0x4abe,(%esp)
    2c06:	e8 de 0d 00 00       	call   39e9 <link>
    fd = open("", O_CREATE);
    2c0b:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2c12:	00 
    2c13:	c7 04 24 c7 41 00 00 	movl   $0x41c7,(%esp)
    2c1a:	e8 aa 0d 00 00       	call   39c9 <open>
    if(fd >= 0)
    2c1f:	85 c0                	test   %eax,%eax
    2c21:	78 08                	js     2c2b <iref+0xb7>
      close(fd);
    2c23:	89 04 24             	mov    %eax,(%esp)
    2c26:	e8 86 0d 00 00       	call   39b1 <close>
    fd = open("xx", O_CREATE);
    2c2b:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2c32:	00 
    2c33:	c7 04 24 fc 46 00 00 	movl   $0x46fc,(%esp)
    2c3a:	e8 8a 0d 00 00       	call   39c9 <open>
    if(fd >= 0)
    2c3f:	85 c0                	test   %eax,%eax
    2c41:	78 08                	js     2c4b <iref+0xd7>
      close(fd);
    2c43:	89 04 24             	mov    %eax,(%esp)
    2c46:	e8 66 0d 00 00       	call   39b1 <close>
    unlink("xx");
    2c4b:	c7 04 24 fc 46 00 00 	movl   $0x46fc,(%esp)
    2c52:	e8 82 0d 00 00       	call   39d9 <unlink>
  for(i = 0; i < 50 + 1; i++){
    2c57:	83 c3 01             	add    $0x1,%ebx
    2c5a:	83 fb 32             	cmp    $0x32,%ebx
    2c5d:	0f 8e 36 ff ff ff    	jle    2b99 <iref+0x25>
  }

  chdir("/");
    2c63:	c7 04 24 ed 3d 00 00 	movl   $0x3ded,(%esp)
    2c6a:	e8 8a 0d 00 00       	call   39f9 <chdir>
  printf(1, "empty file name OK\n");
    2c6f:	c7 44 24 04 40 4b 00 	movl   $0x4b40,0x4(%esp)
    2c76:	00 
    2c77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c7e:	e8 73 0e 00 00       	call   3af6 <printf>
}
    2c83:	83 c4 14             	add    $0x14,%esp
    2c86:	5b                   	pop    %ebx
    2c87:	5d                   	pop    %ebp
    2c88:	c3                   	ret    

00002c89 <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    2c89:	55                   	push   %ebp
    2c8a:	89 e5                	mov    %esp,%ebp
    2c8c:	53                   	push   %ebx
    2c8d:	83 ec 14             	sub    $0x14,%esp
  int n, pid;

  printf(1, "fork test\n");
    2c90:	c7 44 24 04 54 4b 00 	movl   $0x4b54,0x4(%esp)
    2c97:	00 
    2c98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c9f:	e8 52 0e 00 00       	call   3af6 <printf>

  for(n=0; n<1000; n++){
    2ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
    2ca9:	eb 15                	jmp    2cc0 <forktest+0x37>
    pid = fork();
    2cab:	e8 d1 0c 00 00       	call   3981 <fork>
    if(pid < 0)
    2cb0:	85 c0                	test   %eax,%eax
    2cb2:	78 14                	js     2cc8 <forktest+0x3f>
      break;
    if(pid == 0)
    2cb4:	85 c0                	test   %eax,%eax
    2cb6:	75 05                	jne    2cbd <forktest+0x34>
      exit();
    2cb8:	e8 cc 0c 00 00       	call   3989 <exit>
  for(n=0; n<1000; n++){
    2cbd:	83 c3 01             	add    $0x1,%ebx
    2cc0:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
    2cc6:	7e e3                	jle    2cab <forktest+0x22>
  }

  if(n == 1000){
    2cc8:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
    2cce:	75 3e                	jne    2d0e <forktest+0x85>
    printf(1, "fork claimed to work 1000 times!\n");
    2cd0:	c7 44 24 04 f4 52 00 	movl   $0x52f4,0x4(%esp)
    2cd7:	00 
    2cd8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cdf:	e8 12 0e 00 00       	call   3af6 <printf>
    exit();
    2ce4:	e8 a0 0c 00 00       	call   3989 <exit>
  }

  for(; n > 0; n--){
    if(wait() < 0){
    2ce9:	e8 a3 0c 00 00       	call   3991 <wait>
    2cee:	85 c0                	test   %eax,%eax
    2cf0:	79 19                	jns    2d0b <forktest+0x82>
      printf(1, "wait stopped early\n");
    2cf2:	c7 44 24 04 5f 4b 00 	movl   $0x4b5f,0x4(%esp)
    2cf9:	00 
    2cfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d01:	e8 f0 0d 00 00       	call   3af6 <printf>
      exit();
    2d06:	e8 7e 0c 00 00       	call   3989 <exit>
  for(; n > 0; n--){
    2d0b:	83 eb 01             	sub    $0x1,%ebx
    2d0e:	85 db                	test   %ebx,%ebx
    2d10:	7f d7                	jg     2ce9 <forktest+0x60>
    }
  }

  if(wait() != -1){
    2d12:	e8 7a 0c 00 00       	call   3991 <wait>
    2d17:	83 f8 ff             	cmp    $0xffffffff,%eax
    2d1a:	74 19                	je     2d35 <forktest+0xac>
    printf(1, "wait got too many\n");
    2d1c:	c7 44 24 04 73 4b 00 	movl   $0x4b73,0x4(%esp)
    2d23:	00 
    2d24:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d2b:	e8 c6 0d 00 00       	call   3af6 <printf>
    exit();
    2d30:	e8 54 0c 00 00       	call   3989 <exit>
  }

  printf(1, "fork test OK\n");
    2d35:	c7 44 24 04 86 4b 00 	movl   $0x4b86,0x4(%esp)
    2d3c:	00 
    2d3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d44:	e8 ad 0d 00 00       	call   3af6 <printf>
}
    2d49:	83 c4 14             	add    $0x14,%esp
    2d4c:	5b                   	pop    %ebx
    2d4d:	5d                   	pop    %ebp
    2d4e:	c3                   	ret    

00002d4f <sbrktest>:

void
sbrktest(void)
{
    2d4f:	55                   	push   %ebp
    2d50:	89 e5                	mov    %esp,%ebp
    2d52:	57                   	push   %edi
    2d53:	56                   	push   %esi
    2d54:	53                   	push   %ebx
    2d55:	83 ec 6c             	sub    $0x6c,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    2d58:	c7 44 24 04 94 4b 00 	movl   $0x4b94,0x4(%esp)
    2d5f:	00 
    2d60:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2d65:	89 04 24             	mov    %eax,(%esp)
    2d68:	e8 89 0d 00 00       	call   3af6 <printf>
  oldbrk = sbrk(0);
    2d6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2d74:	e8 98 0c 00 00       	call   3a11 <sbrk>
    2d79:	89 c7                	mov    %eax,%edi

  // can one sbrk() less than a page?
  a = sbrk(0);
    2d7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2d82:	e8 8a 0c 00 00       	call   3a11 <sbrk>
    2d87:	89 c6                	mov    %eax,%esi
  int i;
  for(i = 0; i < 5000; i++){
    2d89:	bb 00 00 00 00       	mov    $0x0,%ebx
    2d8e:	eb 3f                	jmp    2dcf <sbrktest+0x80>
    b = sbrk(1);
    2d90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d97:	e8 75 0c 00 00       	call   3a11 <sbrk>
    if(b != a){
    2d9c:	39 f0                	cmp    %esi,%eax
    2d9e:	74 26                	je     2dc6 <sbrktest+0x77>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    2da0:	89 44 24 10          	mov    %eax,0x10(%esp)
    2da4:	89 74 24 0c          	mov    %esi,0xc(%esp)
    2da8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    2dac:	c7 44 24 04 9f 4b 00 	movl   $0x4b9f,0x4(%esp)
    2db3:	00 
    2db4:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2db9:	89 04 24             	mov    %eax,(%esp)
    2dbc:	e8 35 0d 00 00       	call   3af6 <printf>
      exit();
    2dc1:	e8 c3 0b 00 00       	call   3989 <exit>
    }
    *b = 1;
    2dc6:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    2dc9:	8d 70 01             	lea    0x1(%eax),%esi
  for(i = 0; i < 5000; i++){
    2dcc:	83 c3 01             	add    $0x1,%ebx
    2dcf:	81 fb 87 13 00 00    	cmp    $0x1387,%ebx
    2dd5:	7e b9                	jle    2d90 <sbrktest+0x41>
  }
  pid = fork();
    2dd7:	e8 a5 0b 00 00       	call   3981 <fork>
    2ddc:	89 c3                	mov    %eax,%ebx
  if(pid < 0){
    2dde:	85 c0                	test   %eax,%eax
    2de0:	79 1a                	jns    2dfc <sbrktest+0xad>
    printf(stdout, "sbrk test fork failed\n");
    2de2:	c7 44 24 04 ba 4b 00 	movl   $0x4bba,0x4(%esp)
    2de9:	00 
    2dea:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2def:	89 04 24             	mov    %eax,(%esp)
    2df2:	e8 ff 0c 00 00       	call   3af6 <printf>
    exit();
    2df7:	e8 8d 0b 00 00       	call   3989 <exit>
  }
  c = sbrk(1);
    2dfc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e03:	e8 09 0c 00 00       	call   3a11 <sbrk>
  c = sbrk(1);
    2e08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e0f:	e8 fd 0b 00 00       	call   3a11 <sbrk>
  if(c != a + 1){
    2e14:	83 c6 01             	add    $0x1,%esi
    2e17:	39 c6                	cmp    %eax,%esi
    2e19:	74 1a                	je     2e35 <sbrktest+0xe6>
    printf(stdout, "sbrk test failed post-fork\n");
    2e1b:	c7 44 24 04 d1 4b 00 	movl   $0x4bd1,0x4(%esp)
    2e22:	00 
    2e23:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2e28:	89 04 24             	mov    %eax,(%esp)
    2e2b:	e8 c6 0c 00 00       	call   3af6 <printf>
    exit();
    2e30:	e8 54 0b 00 00       	call   3989 <exit>
  }
  if(pid == 0)
    2e35:	85 db                	test   %ebx,%ebx
    2e37:	75 05                	jne    2e3e <sbrktest+0xef>
    exit();
    2e39:	e8 4b 0b 00 00       	call   3989 <exit>
    2e3e:	66 90                	xchg   %ax,%ax
  wait();
    2e40:	e8 4c 0b 00 00       	call   3991 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    2e45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2e4c:	e8 c0 0b 00 00       	call   3a11 <sbrk>
    2e51:	89 c3                	mov    %eax,%ebx
  amt = (BIG) - (uint)a;
    2e53:	b8 00 00 40 06       	mov    $0x6400000,%eax
    2e58:	29 d8                	sub    %ebx,%eax
  p = sbrk(amt);
    2e5a:	89 04 24             	mov    %eax,(%esp)
    2e5d:	e8 af 0b 00 00       	call   3a11 <sbrk>
  if (p != a) {
    2e62:	39 d8                	cmp    %ebx,%eax
    2e64:	74 1a                	je     2e80 <sbrktest+0x131>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    2e66:	c7 44 24 04 18 53 00 	movl   $0x5318,0x4(%esp)
    2e6d:	00 
    2e6e:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2e73:	89 04 24             	mov    %eax,(%esp)
    2e76:	e8 7b 0c 00 00       	call   3af6 <printf>
    exit();
    2e7b:	e8 09 0b 00 00       	call   3989 <exit>
  }
  lastaddr = (char*) (BIG-1);
  *lastaddr = 99;
    2e80:	c6 05 ff ff 3f 06 63 	movb   $0x63,0x63fffff

  // can one de-allocate?
  a = sbrk(0);
    2e87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2e8e:	e8 7e 0b 00 00       	call   3a11 <sbrk>
    2e93:	89 c3                	mov    %eax,%ebx
  c = sbrk(-4096);
    2e95:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    2e9c:	e8 70 0b 00 00       	call   3a11 <sbrk>
  if(c == (char*)0xffffffff){
    2ea1:	83 f8 ff             	cmp    $0xffffffff,%eax
    2ea4:	75 1a                	jne    2ec0 <sbrktest+0x171>
    printf(stdout, "sbrk could not deallocate\n");
    2ea6:	c7 44 24 04 ed 4b 00 	movl   $0x4bed,0x4(%esp)
    2ead:	00 
    2eae:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2eb3:	89 04 24             	mov    %eax,(%esp)
    2eb6:	e8 3b 0c 00 00       	call   3af6 <printf>
    exit();
    2ebb:	e8 c9 0a 00 00       	call   3989 <exit>
  }
  c = sbrk(0);
    2ec0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2ec7:	e8 45 0b 00 00       	call   3a11 <sbrk>
  if(c != a - 4096){
    2ecc:	8d 93 00 f0 ff ff    	lea    -0x1000(%ebx),%edx
    2ed2:	39 c2                	cmp    %eax,%edx
    2ed4:	74 22                	je     2ef8 <sbrktest+0x1a9>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    2ed6:	89 44 24 0c          	mov    %eax,0xc(%esp)
    2eda:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    2ede:	c7 44 24 04 58 53 00 	movl   $0x5358,0x4(%esp)
    2ee5:	00 
    2ee6:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2eeb:	89 04 24             	mov    %eax,(%esp)
    2eee:	e8 03 0c 00 00       	call   3af6 <printf>
    exit();
    2ef3:	e8 91 0a 00 00       	call   3989 <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    2ef8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2eff:	e8 0d 0b 00 00       	call   3a11 <sbrk>
    2f04:	89 c3                	mov    %eax,%ebx
  c = sbrk(4096);
    2f06:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    2f0d:	e8 ff 0a 00 00       	call   3a11 <sbrk>
    2f12:	89 c6                	mov    %eax,%esi
  if(c != a || sbrk(0) != a + 4096){
    2f14:	39 d8                	cmp    %ebx,%eax
    2f16:	75 16                	jne    2f2e <sbrktest+0x1df>
    2f18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2f1f:	e8 ed 0a 00 00       	call   3a11 <sbrk>
    2f24:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
    2f2a:	39 d0                	cmp    %edx,%eax
    2f2c:	74 22                	je     2f50 <sbrktest+0x201>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    2f2e:	89 74 24 0c          	mov    %esi,0xc(%esp)
    2f32:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    2f36:	c7 44 24 04 90 53 00 	movl   $0x5390,0x4(%esp)
    2f3d:	00 
    2f3e:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2f43:	89 04 24             	mov    %eax,(%esp)
    2f46:	e8 ab 0b 00 00       	call   3af6 <printf>
    exit();
    2f4b:	e8 39 0a 00 00       	call   3989 <exit>
  }
  if(*lastaddr == 99){
    2f50:	80 3d ff ff 3f 06 63 	cmpb   $0x63,0x63fffff
    2f57:	75 1a                	jne    2f73 <sbrktest+0x224>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    2f59:	c7 44 24 04 b8 53 00 	movl   $0x53b8,0x4(%esp)
    2f60:	00 
    2f61:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2f66:	89 04 24             	mov    %eax,(%esp)
    2f69:	e8 88 0b 00 00       	call   3af6 <printf>
    exit();
    2f6e:	e8 16 0a 00 00       	call   3989 <exit>
  }

  a = sbrk(0);
    2f73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2f7a:	e8 92 0a 00 00       	call   3a11 <sbrk>
    2f7f:	89 c3                	mov    %eax,%ebx
  c = sbrk(-(sbrk(0) - oldbrk));
    2f81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2f88:	e8 84 0a 00 00       	call   3a11 <sbrk>
    2f8d:	89 f9                	mov    %edi,%ecx
    2f8f:	29 c1                	sub    %eax,%ecx
    2f91:	89 0c 24             	mov    %ecx,(%esp)
    2f94:	e8 78 0a 00 00       	call   3a11 <sbrk>
  if(c != a){
    2f99:	39 d8                	cmp    %ebx,%eax
    2f9b:	0f 84 8a 00 00 00    	je     302b <sbrktest+0x2dc>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    2fa1:	89 44 24 0c          	mov    %eax,0xc(%esp)
    2fa5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    2fa9:	c7 44 24 04 e8 53 00 	movl   $0x53e8,0x4(%esp)
    2fb0:	00 
    2fb1:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2fb6:	89 04 24             	mov    %eax,(%esp)
    2fb9:	e8 38 0b 00 00       	call   3af6 <printf>
    exit();
    2fbe:	e8 c6 09 00 00       	call   3989 <exit>
  }

  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    ppid = getpid();
    2fc3:	e8 41 0a 00 00       	call   3a09 <getpid>
    2fc8:	89 c6                	mov    %eax,%esi
    pid = fork();
    2fca:	e8 b2 09 00 00       	call   3981 <fork>
    if(pid < 0){
    2fcf:	85 c0                	test   %eax,%eax
    2fd1:	79 1a                	jns    2fed <sbrktest+0x29e>
      printf(stdout, "fork failed\n");
    2fd3:	c7 44 24 04 e5 4c 00 	movl   $0x4ce5,0x4(%esp)
    2fda:	00 
    2fdb:	a1 b4 55 00 00       	mov    0x55b4,%eax
    2fe0:	89 04 24             	mov    %eax,(%esp)
    2fe3:	e8 0e 0b 00 00       	call   3af6 <printf>
      exit();
    2fe8:	e8 9c 09 00 00       	call   3989 <exit>
    }
    if(pid == 0){
    2fed:	85 c0                	test   %eax,%eax
    2fef:	75 2d                	jne    301e <sbrktest+0x2cf>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    2ff1:	0f be 03             	movsbl (%ebx),%eax
    2ff4:	89 44 24 0c          	mov    %eax,0xc(%esp)
    2ff8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    2ffc:	c7 44 24 04 08 4c 00 	movl   $0x4c08,0x4(%esp)
    3003:	00 
    3004:	a1 b4 55 00 00       	mov    0x55b4,%eax
    3009:	89 04 24             	mov    %eax,(%esp)
    300c:	e8 e5 0a 00 00       	call   3af6 <printf>
      kill(ppid);
    3011:	89 34 24             	mov    %esi,(%esp)
    3014:	e8 a0 09 00 00       	call   39b9 <kill>
      exit();
    3019:	e8 6b 09 00 00       	call   3989 <exit>
    }
    wait();
    301e:	e8 6e 09 00 00       	call   3991 <wait>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    3023:	81 c3 50 c3 00 00    	add    $0xc350,%ebx
    3029:	eb 05                	jmp    3030 <sbrktest+0x2e1>
    302b:	bb 00 00 00 80       	mov    $0x80000000,%ebx
    3030:	81 fb 7f 84 1e 80    	cmp    $0x801e847f,%ebx
    3036:	76 8b                	jbe    2fc3 <sbrktest+0x274>
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    3038:	8d 45 e0             	lea    -0x20(%ebp),%eax
    303b:	89 04 24             	mov    %eax,(%esp)
    303e:	e8 56 09 00 00       	call   3999 <pipe>
    3043:	85 c0                	test   %eax,%eax
    3045:	0f 84 8b 00 00 00    	je     30d6 <sbrktest+0x387>
    printf(1, "pipe() failed\n");
    304b:	c7 44 24 04 dd 40 00 	movl   $0x40dd,0x4(%esp)
    3052:	00 
    3053:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    305a:	e8 97 0a 00 00       	call   3af6 <printf>
    exit();
    305f:	e8 25 09 00 00       	call   3989 <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if((pids[i] = fork()) == 0){
    3064:	e8 18 09 00 00       	call   3981 <fork>
    3069:	89 44 9d b8          	mov    %eax,-0x48(%ebp,%ebx,4)
    306d:	85 c0                	test   %eax,%eax
    306f:	75 44                	jne    30b5 <sbrktest+0x366>
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    3071:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3078:	e8 94 09 00 00       	call   3a11 <sbrk>
    307d:	ba 00 00 40 06       	mov    $0x6400000,%edx
    3082:	29 c2                	sub    %eax,%edx
    3084:	89 14 24             	mov    %edx,(%esp)
    3087:	e8 85 09 00 00       	call   3a11 <sbrk>
      write(fds[1], "x", 1);
    308c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3093:	00 
    3094:	c7 44 24 04 fd 46 00 	movl   $0x46fd,0x4(%esp)
    309b:	00 
    309c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    309f:	89 04 24             	mov    %eax,(%esp)
    30a2:	e8 02 09 00 00       	call   39a9 <write>
      // sit around until killed
      for(;;) sleep(1000);
    30a7:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
    30ae:	e8 66 09 00 00       	call   3a19 <sleep>
    30b3:	eb f2                	jmp    30a7 <sbrktest+0x358>
    }
    if(pids[i] != -1)
    30b5:	83 f8 ff             	cmp    $0xffffffff,%eax
    30b8:	74 17                	je     30d1 <sbrktest+0x382>
      read(fds[0], &scratch, 1);
    30ba:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    30c1:	00 
    30c2:	89 74 24 04          	mov    %esi,0x4(%esp)
    30c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
    30c9:	89 04 24             	mov    %eax,(%esp)
    30cc:	e8 d0 08 00 00       	call   39a1 <read>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    30d1:	83 c3 01             	add    $0x1,%ebx
    30d4:	eb 08                	jmp    30de <sbrktest+0x38f>
    30d6:	bb 00 00 00 00       	mov    $0x0,%ebx
      read(fds[0], &scratch, 1);
    30db:	8d 75 b7             	lea    -0x49(%ebp),%esi
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    30de:	83 fb 09             	cmp    $0x9,%ebx
    30e1:	76 81                	jbe    3064 <sbrktest+0x315>
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    30e3:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    30ea:	e8 22 09 00 00       	call   3a11 <sbrk>
    30ef:	89 c6                	mov    %eax,%esi
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    30f1:	bb 00 00 00 00       	mov    $0x0,%ebx
    30f6:	eb 19                	jmp    3111 <sbrktest+0x3c2>
    if(pids[i] == -1)
    30f8:	8b 44 9d b8          	mov    -0x48(%ebp,%ebx,4),%eax
    30fc:	83 f8 ff             	cmp    $0xffffffff,%eax
    30ff:	74 0d                	je     310e <sbrktest+0x3bf>
      continue;
    kill(pids[i]);
    3101:	89 04 24             	mov    %eax,(%esp)
    3104:	e8 b0 08 00 00       	call   39b9 <kill>
    wait();
    3109:	e8 83 08 00 00       	call   3991 <wait>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    310e:	83 c3 01             	add    $0x1,%ebx
    3111:	83 fb 09             	cmp    $0x9,%ebx
    3114:	76 e2                	jbe    30f8 <sbrktest+0x3a9>
  }
  if(c == (char*)0xffffffff){
    3116:	83 fe ff             	cmp    $0xffffffff,%esi
    3119:	75 1a                	jne    3135 <sbrktest+0x3e6>
    printf(stdout, "failed sbrk leaked memory\n");
    311b:	c7 44 24 04 21 4c 00 	movl   $0x4c21,0x4(%esp)
    3122:	00 
    3123:	a1 b4 55 00 00       	mov    0x55b4,%eax
    3128:	89 04 24             	mov    %eax,(%esp)
    312b:	e8 c6 09 00 00       	call   3af6 <printf>
    exit();
    3130:	e8 54 08 00 00       	call   3989 <exit>
  }

  if(sbrk(0) > oldbrk)
    3135:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    313c:	e8 d0 08 00 00       	call   3a11 <sbrk>
    3141:	39 f8                	cmp    %edi,%eax
    3143:	76 16                	jbe    315b <sbrktest+0x40c>
    sbrk(-(sbrk(0) - oldbrk));
    3145:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    314c:	e8 c0 08 00 00       	call   3a11 <sbrk>
    3151:	29 c7                	sub    %eax,%edi
    3153:	89 3c 24             	mov    %edi,(%esp)
    3156:	e8 b6 08 00 00       	call   3a11 <sbrk>

  printf(stdout, "sbrk test OK\n");
    315b:	c7 44 24 04 3c 4c 00 	movl   $0x4c3c,0x4(%esp)
    3162:	00 
    3163:	a1 b4 55 00 00       	mov    0x55b4,%eax
    3168:	89 04 24             	mov    %eax,(%esp)
    316b:	e8 86 09 00 00       	call   3af6 <printf>
}
    3170:	83 c4 6c             	add    $0x6c,%esp
    3173:	5b                   	pop    %ebx
    3174:	5e                   	pop    %esi
    3175:	5f                   	pop    %edi
    3176:	5d                   	pop    %ebp
    3177:	c3                   	ret    

00003178 <validateint>:

void
validateint(int *p)
{
    3178:	55                   	push   %ebp
    3179:	89 e5                	mov    %esp,%ebp
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    317b:	5d                   	pop    %ebp
    317c:	c3                   	ret    

0000317d <validatetest>:

void
validatetest(void)
{
    317d:	55                   	push   %ebp
    317e:	89 e5                	mov    %esp,%ebp
    3180:	56                   	push   %esi
    3181:	53                   	push   %ebx
    3182:	83 ec 10             	sub    $0x10,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    3185:	c7 44 24 04 4a 4c 00 	movl   $0x4c4a,0x4(%esp)
    318c:	00 
    318d:	a1 b4 55 00 00       	mov    0x55b4,%eax
    3192:	89 04 24             	mov    %eax,(%esp)
    3195:	e8 5c 09 00 00       	call   3af6 <printf>
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    319a:	bb 00 00 00 00       	mov    $0x0,%ebx
    319f:	eb 6a                	jmp    320b <validatetest+0x8e>
    if((pid = fork()) == 0){
    31a1:	e8 db 07 00 00       	call   3981 <fork>
    31a6:	89 c6                	mov    %eax,%esi
    31a8:	85 c0                	test   %eax,%eax
    31aa:	75 05                	jne    31b1 <validatetest+0x34>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
      exit();
    31ac:	e8 d8 07 00 00       	call   3989 <exit>
    }
    sleep(0);
    31b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    31b8:	e8 5c 08 00 00       	call   3a19 <sleep>
    sleep(0);
    31bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    31c4:	e8 50 08 00 00       	call   3a19 <sleep>
    kill(pid);
    31c9:	89 34 24             	mov    %esi,(%esp)
    31cc:	e8 e8 07 00 00       	call   39b9 <kill>
    wait();
    31d1:	e8 bb 07 00 00       	call   3991 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    31d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    31da:	c7 04 24 59 4c 00 00 	movl   $0x4c59,(%esp)
    31e1:	e8 03 08 00 00       	call   39e9 <link>
    31e6:	83 f8 ff             	cmp    $0xffffffff,%eax
    31e9:	74 1a                	je     3205 <validatetest+0x88>
      printf(stdout, "link should not succeed\n");
    31eb:	c7 44 24 04 64 4c 00 	movl   $0x4c64,0x4(%esp)
    31f2:	00 
    31f3:	a1 b4 55 00 00       	mov    0x55b4,%eax
    31f8:	89 04 24             	mov    %eax,(%esp)
    31fb:	e8 f6 08 00 00       	call   3af6 <printf>
      exit();
    3200:	e8 84 07 00 00       	call   3989 <exit>
  for(p = 0; p <= (uint)hi; p += 4096){
    3205:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    320b:	81 fb 00 30 11 00    	cmp    $0x113000,%ebx
    3211:	76 8e                	jbe    31a1 <validatetest+0x24>
    }
  }

  printf(stdout, "validate ok\n");
    3213:	c7 44 24 04 7d 4c 00 	movl   $0x4c7d,0x4(%esp)
    321a:	00 
    321b:	a1 b4 55 00 00       	mov    0x55b4,%eax
    3220:	89 04 24             	mov    %eax,(%esp)
    3223:	e8 ce 08 00 00       	call   3af6 <printf>
}
    3228:	83 c4 10             	add    $0x10,%esp
    322b:	5b                   	pop    %ebx
    322c:	5e                   	pop    %esi
    322d:	5d                   	pop    %ebp
    322e:	c3                   	ret    

0000322f <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    322f:	55                   	push   %ebp
    3230:	89 e5                	mov    %esp,%ebp
    3232:	83 ec 18             	sub    $0x18,%esp
  int i;

  printf(stdout, "bss test\n");
    3235:	c7 44 24 04 8a 4c 00 	movl   $0x4c8a,0x4(%esp)
    323c:	00 
    323d:	a1 b4 55 00 00       	mov    0x55b4,%eax
    3242:	89 04 24             	mov    %eax,(%esp)
    3245:	e8 ac 08 00 00       	call   3af6 <printf>
  for(i = 0; i < sizeof(uninit); i++){
    324a:	b8 00 00 00 00       	mov    $0x0,%eax
    324f:	eb 26                	jmp    3277 <bsstest+0x48>
    if(uninit[i] != '\0'){
    3251:	80 b8 80 56 00 00 00 	cmpb   $0x0,0x5680(%eax)
    3258:	74 1a                	je     3274 <bsstest+0x45>
      printf(stdout, "bss test failed\n");
    325a:	c7 44 24 04 94 4c 00 	movl   $0x4c94,0x4(%esp)
    3261:	00 
    3262:	a1 b4 55 00 00       	mov    0x55b4,%eax
    3267:	89 04 24             	mov    %eax,(%esp)
    326a:	e8 87 08 00 00       	call   3af6 <printf>
      exit();
    326f:	e8 15 07 00 00       	call   3989 <exit>
  for(i = 0; i < sizeof(uninit); i++){
    3274:	83 c0 01             	add    $0x1,%eax
    3277:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    327c:	76 d3                	jbe    3251 <bsstest+0x22>
    }
  }
  printf(stdout, "bss test ok\n");
    327e:	c7 44 24 04 a5 4c 00 	movl   $0x4ca5,0x4(%esp)
    3285:	00 
    3286:	a1 b4 55 00 00       	mov    0x55b4,%eax
    328b:	89 04 24             	mov    %eax,(%esp)
    328e:	e8 63 08 00 00       	call   3af6 <printf>
}
    3293:	c9                   	leave  
    3294:	c3                   	ret    

00003295 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    3295:	55                   	push   %ebp
    3296:	89 e5                	mov    %esp,%ebp
    3298:	83 ec 18             	sub    $0x18,%esp
  int pid, fd;

  unlink("bigarg-ok");
    329b:	c7 04 24 b2 4c 00 00 	movl   $0x4cb2,(%esp)
    32a2:	e8 32 07 00 00       	call   39d9 <unlink>
  pid = fork();
    32a7:	e8 d5 06 00 00       	call   3981 <fork>
  if(pid == 0){
    32ac:	85 c0                	test   %eax,%eax
    32ae:	0f 85 85 00 00 00    	jne    3339 <bigargtest+0xa4>
    32b4:	eb 10                	jmp    32c6 <bigargtest+0x31>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    32b6:	c7 04 85 e0 55 00 00 	movl   $0x540c,0x55e0(,%eax,4)
    32bd:	0c 54 00 00 
    for(i = 0; i < MAXARG-1; i++)
    32c1:	83 c0 01             	add    $0x1,%eax
    32c4:	eb 05                	jmp    32cb <bigargtest+0x36>
    32c6:	b8 00 00 00 00       	mov    $0x0,%eax
    32cb:	83 f8 1e             	cmp    $0x1e,%eax
    32ce:	7e e6                	jle    32b6 <bigargtest+0x21>
    args[MAXARG-1] = 0;
    32d0:	c7 05 5c 56 00 00 00 	movl   $0x0,0x565c
    32d7:	00 00 00 
    printf(stdout, "bigarg test\n");
    32da:	c7 44 24 04 bc 4c 00 	movl   $0x4cbc,0x4(%esp)
    32e1:	00 
    32e2:	a1 b4 55 00 00       	mov    0x55b4,%eax
    32e7:	89 04 24             	mov    %eax,(%esp)
    32ea:	e8 07 08 00 00       	call   3af6 <printf>
    exec("echo", args);
    32ef:	c7 44 24 04 e0 55 00 	movl   $0x55e0,0x4(%esp)
    32f6:	00 
    32f7:	c7 04 24 89 3e 00 00 	movl   $0x3e89,(%esp)
    32fe:	e8 be 06 00 00       	call   39c1 <exec>
    printf(stdout, "bigarg test ok\n");
    3303:	c7 44 24 04 c9 4c 00 	movl   $0x4cc9,0x4(%esp)
    330a:	00 
    330b:	a1 b4 55 00 00       	mov    0x55b4,%eax
    3310:	89 04 24             	mov    %eax,(%esp)
    3313:	e8 de 07 00 00       	call   3af6 <printf>
    fd = open("bigarg-ok", O_CREATE);
    3318:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    331f:	00 
    3320:	c7 04 24 b2 4c 00 00 	movl   $0x4cb2,(%esp)
    3327:	e8 9d 06 00 00       	call   39c9 <open>
    close(fd);
    332c:	89 04 24             	mov    %eax,(%esp)
    332f:	e8 7d 06 00 00       	call   39b1 <close>
    exit();
    3334:	e8 50 06 00 00       	call   3989 <exit>
  } else if(pid < 0){
    3339:	85 c0                	test   %eax,%eax
    333b:	79 1a                	jns    3357 <bigargtest+0xc2>
    printf(stdout, "bigargtest: fork failed\n");
    333d:	c7 44 24 04 d9 4c 00 	movl   $0x4cd9,0x4(%esp)
    3344:	00 
    3345:	a1 b4 55 00 00       	mov    0x55b4,%eax
    334a:	89 04 24             	mov    %eax,(%esp)
    334d:	e8 a4 07 00 00       	call   3af6 <printf>
    exit();
    3352:	e8 32 06 00 00       	call   3989 <exit>
  }
  wait();
    3357:	e8 35 06 00 00       	call   3991 <wait>
  fd = open("bigarg-ok", 0);
    335c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3363:	00 
    3364:	c7 04 24 b2 4c 00 00 	movl   $0x4cb2,(%esp)
    336b:	e8 59 06 00 00       	call   39c9 <open>
  if(fd < 0){
    3370:	85 c0                	test   %eax,%eax
    3372:	79 1a                	jns    338e <bigargtest+0xf9>
    printf(stdout, "bigarg test failed!\n");
    3374:	c7 44 24 04 f2 4c 00 	movl   $0x4cf2,0x4(%esp)
    337b:	00 
    337c:	a1 b4 55 00 00       	mov    0x55b4,%eax
    3381:	89 04 24             	mov    %eax,(%esp)
    3384:	e8 6d 07 00 00       	call   3af6 <printf>
    exit();
    3389:	e8 fb 05 00 00       	call   3989 <exit>
  }
  close(fd);
    338e:	89 04 24             	mov    %eax,(%esp)
    3391:	e8 1b 06 00 00       	call   39b1 <close>
  unlink("bigarg-ok");
    3396:	c7 04 24 b2 4c 00 00 	movl   $0x4cb2,(%esp)
    339d:	e8 37 06 00 00       	call   39d9 <unlink>
}
    33a2:	c9                   	leave  
    33a3:	c3                   	ret    

000033a4 <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    33a4:	55                   	push   %ebp
    33a5:	89 e5                	mov    %esp,%ebp
    33a7:	57                   	push   %edi
    33a8:	56                   	push   %esi
    33a9:	53                   	push   %ebx
    33aa:	83 ec 5c             	sub    $0x5c,%esp
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");
    33ad:	c7 44 24 04 07 4d 00 	movl   $0x4d07,0x4(%esp)
    33b4:	00 
    33b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    33bc:	e8 35 07 00 00       	call   3af6 <printf>

  for(nfiles = 0; ; nfiles++){
    33c1:	be 00 00 00 00       	mov    $0x0,%esi
    char name[64];
    name[0] = 'f';
    33c6:	c6 45 a8 66          	movb   $0x66,-0x58(%ebp)
    name[1] = '0' + nfiles / 1000;
    33ca:	b8 d3 4d 62 10       	mov    $0x10624dd3,%eax
    33cf:	f7 ee                	imul   %esi
    33d1:	c1 fa 06             	sar    $0x6,%edx
    33d4:	89 f3                	mov    %esi,%ebx
    33d6:	c1 fb 1f             	sar    $0x1f,%ebx
    33d9:	29 da                	sub    %ebx,%edx
    33db:	8d 42 30             	lea    0x30(%edx),%eax
    33de:	88 45 a9             	mov    %al,-0x57(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    33e1:	69 d2 e8 03 00 00    	imul   $0x3e8,%edx,%edx
    33e7:	89 f7                	mov    %esi,%edi
    33e9:	29 d7                	sub    %edx,%edi
    33eb:	b9 1f 85 eb 51       	mov    $0x51eb851f,%ecx
    33f0:	89 f8                	mov    %edi,%eax
    33f2:	f7 e9                	imul   %ecx
    33f4:	c1 fa 05             	sar    $0x5,%edx
    33f7:	c1 ff 1f             	sar    $0x1f,%edi
    33fa:	29 fa                	sub    %edi,%edx
    33fc:	83 c2 30             	add    $0x30,%edx
    33ff:	88 55 aa             	mov    %dl,-0x56(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3402:	89 f0                	mov    %esi,%eax
    3404:	f7 e9                	imul   %ecx
    3406:	89 d1                	mov    %edx,%ecx
    3408:	c1 f9 05             	sar    $0x5,%ecx
    340b:	29 d9                	sub    %ebx,%ecx
    340d:	6b c9 64             	imul   $0x64,%ecx,%ecx
    3410:	89 f0                	mov    %esi,%eax
    3412:	29 c8                	sub    %ecx,%eax
    3414:	89 c1                	mov    %eax,%ecx
    3416:	bf 67 66 66 66       	mov    $0x66666667,%edi
    341b:	f7 ef                	imul   %edi
    341d:	c1 fa 02             	sar    $0x2,%edx
    3420:	c1 f9 1f             	sar    $0x1f,%ecx
    3423:	29 ca                	sub    %ecx,%edx
    3425:	83 c2 30             	add    $0x30,%edx
    3428:	88 55 ab             	mov    %dl,-0x55(%ebp)
    name[4] = '0' + (nfiles % 10);
    342b:	89 f0                	mov    %esi,%eax
    342d:	f7 ef                	imul   %edi
    342f:	c1 fa 02             	sar    $0x2,%edx
    3432:	29 da                	sub    %ebx,%edx
    3434:	8d 04 92             	lea    (%edx,%edx,4),%eax
    3437:	01 c0                	add    %eax,%eax
    3439:	89 f2                	mov    %esi,%edx
    343b:	29 c2                	sub    %eax,%edx
    343d:	83 c2 30             	add    $0x30,%edx
    3440:	88 55 ac             	mov    %dl,-0x54(%ebp)
    name[5] = '\0';
    3443:	c6 45 ad 00          	movb   $0x0,-0x53(%ebp)
    printf(1, "writing %s\n", name);
    3447:	8d 45 a8             	lea    -0x58(%ebp),%eax
    344a:	89 44 24 08          	mov    %eax,0x8(%esp)
    344e:	c7 44 24 04 14 4d 00 	movl   $0x4d14,0x4(%esp)
    3455:	00 
    3456:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    345d:	e8 94 06 00 00       	call   3af6 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    3462:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    3469:	00 
    346a:	8d 45 a8             	lea    -0x58(%ebp),%eax
    346d:	89 04 24             	mov    %eax,(%esp)
    3470:	e8 54 05 00 00       	call   39c9 <open>
    3475:	89 c7                	mov    %eax,%edi
    if(fd < 0){
    3477:	85 c0                	test   %eax,%eax
    3479:	79 20                	jns    349b <fsfull+0xf7>
      printf(1, "open %s failed\n", name);
    347b:	8d 45 a8             	lea    -0x58(%ebp),%eax
    347e:	89 44 24 08          	mov    %eax,0x8(%esp)
    3482:	c7 44 24 04 20 4d 00 	movl   $0x4d20,0x4(%esp)
    3489:	00 
    348a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3491:	e8 60 06 00 00       	call   3af6 <printf>
      break;
    3496:	e9 e7 00 00 00       	jmp    3582 <fsfull+0x1de>
    349b:	bb 00 00 00 00       	mov    $0x0,%ebx
    }
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
    34a0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    34a7:	00 
    34a8:	c7 44 24 04 a0 7d 00 	movl   $0x7da0,0x4(%esp)
    34af:	00 
    34b0:	89 3c 24             	mov    %edi,(%esp)
    34b3:	e8 f1 04 00 00       	call   39a9 <write>
      if(cc < 512)
    34b8:	3d ff 01 00 00       	cmp    $0x1ff,%eax
    34bd:	7e 04                	jle    34c3 <fsfull+0x11f>
        break;
      total += cc;
    34bf:	01 c3                	add    %eax,%ebx
      fsblocks++;
    }
    34c1:	eb dd                	jmp    34a0 <fsfull+0xfc>
    printf(1, "wrote %d bytes\n", total);
    34c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    34c7:	c7 44 24 04 30 4d 00 	movl   $0x4d30,0x4(%esp)
    34ce:	00 
    34cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    34d6:	e8 1b 06 00 00       	call   3af6 <printf>
    close(fd);
    34db:	89 3c 24             	mov    %edi,(%esp)
    34de:	e8 ce 04 00 00       	call   39b1 <close>
    if(total == 0)
    34e3:	85 db                	test   %ebx,%ebx
    34e5:	0f 84 97 00 00 00    	je     3582 <fsfull+0x1de>
  for(nfiles = 0; ; nfiles++){
    34eb:	83 c6 01             	add    $0x1,%esi
      break;
  }
    34ee:	e9 d3 fe ff ff       	jmp    33c6 <fsfull+0x22>

  while(nfiles >= 0){
    char name[64];
    name[0] = 'f';
    34f3:	c6 45 a8 66          	movb   $0x66,-0x58(%ebp)
    name[1] = '0' + nfiles / 1000;
    34f7:	b8 d3 4d 62 10       	mov    $0x10624dd3,%eax
    34fc:	f7 ee                	imul   %esi
    34fe:	c1 fa 06             	sar    $0x6,%edx
    3501:	89 f3                	mov    %esi,%ebx
    3503:	c1 fb 1f             	sar    $0x1f,%ebx
    3506:	29 da                	sub    %ebx,%edx
    3508:	8d 42 30             	lea    0x30(%edx),%eax
    350b:	88 45 a9             	mov    %al,-0x57(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    350e:	69 d2 e8 03 00 00    	imul   $0x3e8,%edx,%edx
    3514:	89 f7                	mov    %esi,%edi
    3516:	29 d7                	sub    %edx,%edi
    3518:	b9 1f 85 eb 51       	mov    $0x51eb851f,%ecx
    351d:	89 f8                	mov    %edi,%eax
    351f:	f7 e9                	imul   %ecx
    3521:	c1 fa 05             	sar    $0x5,%edx
    3524:	c1 ff 1f             	sar    $0x1f,%edi
    3527:	29 fa                	sub    %edi,%edx
    3529:	83 c2 30             	add    $0x30,%edx
    352c:	88 55 aa             	mov    %dl,-0x56(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    352f:	89 f0                	mov    %esi,%eax
    3531:	f7 e9                	imul   %ecx
    3533:	89 d1                	mov    %edx,%ecx
    3535:	c1 f9 05             	sar    $0x5,%ecx
    3538:	29 d9                	sub    %ebx,%ecx
    353a:	6b c9 64             	imul   $0x64,%ecx,%ecx
    353d:	89 f0                	mov    %esi,%eax
    353f:	29 c8                	sub    %ecx,%eax
    3541:	89 c1                	mov    %eax,%ecx
    3543:	bf 67 66 66 66       	mov    $0x66666667,%edi
    3548:	f7 ef                	imul   %edi
    354a:	c1 fa 02             	sar    $0x2,%edx
    354d:	c1 f9 1f             	sar    $0x1f,%ecx
    3550:	29 ca                	sub    %ecx,%edx
    3552:	83 c2 30             	add    $0x30,%edx
    3555:	88 55 ab             	mov    %dl,-0x55(%ebp)
    name[4] = '0' + (nfiles % 10);
    3558:	89 f0                	mov    %esi,%eax
    355a:	f7 ef                	imul   %edi
    355c:	c1 fa 02             	sar    $0x2,%edx
    355f:	29 da                	sub    %ebx,%edx
    3561:	8d 04 92             	lea    (%edx,%edx,4),%eax
    3564:	01 c0                	add    %eax,%eax
    3566:	89 f2                	mov    %esi,%edx
    3568:	29 c2                	sub    %eax,%edx
    356a:	83 c2 30             	add    $0x30,%edx
    356d:	88 55 ac             	mov    %dl,-0x54(%ebp)
    name[5] = '\0';
    3570:	c6 45 ad 00          	movb   $0x0,-0x53(%ebp)
    unlink(name);
    3574:	8d 45 a8             	lea    -0x58(%ebp),%eax
    3577:	89 04 24             	mov    %eax,(%esp)
    357a:	e8 5a 04 00 00       	call   39d9 <unlink>
    nfiles--;
    357f:	83 ee 01             	sub    $0x1,%esi
  while(nfiles >= 0){
    3582:	85 f6                	test   %esi,%esi
    3584:	0f 89 69 ff ff ff    	jns    34f3 <fsfull+0x14f>
  }

  printf(1, "fsfull test finished\n");
    358a:	c7 44 24 04 40 4d 00 	movl   $0x4d40,0x4(%esp)
    3591:	00 
    3592:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3599:	e8 58 05 00 00       	call   3af6 <printf>
}
    359e:	83 c4 5c             	add    $0x5c,%esp
    35a1:	5b                   	pop    %ebx
    35a2:	5e                   	pop    %esi
    35a3:	5f                   	pop    %edi
    35a4:	5d                   	pop    %ebp
    35a5:	c3                   	ret    

000035a6 <uio>:

void
uio()
{
    35a6:	55                   	push   %ebp
    35a7:	89 e5                	mov    %esp,%ebp
    35a9:	83 ec 18             	sub    $0x18,%esp

  ushort port = 0;
  uchar val = 0;
  int pid;

  printf(1, "uio test\n");
    35ac:	c7 44 24 04 56 4d 00 	movl   $0x4d56,0x4(%esp)
    35b3:	00 
    35b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    35bb:	e8 36 05 00 00       	call   3af6 <printf>
  pid = fork();
    35c0:	e8 bc 03 00 00       	call   3981 <fork>
  if(pid == 0){
    35c5:	85 c0                	test   %eax,%eax
    35c7:	75 27                	jne    35f0 <uio+0x4a>
    port = RTC_ADDR;
    val = 0x09;  /* year */
    /* http://wiki.osdev.org/Inline_Assembly/Examples */
    asm volatile("outb %0,%1"::"a"(val), "d" (port));
    35c9:	ba 70 00 00 00       	mov    $0x70,%edx
    35ce:	b8 09 00 00 00       	mov    $0x9,%eax
    35d3:	ee                   	out    %al,(%dx)
    port = RTC_DATA;
    asm volatile("inb %1,%0" : "=a" (val) : "d" (port));
    35d4:	b2 71                	mov    $0x71,%dl
    35d6:	ec                   	in     (%dx),%al
    printf(1, "uio: uio succeeded; test FAILED\n");
    35d7:	c7 44 24 04 ec 54 00 	movl   $0x54ec,0x4(%esp)
    35de:	00 
    35df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    35e6:	e8 0b 05 00 00       	call   3af6 <printf>
    exit();
    35eb:	e8 99 03 00 00       	call   3989 <exit>
  } else if(pid < 0){
    35f0:	85 c0                	test   %eax,%eax
    35f2:	79 19                	jns    360d <uio+0x67>
    printf (1, "fork failed\n");
    35f4:	c7 44 24 04 e5 4c 00 	movl   $0x4ce5,0x4(%esp)
    35fb:	00 
    35fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3603:	e8 ee 04 00 00       	call   3af6 <printf>
    exit();
    3608:	e8 7c 03 00 00       	call   3989 <exit>
  }
  wait();
    360d:	e8 7f 03 00 00       	call   3991 <wait>
  printf(1, "uio test done\n");
    3612:	c7 44 24 04 60 4d 00 	movl   $0x4d60,0x4(%esp)
    3619:	00 
    361a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3621:	e8 d0 04 00 00       	call   3af6 <printf>
}
    3626:	c9                   	leave  
    3627:	c3                   	ret    

00003628 <argptest>:

void argptest()
{
    3628:	55                   	push   %ebp
    3629:	89 e5                	mov    %esp,%ebp
    362b:	53                   	push   %ebx
    362c:	83 ec 14             	sub    $0x14,%esp
  int fd;
  fd = open("init", O_RDONLY);
    362f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3636:	00 
    3637:	c7 04 24 6f 4d 00 00 	movl   $0x4d6f,(%esp)
    363e:	e8 86 03 00 00       	call   39c9 <open>
    3643:	89 c3                	mov    %eax,%ebx
  if (fd < 0) {
    3645:	85 c0                	test   %eax,%eax
    3647:	79 19                	jns    3662 <argptest+0x3a>
    printf(2, "open failed\n");
    3649:	c7 44 24 04 74 4d 00 	movl   $0x4d74,0x4(%esp)
    3650:	00 
    3651:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3658:	e8 99 04 00 00       	call   3af6 <printf>
    exit();
    365d:	e8 27 03 00 00       	call   3989 <exit>
  }
  read(fd, sbrk(0) - 1, -1);
    3662:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3669:	e8 a3 03 00 00       	call   3a11 <sbrk>
    366e:	c7 44 24 08 ff ff ff 	movl   $0xffffffff,0x8(%esp)
    3675:	ff 
    3676:	83 e8 01             	sub    $0x1,%eax
    3679:	89 44 24 04          	mov    %eax,0x4(%esp)
    367d:	89 1c 24             	mov    %ebx,(%esp)
    3680:	e8 1c 03 00 00       	call   39a1 <read>
  close(fd);
    3685:	89 1c 24             	mov    %ebx,(%esp)
    3688:	e8 24 03 00 00       	call   39b1 <close>
  printf(1, "arg test passed\n");
    368d:	c7 44 24 04 81 4d 00 	movl   $0x4d81,0x4(%esp)
    3694:	00 
    3695:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    369c:	e8 55 04 00 00       	call   3af6 <printf>
}
    36a1:	83 c4 14             	add    $0x14,%esp
    36a4:	5b                   	pop    %ebx
    36a5:	5d                   	pop    %ebp
    36a6:	c3                   	ret    

000036a7 <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    36a7:	55                   	push   %ebp
    36a8:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    36aa:	69 05 b0 55 00 00 0d 	imul   $0x19660d,0x55b0,%eax
    36b1:	66 19 00 
    36b4:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    36b9:	a3 b0 55 00 00       	mov    %eax,0x55b0
  return randstate;
}
    36be:	5d                   	pop    %ebp
    36bf:	c3                   	ret    

000036c0 <main>:

int
main(int argc, char *argv[])
{
    36c0:	55                   	push   %ebp
    36c1:	89 e5                	mov    %esp,%ebp
    36c3:	83 e4 f0             	and    $0xfffffff0,%esp
    36c6:	83 ec 10             	sub    $0x10,%esp
  printf(1, "usertests starting\n");
    36c9:	c7 44 24 04 92 4d 00 	movl   $0x4d92,0x4(%esp)
    36d0:	00 
    36d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    36d8:	e8 19 04 00 00       	call   3af6 <printf>

  if(open("usertests.ran", 0) >= 0){
    36dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    36e4:	00 
    36e5:	c7 04 24 a6 4d 00 00 	movl   $0x4da6,(%esp)
    36ec:	e8 d8 02 00 00       	call   39c9 <open>
    36f1:	85 c0                	test   %eax,%eax
    36f3:	78 19                	js     370e <main+0x4e>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    36f5:	c7 44 24 04 10 55 00 	movl   $0x5510,0x4(%esp)
    36fc:	00 
    36fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3704:	e8 ed 03 00 00       	call   3af6 <printf>
    exit();
    3709:	e8 7b 02 00 00       	call   3989 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    370e:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3715:	00 
    3716:	c7 04 24 a6 4d 00 00 	movl   $0x4da6,(%esp)
    371d:	e8 a7 02 00 00       	call   39c9 <open>
    3722:	89 04 24             	mov    %eax,(%esp)
    3725:	e8 87 02 00 00       	call   39b1 <close>

  argptest();
    372a:	e8 f9 fe ff ff       	call   3628 <argptest>
  createdelete();
    372f:	e8 cc d9 ff ff       	call   1100 <createdelete>
  linkunlink();
    3734:	e8 ee e2 ff ff       	call   1a27 <linkunlink>
  concreate();
    3739:	e8 e7 df ff ff       	call   1725 <concreate>
    373e:	66 90                	xchg   %ax,%ax
  fourfiles();
    3740:	e8 a4 d7 ff ff       	call   ee9 <fourfiles>
  sharedfd();
    3745:	e8 d4 d5 ff ff       	call   d1e <sharedfd>

  bigargtest();
    374a:	e8 46 fb ff ff       	call   3295 <bigargtest>
    374f:	90                   	nop
  bigwrite();
    3750:	e8 5c ec ff ff       	call   23b1 <bigwrite>
  bigargtest();
    3755:	e8 3b fb ff ff       	call   3295 <bigargtest>
  bsstest();
    375a:	e8 d0 fa ff ff       	call   322f <bsstest>
    375f:	90                   	nop
  sbrktest();
    3760:	e8 ea f5 ff ff       	call   2d4f <sbrktest>
  validatetest();
    3765:	e8 13 fa ff ff       	call   317d <validatetest>

  opentest();
    376a:	e8 45 cb ff ff       	call   2b4 <opentest>
    376f:	90                   	nop
  writetest();
    3770:	e8 dd cb ff ff       	call   352 <writetest>
  writetest1();
    3775:	e8 cc cd ff ff       	call   546 <writetest1>
  createtest();
    377a:	e8 96 cf ff ff       	call   715 <createtest>
    377f:	90                   	nop

  openiputtest();
    3780:	e8 3a ca ff ff       	call   1bf <openiputtest>
  exitiputtest();
    3785:	e8 50 c9 ff ff       	call   da <exitiputtest>
  iputtest();
    378a:	e8 71 c8 ff ff       	call   0 <iputtest>
    378f:	90                   	nop

  mem();
    3790:	e8 cb d4 ff ff       	call   c60 <mem>
  pipe1();
    3795:	e8 4d d1 ff ff       	call   8e7 <pipe1>
  preempt();
    379a:	e8 ec d2 ff ff       	call   a8b <preempt>
    379f:	90                   	nop
  exitwait();
    37a0:	e8 3c d4 ff ff       	call   be1 <exitwait>

  rmdot();
    37a5:	e8 29 f0 ff ff       	call   27d3 <rmdot>
  fourteen();
    37aa:	e8 de ee ff ff       	call   268d <fourteen>
    37af:	90                   	nop
  bigfile();
    37b0:	e8 ec ec ff ff       	call   24a1 <bigfile>
  subdir();
    37b5:	e8 d6 e4 ff ff       	call   1c90 <subdir>
  linktest();
    37ba:	e8 2a dd ff ff       	call   14e9 <linktest>
    37bf:	90                   	nop
  unlinkread();
    37c0:	e8 66 db ff ff       	call   132b <unlinkread>
  dirfile();
    37c5:	e8 81 f1 ff ff       	call   294b <dirfile>
  iref();
    37ca:	e8 a5 f3 ff ff       	call   2b74 <iref>
    37cf:	90                   	nop
  forktest();
    37d0:	e8 b4 f4 ff ff       	call   2c89 <forktest>
  bigdir(); // slow
    37d5:	e8 50 e3 ff ff       	call   1b2a <bigdir>

  uio();
    37da:	e8 c7 fd ff ff       	call   35a6 <uio>
    37df:	90                   	nop

  exectest();
    37e0:	e8 b3 d0 ff ff       	call   898 <exectest>

  exit();
    37e5:	e8 9f 01 00 00       	call   3989 <exit>

000037ea <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
    37ea:	55                   	push   %ebp
    37eb:	89 e5                	mov    %esp,%ebp
    37ed:	56                   	push   %esi
    37ee:	53                   	push   %ebx
    37ef:	8b 75 08             	mov    0x8(%ebp),%esi
    37f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    37f5:	89 f0                	mov    %esi,%eax
    37f7:	89 d1                	mov    %edx,%ecx
    37f9:	83 c2 01             	add    $0x1,%edx
    37fc:	89 c3                	mov    %eax,%ebx
    37fe:	83 c0 01             	add    $0x1,%eax
    3801:	0f b6 09             	movzbl (%ecx),%ecx
    3804:	88 0b                	mov    %cl,(%ebx)
    3806:	84 c9                	test   %cl,%cl
    3808:	75 ed                	jne    37f7 <strcpy+0xd>
    ;
  return os;
}
    380a:	89 f0                	mov    %esi,%eax
    380c:	5b                   	pop    %ebx
    380d:	5e                   	pop    %esi
    380e:	5d                   	pop    %ebp
    380f:	c3                   	ret    

00003810 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    3810:	55                   	push   %ebp
    3811:	89 e5                	mov    %esp,%ebp
    3813:	8b 4d 08             	mov    0x8(%ebp),%ecx
    3816:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
    3819:	eb 06                	jmp    3821 <strcmp+0x11>
    p++, q++;
    381b:	83 c1 01             	add    $0x1,%ecx
    381e:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
    3821:	0f b6 01             	movzbl (%ecx),%eax
    3824:	84 c0                	test   %al,%al
    3826:	74 04                	je     382c <strcmp+0x1c>
    3828:	3a 02                	cmp    (%edx),%al
    382a:	74 ef                	je     381b <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
    382c:	0f b6 c0             	movzbl %al,%eax
    382f:	0f b6 12             	movzbl (%edx),%edx
    3832:	29 d0                	sub    %edx,%eax
}
    3834:	5d                   	pop    %ebp
    3835:	c3                   	ret    

00003836 <strlen>:

uint
strlen(const char *s)
{
    3836:	55                   	push   %ebp
    3837:	89 e5                	mov    %esp,%ebp
    3839:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
    383c:	b8 00 00 00 00       	mov    $0x0,%eax
    3841:	eb 03                	jmp    3846 <strlen+0x10>
    3843:	83 c0 01             	add    $0x1,%eax
    3846:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
    384a:	75 f7                	jne    3843 <strlen+0xd>
    ;
  return n;
}
    384c:	5d                   	pop    %ebp
    384d:	c3                   	ret    

0000384e <memset>:

void*
memset(void *dst, int c, uint n)
{
    384e:	55                   	push   %ebp
    384f:	89 e5                	mov    %esp,%ebp
    3851:	57                   	push   %edi
    3852:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    3855:	89 d7                	mov    %edx,%edi
    3857:	8b 4d 10             	mov    0x10(%ebp),%ecx
    385a:	8b 45 0c             	mov    0xc(%ebp),%eax
    385d:	fc                   	cld    
    385e:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
    3860:	89 d0                	mov    %edx,%eax
    3862:	8b 7d fc             	mov    -0x4(%ebp),%edi
    3865:	c9                   	leave  
    3866:	c3                   	ret    

00003867 <strchr>:

char*
strchr(const char *s, char c)
{
    3867:	55                   	push   %ebp
    3868:	89 e5                	mov    %esp,%ebp
    386a:	8b 45 08             	mov    0x8(%ebp),%eax
    386d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
    3871:	eb 03                	jmp    3876 <strchr+0xf>
    3873:	83 c0 01             	add    $0x1,%eax
    3876:	0f b6 10             	movzbl (%eax),%edx
    3879:	84 d2                	test   %dl,%dl
    387b:	74 06                	je     3883 <strchr+0x1c>
    if(*s == c)
    387d:	38 ca                	cmp    %cl,%dl
    387f:	75 f2                	jne    3873 <strchr+0xc>
    3881:	eb 05                	jmp    3888 <strchr+0x21>
      return (char*)s;
  return 0;
    3883:	b8 00 00 00 00       	mov    $0x0,%eax
}
    3888:	5d                   	pop    %ebp
    3889:	c3                   	ret    

0000388a <gets>:

char*
gets(char *buf, int max)
{
    388a:	55                   	push   %ebp
    388b:	89 e5                	mov    %esp,%ebp
    388d:	57                   	push   %edi
    388e:	56                   	push   %esi
    388f:	53                   	push   %ebx
    3890:	83 ec 1c             	sub    $0x1c,%esp
    3893:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3896:	bb 00 00 00 00       	mov    $0x0,%ebx
    389b:	89 de                	mov    %ebx,%esi
    389d:	83 c3 01             	add    $0x1,%ebx
    38a0:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
    38a3:	7d 2e                	jge    38d3 <gets+0x49>
    cc = read(0, &c, 1);
    38a5:	83 ec 04             	sub    $0x4,%esp
    38a8:	6a 01                	push   $0x1
    38aa:	8d 45 e7             	lea    -0x19(%ebp),%eax
    38ad:	50                   	push   %eax
    38ae:	6a 00                	push   $0x0
    38b0:	e8 ec 00 00 00       	call   39a1 <read>
    if(cc < 1)
    38b5:	83 c4 10             	add    $0x10,%esp
    38b8:	85 c0                	test   %eax,%eax
    38ba:	7e 17                	jle    38d3 <gets+0x49>
      break;
    buf[i++] = c;
    38bc:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
    38c0:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
    38c3:	3c 0a                	cmp    $0xa,%al
    38c5:	0f 94 c2             	sete   %dl
    38c8:	3c 0d                	cmp    $0xd,%al
    38ca:	0f 94 c0             	sete   %al
    38cd:	08 c2                	or     %al,%dl
    38cf:	74 ca                	je     389b <gets+0x11>
    buf[i++] = c;
    38d1:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
    38d3:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
    38d7:	89 f8                	mov    %edi,%eax
    38d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
    38dc:	5b                   	pop    %ebx
    38dd:	5e                   	pop    %esi
    38de:	5f                   	pop    %edi
    38df:	5d                   	pop    %ebp
    38e0:	c3                   	ret    

000038e1 <stat>:

int
stat(const char *n, struct stat *st)
{
    38e1:	55                   	push   %ebp
    38e2:	89 e5                	mov    %esp,%ebp
    38e4:	56                   	push   %esi
    38e5:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    38e6:	83 ec 08             	sub    $0x8,%esp
    38e9:	6a 00                	push   $0x0
    38eb:	ff 75 08             	push   0x8(%ebp)
    38ee:	e8 d6 00 00 00       	call   39c9 <open>
  if(fd < 0)
    38f3:	83 c4 10             	add    $0x10,%esp
    38f6:	85 c0                	test   %eax,%eax
    38f8:	78 24                	js     391e <stat+0x3d>
    38fa:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
    38fc:	83 ec 08             	sub    $0x8,%esp
    38ff:	ff 75 0c             	push   0xc(%ebp)
    3902:	50                   	push   %eax
    3903:	e8 d9 00 00 00       	call   39e1 <fstat>
    3908:	89 c6                	mov    %eax,%esi
  close(fd);
    390a:	89 1c 24             	mov    %ebx,(%esp)
    390d:	e8 9f 00 00 00       	call   39b1 <close>
  return r;
    3912:	83 c4 10             	add    $0x10,%esp
}
    3915:	89 f0                	mov    %esi,%eax
    3917:	8d 65 f8             	lea    -0x8(%ebp),%esp
    391a:	5b                   	pop    %ebx
    391b:	5e                   	pop    %esi
    391c:	5d                   	pop    %ebp
    391d:	c3                   	ret    
    return -1;
    391e:	be ff ff ff ff       	mov    $0xffffffff,%esi
    3923:	eb f0                	jmp    3915 <stat+0x34>

00003925 <atoi>:

int
atoi(const char *s)
{
    3925:	55                   	push   %ebp
    3926:	89 e5                	mov    %esp,%ebp
    3928:	53                   	push   %ebx
    3929:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
    392c:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
    3931:	eb 10                	jmp    3943 <atoi+0x1e>
    n = n*10 + *s++ - '0';
    3933:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
    3936:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
    3939:	83 c1 01             	add    $0x1,%ecx
    393c:	0f be c0             	movsbl %al,%eax
    393f:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
  while('0' <= *s && *s <= '9')
    3943:	0f b6 01             	movzbl (%ecx),%eax
    3946:	8d 58 d0             	lea    -0x30(%eax),%ebx
    3949:	80 fb 09             	cmp    $0x9,%bl
    394c:	76 e5                	jbe    3933 <atoi+0xe>
  return n;
}
    394e:	89 d0                	mov    %edx,%eax
    3950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    3953:	c9                   	leave  
    3954:	c3                   	ret    

00003955 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    3955:	55                   	push   %ebp
    3956:	89 e5                	mov    %esp,%ebp
    3958:	56                   	push   %esi
    3959:	53                   	push   %ebx
    395a:	8b 75 08             	mov    0x8(%ebp),%esi
    395d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    3960:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
    3963:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
    3965:	eb 0d                	jmp    3974 <memmove+0x1f>
    *dst++ = *src++;
    3967:	0f b6 01             	movzbl (%ecx),%eax
    396a:	88 02                	mov    %al,(%edx)
    396c:	8d 49 01             	lea    0x1(%ecx),%ecx
    396f:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
    3972:	89 d8                	mov    %ebx,%eax
    3974:	8d 58 ff             	lea    -0x1(%eax),%ebx
    3977:	85 c0                	test   %eax,%eax
    3979:	7f ec                	jg     3967 <memmove+0x12>
  return vdst;
}
    397b:	89 f0                	mov    %esi,%eax
    397d:	5b                   	pop    %ebx
    397e:	5e                   	pop    %esi
    397f:	5d                   	pop    %ebp
    3980:	c3                   	ret    

00003981 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3981:	b8 01 00 00 00       	mov    $0x1,%eax
    3986:	cd 40                	int    $0x40
    3988:	c3                   	ret    

00003989 <exit>:
SYSCALL(exit)
    3989:	b8 02 00 00 00       	mov    $0x2,%eax
    398e:	cd 40                	int    $0x40
    3990:	c3                   	ret    

00003991 <wait>:
SYSCALL(wait)
    3991:	b8 03 00 00 00       	mov    $0x3,%eax
    3996:	cd 40                	int    $0x40
    3998:	c3                   	ret    

00003999 <pipe>:
SYSCALL(pipe)
    3999:	b8 04 00 00 00       	mov    $0x4,%eax
    399e:	cd 40                	int    $0x40
    39a0:	c3                   	ret    

000039a1 <read>:
SYSCALL(read)
    39a1:	b8 05 00 00 00       	mov    $0x5,%eax
    39a6:	cd 40                	int    $0x40
    39a8:	c3                   	ret    

000039a9 <write>:
SYSCALL(write)
    39a9:	b8 10 00 00 00       	mov    $0x10,%eax
    39ae:	cd 40                	int    $0x40
    39b0:	c3                   	ret    

000039b1 <close>:
SYSCALL(close)
    39b1:	b8 15 00 00 00       	mov    $0x15,%eax
    39b6:	cd 40                	int    $0x40
    39b8:	c3                   	ret    

000039b9 <kill>:
SYSCALL(kill)
    39b9:	b8 06 00 00 00       	mov    $0x6,%eax
    39be:	cd 40                	int    $0x40
    39c0:	c3                   	ret    

000039c1 <exec>:
SYSCALL(exec)
    39c1:	b8 07 00 00 00       	mov    $0x7,%eax
    39c6:	cd 40                	int    $0x40
    39c8:	c3                   	ret    

000039c9 <open>:
SYSCALL(open)
    39c9:	b8 0f 00 00 00       	mov    $0xf,%eax
    39ce:	cd 40                	int    $0x40
    39d0:	c3                   	ret    

000039d1 <mknod>:
SYSCALL(mknod)
    39d1:	b8 11 00 00 00       	mov    $0x11,%eax
    39d6:	cd 40                	int    $0x40
    39d8:	c3                   	ret    

000039d9 <unlink>:
SYSCALL(unlink)
    39d9:	b8 12 00 00 00       	mov    $0x12,%eax
    39de:	cd 40                	int    $0x40
    39e0:	c3                   	ret    

000039e1 <fstat>:
SYSCALL(fstat)
    39e1:	b8 08 00 00 00       	mov    $0x8,%eax
    39e6:	cd 40                	int    $0x40
    39e8:	c3                   	ret    

000039e9 <link>:
SYSCALL(link)
    39e9:	b8 13 00 00 00       	mov    $0x13,%eax
    39ee:	cd 40                	int    $0x40
    39f0:	c3                   	ret    

000039f1 <mkdir>:
SYSCALL(mkdir)
    39f1:	b8 14 00 00 00       	mov    $0x14,%eax
    39f6:	cd 40                	int    $0x40
    39f8:	c3                   	ret    

000039f9 <chdir>:
SYSCALL(chdir)
    39f9:	b8 09 00 00 00       	mov    $0x9,%eax
    39fe:	cd 40                	int    $0x40
    3a00:	c3                   	ret    

00003a01 <dup>:
SYSCALL(dup)
    3a01:	b8 0a 00 00 00       	mov    $0xa,%eax
    3a06:	cd 40                	int    $0x40
    3a08:	c3                   	ret    

00003a09 <getpid>:
SYSCALL(getpid)
    3a09:	b8 0b 00 00 00       	mov    $0xb,%eax
    3a0e:	cd 40                	int    $0x40
    3a10:	c3                   	ret    

00003a11 <sbrk>:
SYSCALL(sbrk)
    3a11:	b8 0c 00 00 00       	mov    $0xc,%eax
    3a16:	cd 40                	int    $0x40
    3a18:	c3                   	ret    

00003a19 <sleep>:
SYSCALL(sleep)
    3a19:	b8 0d 00 00 00       	mov    $0xd,%eax
    3a1e:	cd 40                	int    $0x40
    3a20:	c3                   	ret    

00003a21 <uptime>:
SYSCALL(uptime)
    3a21:	b8 0e 00 00 00       	mov    $0xe,%eax
    3a26:	cd 40                	int    $0x40
    3a28:	c3                   	ret    

00003a29 <yield>:
SYSCALL(yield)
    3a29:	b8 16 00 00 00       	mov    $0x16,%eax
    3a2e:	cd 40                	int    $0x40
    3a30:	c3                   	ret    

00003a31 <shutdown>:
SYSCALL(shutdown)
    3a31:	b8 17 00 00 00       	mov    $0x17,%eax
    3a36:	cd 40                	int    $0x40
    3a38:	c3                   	ret    

00003a39 <getpagetableentry>:
SYSCALL(getpagetableentry)
    3a39:	b8 18 00 00 00       	mov    $0x18,%eax
    3a3e:	cd 40                	int    $0x40
    3a40:	c3                   	ret    

00003a41 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
    3a41:	b8 19 00 00 00       	mov    $0x19,%eax
    3a46:	cd 40                	int    $0x40
    3a48:	c3                   	ret    

00003a49 <dumppagetable>:
    3a49:	b8 1a 00 00 00       	mov    $0x1a,%eax
    3a4e:	cd 40                	int    $0x40
    3a50:	c3                   	ret    

00003a51 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    3a51:	55                   	push   %ebp
    3a52:	89 e5                	mov    %esp,%ebp
    3a54:	83 ec 1c             	sub    $0x1c,%esp
    3a57:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
    3a5a:	6a 01                	push   $0x1
    3a5c:	8d 55 f4             	lea    -0xc(%ebp),%edx
    3a5f:	52                   	push   %edx
    3a60:	50                   	push   %eax
    3a61:	e8 43 ff ff ff       	call   39a9 <write>
}
    3a66:	83 c4 10             	add    $0x10,%esp
    3a69:	c9                   	leave  
    3a6a:	c3                   	ret    

00003a6b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    3a6b:	55                   	push   %ebp
    3a6c:	89 e5                	mov    %esp,%ebp
    3a6e:	57                   	push   %edi
    3a6f:	56                   	push   %esi
    3a70:	53                   	push   %ebx
    3a71:	83 ec 2c             	sub    $0x2c,%esp
    3a74:	89 45 d0             	mov    %eax,-0x30(%ebp)
    3a77:	89 d0                	mov    %edx,%eax
    3a79:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    3a7b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    3a7f:	0f 95 c1             	setne  %cl
    3a82:	c1 ea 1f             	shr    $0x1f,%edx
    3a85:	84 d1                	test   %dl,%cl
    3a87:	74 44                	je     3acd <printint+0x62>
    neg = 1;
    x = -xx;
    3a89:	f7 d8                	neg    %eax
    3a8b:	89 c1                	mov    %eax,%ecx
    neg = 1;
    3a8d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
    3a94:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
    3a99:	89 c8                	mov    %ecx,%eax
    3a9b:	ba 00 00 00 00       	mov    $0x0,%edx
    3aa0:	f7 f6                	div    %esi
    3aa2:	89 df                	mov    %ebx,%edi
    3aa4:	83 c3 01             	add    $0x1,%ebx
    3aa7:	0f b6 92 9c 55 00 00 	movzbl 0x559c(%edx),%edx
    3aae:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
    3ab2:	89 ca                	mov    %ecx,%edx
    3ab4:	89 c1                	mov    %eax,%ecx
    3ab6:	39 d6                	cmp    %edx,%esi
    3ab8:	76 df                	jbe    3a99 <printint+0x2e>
  if(neg)
    3aba:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
    3abe:	74 31                	je     3af1 <printint+0x86>
    buf[i++] = '-';
    3ac0:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    3ac5:	8d 5f 02             	lea    0x2(%edi),%ebx
    3ac8:	8b 75 d0             	mov    -0x30(%ebp),%esi
    3acb:	eb 17                	jmp    3ae4 <printint+0x79>
    x = xx;
    3acd:	89 c1                	mov    %eax,%ecx
  neg = 0;
    3acf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    3ad6:	eb bc                	jmp    3a94 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
    3ad8:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
    3add:	89 f0                	mov    %esi,%eax
    3adf:	e8 6d ff ff ff       	call   3a51 <putc>
  while(--i >= 0)
    3ae4:	83 eb 01             	sub    $0x1,%ebx
    3ae7:	79 ef                	jns    3ad8 <printint+0x6d>
}
    3ae9:	83 c4 2c             	add    $0x2c,%esp
    3aec:	5b                   	pop    %ebx
    3aed:	5e                   	pop    %esi
    3aee:	5f                   	pop    %edi
    3aef:	5d                   	pop    %ebp
    3af0:	c3                   	ret    
    3af1:	8b 75 d0             	mov    -0x30(%ebp),%esi
    3af4:	eb ee                	jmp    3ae4 <printint+0x79>

00003af6 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
    3af6:	55                   	push   %ebp
    3af7:	89 e5                	mov    %esp,%ebp
    3af9:	57                   	push   %edi
    3afa:	56                   	push   %esi
    3afb:	53                   	push   %ebx
    3afc:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
    3aff:	8d 45 10             	lea    0x10(%ebp),%eax
    3b02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
    3b05:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
    3b0a:	bb 00 00 00 00       	mov    $0x0,%ebx
    3b0f:	eb 14                	jmp    3b25 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
    3b11:	89 fa                	mov    %edi,%edx
    3b13:	8b 45 08             	mov    0x8(%ebp),%eax
    3b16:	e8 36 ff ff ff       	call   3a51 <putc>
    3b1b:	eb 05                	jmp    3b22 <printf+0x2c>
      }
    } else if(state == '%'){
    3b1d:	83 fe 25             	cmp    $0x25,%esi
    3b20:	74 25                	je     3b47 <printf+0x51>
  for(i = 0; fmt[i]; i++){
    3b22:	83 c3 01             	add    $0x1,%ebx
    3b25:	8b 45 0c             	mov    0xc(%ebp),%eax
    3b28:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
    3b2c:	84 c0                	test   %al,%al
    3b2e:	0f 84 20 01 00 00    	je     3c54 <printf+0x15e>
    c = fmt[i] & 0xff;
    3b34:	0f be f8             	movsbl %al,%edi
    3b37:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
    3b3a:	85 f6                	test   %esi,%esi
    3b3c:	75 df                	jne    3b1d <printf+0x27>
      if(c == '%'){
    3b3e:	83 f8 25             	cmp    $0x25,%eax
    3b41:	75 ce                	jne    3b11 <printf+0x1b>
        state = '%';
    3b43:	89 c6                	mov    %eax,%esi
    3b45:	eb db                	jmp    3b22 <printf+0x2c>
      if(c == 'd'){
    3b47:	83 f8 25             	cmp    $0x25,%eax
    3b4a:	0f 84 cf 00 00 00    	je     3c1f <printf+0x129>
    3b50:	0f 8c dd 00 00 00    	jl     3c33 <printf+0x13d>
    3b56:	83 f8 78             	cmp    $0x78,%eax
    3b59:	0f 8f d4 00 00 00    	jg     3c33 <printf+0x13d>
    3b5f:	83 f8 63             	cmp    $0x63,%eax
    3b62:	0f 8c cb 00 00 00    	jl     3c33 <printf+0x13d>
    3b68:	83 e8 63             	sub    $0x63,%eax
    3b6b:	83 f8 15             	cmp    $0x15,%eax
    3b6e:	0f 87 bf 00 00 00    	ja     3c33 <printf+0x13d>
    3b74:	ff 24 85 44 55 00 00 	jmp    *0x5544(,%eax,4)
        printint(fd, *ap, 10, 1);
    3b7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    3b7e:	8b 17                	mov    (%edi),%edx
    3b80:	83 ec 0c             	sub    $0xc,%esp
    3b83:	6a 01                	push   $0x1
    3b85:	b9 0a 00 00 00       	mov    $0xa,%ecx
    3b8a:	8b 45 08             	mov    0x8(%ebp),%eax
    3b8d:	e8 d9 fe ff ff       	call   3a6b <printint>
        ap++;
    3b92:	83 c7 04             	add    $0x4,%edi
    3b95:	89 7d e4             	mov    %edi,-0x1c(%ebp)
    3b98:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    3b9b:	be 00 00 00 00       	mov    $0x0,%esi
    3ba0:	eb 80                	jmp    3b22 <printf+0x2c>
        printint(fd, *ap, 16, 0);
    3ba2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    3ba5:	8b 17                	mov    (%edi),%edx
    3ba7:	83 ec 0c             	sub    $0xc,%esp
    3baa:	6a 00                	push   $0x0
    3bac:	b9 10 00 00 00       	mov    $0x10,%ecx
    3bb1:	8b 45 08             	mov    0x8(%ebp),%eax
    3bb4:	e8 b2 fe ff ff       	call   3a6b <printint>
        ap++;
    3bb9:	83 c7 04             	add    $0x4,%edi
    3bbc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
    3bbf:	83 c4 10             	add    $0x10,%esp
      state = 0;
    3bc2:	be 00 00 00 00       	mov    $0x0,%esi
    3bc7:	e9 56 ff ff ff       	jmp    3b22 <printf+0x2c>
        s = (char*)*ap;
    3bcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3bcf:	8b 30                	mov    (%eax),%esi
        ap++;
    3bd1:	83 c0 04             	add    $0x4,%eax
    3bd4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
    3bd7:	85 f6                	test   %esi,%esi
    3bd9:	75 15                	jne    3bf0 <printf+0xfa>
          s = "(null)";
    3bdb:	be 3a 55 00 00       	mov    $0x553a,%esi
    3be0:	eb 0e                	jmp    3bf0 <printf+0xfa>
          putc(fd, *s);
    3be2:	0f be d2             	movsbl %dl,%edx
    3be5:	8b 45 08             	mov    0x8(%ebp),%eax
    3be8:	e8 64 fe ff ff       	call   3a51 <putc>
          s++;
    3bed:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
    3bf0:	0f b6 16             	movzbl (%esi),%edx
    3bf3:	84 d2                	test   %dl,%dl
    3bf5:	75 eb                	jne    3be2 <printf+0xec>
      state = 0;
    3bf7:	be 00 00 00 00       	mov    $0x0,%esi
    3bfc:	e9 21 ff ff ff       	jmp    3b22 <printf+0x2c>
        putc(fd, *ap);
    3c01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    3c04:	0f be 17             	movsbl (%edi),%edx
    3c07:	8b 45 08             	mov    0x8(%ebp),%eax
    3c0a:	e8 42 fe ff ff       	call   3a51 <putc>
        ap++;
    3c0f:	83 c7 04             	add    $0x4,%edi
    3c12:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
    3c15:	be 00 00 00 00       	mov    $0x0,%esi
    3c1a:	e9 03 ff ff ff       	jmp    3b22 <printf+0x2c>
        putc(fd, c);
    3c1f:	89 fa                	mov    %edi,%edx
    3c21:	8b 45 08             	mov    0x8(%ebp),%eax
    3c24:	e8 28 fe ff ff       	call   3a51 <putc>
      state = 0;
    3c29:	be 00 00 00 00       	mov    $0x0,%esi
    3c2e:	e9 ef fe ff ff       	jmp    3b22 <printf+0x2c>
        putc(fd, '%');
    3c33:	ba 25 00 00 00       	mov    $0x25,%edx
    3c38:	8b 45 08             	mov    0x8(%ebp),%eax
    3c3b:	e8 11 fe ff ff       	call   3a51 <putc>
        putc(fd, c);
    3c40:	89 fa                	mov    %edi,%edx
    3c42:	8b 45 08             	mov    0x8(%ebp),%eax
    3c45:	e8 07 fe ff ff       	call   3a51 <putc>
      state = 0;
    3c4a:	be 00 00 00 00       	mov    $0x0,%esi
    3c4f:	e9 ce fe ff ff       	jmp    3b22 <printf+0x2c>
    }
  }
}
    3c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
    3c57:	5b                   	pop    %ebx
    3c58:	5e                   	pop    %esi
    3c59:	5f                   	pop    %edi
    3c5a:	5d                   	pop    %ebp
    3c5b:	c3                   	ret    

00003c5c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    3c5c:	55                   	push   %ebp
    3c5d:	89 e5                	mov    %esp,%ebp
    3c5f:	57                   	push   %edi
    3c60:	56                   	push   %esi
    3c61:	53                   	push   %ebx
    3c62:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
    3c65:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    3c68:	a1 60 56 00 00       	mov    0x5660,%eax
    3c6d:	eb 02                	jmp    3c71 <free+0x15>
    3c6f:	89 d0                	mov    %edx,%eax
    3c71:	39 c8                	cmp    %ecx,%eax
    3c73:	73 04                	jae    3c79 <free+0x1d>
    3c75:	39 08                	cmp    %ecx,(%eax)
    3c77:	77 12                	ja     3c8b <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    3c79:	8b 10                	mov    (%eax),%edx
    3c7b:	39 c2                	cmp    %eax,%edx
    3c7d:	77 f0                	ja     3c6f <free+0x13>
    3c7f:	39 c8                	cmp    %ecx,%eax
    3c81:	72 08                	jb     3c8b <free+0x2f>
    3c83:	39 ca                	cmp    %ecx,%edx
    3c85:	77 04                	ja     3c8b <free+0x2f>
    3c87:	89 d0                	mov    %edx,%eax
    3c89:	eb e6                	jmp    3c71 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
    3c8b:	8b 73 fc             	mov    -0x4(%ebx),%esi
    3c8e:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
    3c91:	8b 10                	mov    (%eax),%edx
    3c93:	39 d7                	cmp    %edx,%edi
    3c95:	74 19                	je     3cb0 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
    3c97:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
    3c9a:	8b 50 04             	mov    0x4(%eax),%edx
    3c9d:	8d 34 d0             	lea    (%eax,%edx,8),%esi
    3ca0:	39 ce                	cmp    %ecx,%esi
    3ca2:	74 1b                	je     3cbf <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
    3ca4:	89 08                	mov    %ecx,(%eax)
  freep = p;
    3ca6:	a3 60 56 00 00       	mov    %eax,0x5660
}
    3cab:	5b                   	pop    %ebx
    3cac:	5e                   	pop    %esi
    3cad:	5f                   	pop    %edi
    3cae:	5d                   	pop    %ebp
    3caf:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
    3cb0:	03 72 04             	add    0x4(%edx),%esi
    3cb3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
    3cb6:	8b 10                	mov    (%eax),%edx
    3cb8:	8b 12                	mov    (%edx),%edx
    3cba:	89 53 f8             	mov    %edx,-0x8(%ebx)
    3cbd:	eb db                	jmp    3c9a <free+0x3e>
    p->s.size += bp->s.size;
    3cbf:	03 53 fc             	add    -0x4(%ebx),%edx
    3cc2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    3cc5:	8b 53 f8             	mov    -0x8(%ebx),%edx
    3cc8:	89 10                	mov    %edx,(%eax)
    3cca:	eb da                	jmp    3ca6 <free+0x4a>

00003ccc <morecore>:

static Header*
morecore(uint nu)
{
    3ccc:	55                   	push   %ebp
    3ccd:	89 e5                	mov    %esp,%ebp
    3ccf:	53                   	push   %ebx
    3cd0:	83 ec 04             	sub    $0x4,%esp
    3cd3:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
    3cd5:	3d ff 0f 00 00       	cmp    $0xfff,%eax
    3cda:	77 05                	ja     3ce1 <morecore+0x15>
    nu = 4096;
    3cdc:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
    3ce1:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
    3ce8:	83 ec 0c             	sub    $0xc,%esp
    3ceb:	50                   	push   %eax
    3cec:	e8 20 fd ff ff       	call   3a11 <sbrk>
  if(p == (char*)-1)
    3cf1:	83 c4 10             	add    $0x10,%esp
    3cf4:	83 f8 ff             	cmp    $0xffffffff,%eax
    3cf7:	74 1c                	je     3d15 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
    3cf9:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
    3cfc:	83 c0 08             	add    $0x8,%eax
    3cff:	83 ec 0c             	sub    $0xc,%esp
    3d02:	50                   	push   %eax
    3d03:	e8 54 ff ff ff       	call   3c5c <free>
  return freep;
    3d08:	a1 60 56 00 00       	mov    0x5660,%eax
    3d0d:	83 c4 10             	add    $0x10,%esp
}
    3d10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    3d13:	c9                   	leave  
    3d14:	c3                   	ret    
    return 0;
    3d15:	b8 00 00 00 00       	mov    $0x0,%eax
    3d1a:	eb f4                	jmp    3d10 <morecore+0x44>

00003d1c <malloc>:

void*
malloc(uint nbytes)
{
    3d1c:	55                   	push   %ebp
    3d1d:	89 e5                	mov    %esp,%ebp
    3d1f:	53                   	push   %ebx
    3d20:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    3d23:	8b 45 08             	mov    0x8(%ebp),%eax
    3d26:	8d 58 07             	lea    0x7(%eax),%ebx
    3d29:	c1 eb 03             	shr    $0x3,%ebx
    3d2c:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
    3d2f:	8b 0d 60 56 00 00    	mov    0x5660,%ecx
    3d35:	85 c9                	test   %ecx,%ecx
    3d37:	74 04                	je     3d3d <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    3d39:	8b 01                	mov    (%ecx),%eax
    3d3b:	eb 4a                	jmp    3d87 <malloc+0x6b>
    base.s.ptr = freep = prevp = &base;
    3d3d:	c7 05 60 56 00 00 64 	movl   $0x5664,0x5660
    3d44:	56 00 00 
    3d47:	c7 05 64 56 00 00 64 	movl   $0x5664,0x5664
    3d4e:	56 00 00 
    base.s.size = 0;
    3d51:	c7 05 68 56 00 00 00 	movl   $0x0,0x5668
    3d58:	00 00 00 
    base.s.ptr = freep = prevp = &base;
    3d5b:	b9 64 56 00 00       	mov    $0x5664,%ecx
    3d60:	eb d7                	jmp    3d39 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
    3d62:	74 19                	je     3d7d <malloc+0x61>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
    3d64:	29 da                	sub    %ebx,%edx
    3d66:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    3d69:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
    3d6c:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
    3d6f:	89 0d 60 56 00 00    	mov    %ecx,0x5660
      return (void*)(p + 1);
    3d75:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    3d78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    3d7b:	c9                   	leave  
    3d7c:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
    3d7d:	8b 10                	mov    (%eax),%edx
    3d7f:	89 11                	mov    %edx,(%ecx)
    3d81:	eb ec                	jmp    3d6f <malloc+0x53>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    3d83:	89 c1                	mov    %eax,%ecx
    3d85:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
    3d87:	8b 50 04             	mov    0x4(%eax),%edx
    3d8a:	39 da                	cmp    %ebx,%edx
    3d8c:	73 d4                	jae    3d62 <malloc+0x46>
    if(p == freep)
    3d8e:	39 05 60 56 00 00    	cmp    %eax,0x5660
    3d94:	75 ed                	jne    3d83 <malloc+0x67>
      if((p = morecore(nunits)) == 0)
    3d96:	89 d8                	mov    %ebx,%eax
    3d98:	e8 2f ff ff ff       	call   3ccc <morecore>
    3d9d:	85 c0                	test   %eax,%eax
    3d9f:	75 e2                	jne    3d83 <malloc+0x67>
    3da1:	eb d5                	jmp    3d78 <malloc+0x5c>
