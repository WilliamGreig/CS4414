
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <getcmd>:
  exit();
}

int
getcmd(char *buf, int nbuf)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 5d 08             	mov    0x8(%ebp),%ebx
   8:	8b 75 0c             	mov    0xc(%ebp),%esi
  printf(2, "$ ");
   b:	83 ec 08             	sub    $0x8,%esp
   e:	68 74 0f 00 00       	push   $0xf74
  13:	6a 02                	push   $0x2
  15:	e8 aa 0c 00 00       	call   cc4 <printf>
  memset(buf, 0, nbuf);
  1a:	83 c4 0c             	add    $0xc,%esp
  1d:	56                   	push   %esi
  1e:	6a 00                	push   $0x0
  20:	53                   	push   %ebx
  21:	e8 f6 09 00 00       	call   a1c <memset>
  gets(buf, nbuf);
  26:	83 c4 08             	add    $0x8,%esp
  29:	56                   	push   %esi
  2a:	53                   	push   %ebx
  2b:	e8 28 0a 00 00       	call   a58 <gets>
  if(buf[0] == 0) // EOF
  30:	83 c4 10             	add    $0x10,%esp
  33:	80 3b 00             	cmpb   $0x0,(%ebx)
  36:	74 0c                	je     44 <getcmd+0x44>
    return -1;
  return 0;
  38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  40:	5b                   	pop    %ebx
  41:	5e                   	pop    %esi
  42:	5d                   	pop    %ebp
  43:	c3                   	ret    
    return -1;
  44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  49:	eb f2                	jmp    3d <getcmd+0x3d>

0000004b <panic>:
  exit();
}

void
panic(char *s)
{
  4b:	55                   	push   %ebp
  4c:	89 e5                	mov    %esp,%ebp
  4e:	83 ec 0c             	sub    $0xc,%esp
  printf(2, "%s\n", s);
  51:	ff 75 08             	push   0x8(%ebp)
  54:	68 11 10 00 00       	push   $0x1011
  59:	6a 02                	push   $0x2
  5b:	e8 64 0c 00 00       	call   cc4 <printf>
  exit();
  60:	e8 f2 0a 00 00       	call   b57 <exit>

00000065 <fork1>:
}

int
fork1(void)
{
  65:	55                   	push   %ebp
  66:	89 e5                	mov    %esp,%ebp
  68:	83 ec 08             	sub    $0x8,%esp
  int pid;

  pid = fork();
  6b:	e8 df 0a 00 00       	call   b4f <fork>
  if(pid == -1)
  70:	83 f8 ff             	cmp    $0xffffffff,%eax
  73:	74 02                	je     77 <fork1+0x12>
    panic("fork");
  return pid;
}
  75:	c9                   	leave  
  76:	c3                   	ret    
    panic("fork");
  77:	83 ec 0c             	sub    $0xc,%esp
  7a:	68 77 0f 00 00       	push   $0xf77
  7f:	e8 c7 ff ff ff       	call   4b <panic>

00000084 <runcmd>:
{
  84:	55                   	push   %ebp
  85:	89 e5                	mov    %esp,%ebp
  87:	53                   	push   %ebx
  88:	83 ec 14             	sub    $0x14,%esp
  8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(cmd == 0)
  8e:	85 db                	test   %ebx,%ebx
  90:	74 0e                	je     a0 <runcmd+0x1c>
  switch(cmd->type){
  92:	8b 03                	mov    (%ebx),%eax
  94:	83 f8 05             	cmp    $0x5,%eax
  97:	77 0c                	ja     a5 <runcmd+0x21>
  99:	ff 24 85 2c 10 00 00 	jmp    *0x102c(,%eax,4)
    exit();
  a0:	e8 b2 0a 00 00       	call   b57 <exit>
    panic("runcmd");
  a5:	83 ec 0c             	sub    $0xc,%esp
  a8:	68 7c 0f 00 00       	push   $0xf7c
  ad:	e8 99 ff ff ff       	call   4b <panic>
    if(ecmd->argv[0] == 0)
  b2:	8b 43 04             	mov    0x4(%ebx),%eax
  b5:	85 c0                	test   %eax,%eax
  b7:	74 27                	je     e0 <runcmd+0x5c>
    exec(ecmd->argv[0], ecmd->argv);
  b9:	8d 53 04             	lea    0x4(%ebx),%edx
  bc:	83 ec 08             	sub    $0x8,%esp
  bf:	52                   	push   %edx
  c0:	50                   	push   %eax
  c1:	e8 c9 0a 00 00       	call   b8f <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
  c6:	83 c4 0c             	add    $0xc,%esp
  c9:	ff 73 04             	push   0x4(%ebx)
  cc:	68 83 0f 00 00       	push   $0xf83
  d1:	6a 02                	push   $0x2
  d3:	e8 ec 0b 00 00       	call   cc4 <printf>
    break;
  d8:	83 c4 10             	add    $0x10,%esp
  exit();
  db:	e8 77 0a 00 00       	call   b57 <exit>
      exit();
  e0:	e8 72 0a 00 00       	call   b57 <exit>
    close(rcmd->fd);
  e5:	83 ec 0c             	sub    $0xc,%esp
  e8:	ff 73 14             	push   0x14(%ebx)
  eb:	e8 8f 0a 00 00       	call   b7f <close>
    if(open(rcmd->file, rcmd->mode) < 0){
  f0:	83 c4 08             	add    $0x8,%esp
  f3:	ff 73 10             	push   0x10(%ebx)
  f6:	ff 73 08             	push   0x8(%ebx)
  f9:	e8 99 0a 00 00       	call   b97 <open>
  fe:	83 c4 10             	add    $0x10,%esp
 101:	85 c0                	test   %eax,%eax
 103:	78 0b                	js     110 <runcmd+0x8c>
    runcmd(rcmd->cmd);
 105:	83 ec 0c             	sub    $0xc,%esp
 108:	ff 73 04             	push   0x4(%ebx)
 10b:	e8 74 ff ff ff       	call   84 <runcmd>
      printf(2, "open %s failed\n", rcmd->file);
 110:	83 ec 04             	sub    $0x4,%esp
 113:	ff 73 08             	push   0x8(%ebx)
 116:	68 93 0f 00 00       	push   $0xf93
 11b:	6a 02                	push   $0x2
 11d:	e8 a2 0b 00 00       	call   cc4 <printf>
      exit();
 122:	e8 30 0a 00 00       	call   b57 <exit>
    if(fork1() == 0)
 127:	e8 39 ff ff ff       	call   65 <fork1>
 12c:	85 c0                	test   %eax,%eax
 12e:	74 10                	je     140 <runcmd+0xbc>
    wait();
 130:	e8 2a 0a 00 00       	call   b5f <wait>
    runcmd(lcmd->right);
 135:	83 ec 0c             	sub    $0xc,%esp
 138:	ff 73 08             	push   0x8(%ebx)
 13b:	e8 44 ff ff ff       	call   84 <runcmd>
      runcmd(lcmd->left);
 140:	83 ec 0c             	sub    $0xc,%esp
 143:	ff 73 04             	push   0x4(%ebx)
 146:	e8 39 ff ff ff       	call   84 <runcmd>
    if(pipe(p) < 0)
 14b:	83 ec 0c             	sub    $0xc,%esp
 14e:	8d 45 f0             	lea    -0x10(%ebp),%eax
 151:	50                   	push   %eax
 152:	e8 10 0a 00 00       	call   b67 <pipe>
 157:	83 c4 10             	add    $0x10,%esp
 15a:	85 c0                	test   %eax,%eax
 15c:	78 3a                	js     198 <runcmd+0x114>
    if(fork1() == 0){
 15e:	e8 02 ff ff ff       	call   65 <fork1>
 163:	85 c0                	test   %eax,%eax
 165:	74 3e                	je     1a5 <runcmd+0x121>
    if(fork1() == 0){
 167:	e8 f9 fe ff ff       	call   65 <fork1>
 16c:	85 c0                	test   %eax,%eax
 16e:	74 6b                	je     1db <runcmd+0x157>
    close(p[0]);
 170:	83 ec 0c             	sub    $0xc,%esp
 173:	ff 75 f0             	push   -0x10(%ebp)
 176:	e8 04 0a 00 00       	call   b7f <close>
    close(p[1]);
 17b:	83 c4 04             	add    $0x4,%esp
 17e:	ff 75 f4             	push   -0xc(%ebp)
 181:	e8 f9 09 00 00       	call   b7f <close>
    wait();
 186:	e8 d4 09 00 00       	call   b5f <wait>
    wait();
 18b:	e8 cf 09 00 00       	call   b5f <wait>
    break;
 190:	83 c4 10             	add    $0x10,%esp
 193:	e9 43 ff ff ff       	jmp    db <runcmd+0x57>
      panic("pipe");
 198:	83 ec 0c             	sub    $0xc,%esp
 19b:	68 a3 0f 00 00       	push   $0xfa3
 1a0:	e8 a6 fe ff ff       	call   4b <panic>
      close(1);
 1a5:	83 ec 0c             	sub    $0xc,%esp
 1a8:	6a 01                	push   $0x1
 1aa:	e8 d0 09 00 00       	call   b7f <close>
      dup(p[1]);
 1af:	83 c4 04             	add    $0x4,%esp
 1b2:	ff 75 f4             	push   -0xc(%ebp)
 1b5:	e8 15 0a 00 00       	call   bcf <dup>
      close(p[0]);
 1ba:	83 c4 04             	add    $0x4,%esp
 1bd:	ff 75 f0             	push   -0x10(%ebp)
 1c0:	e8 ba 09 00 00       	call   b7f <close>
      close(p[1]);
 1c5:	83 c4 04             	add    $0x4,%esp
 1c8:	ff 75 f4             	push   -0xc(%ebp)
 1cb:	e8 af 09 00 00       	call   b7f <close>
      runcmd(pcmd->left);
 1d0:	83 c4 04             	add    $0x4,%esp
 1d3:	ff 73 04             	push   0x4(%ebx)
 1d6:	e8 a9 fe ff ff       	call   84 <runcmd>
      close(0);
 1db:	83 ec 0c             	sub    $0xc,%esp
 1de:	6a 00                	push   $0x0
 1e0:	e8 9a 09 00 00       	call   b7f <close>
      dup(p[0]);
 1e5:	83 c4 04             	add    $0x4,%esp
 1e8:	ff 75 f0             	push   -0x10(%ebp)
 1eb:	e8 df 09 00 00       	call   bcf <dup>
      close(p[0]);
 1f0:	83 c4 04             	add    $0x4,%esp
 1f3:	ff 75 f0             	push   -0x10(%ebp)
 1f6:	e8 84 09 00 00       	call   b7f <close>
      close(p[1]);
 1fb:	83 c4 04             	add    $0x4,%esp
 1fe:	ff 75 f4             	push   -0xc(%ebp)
 201:	e8 79 09 00 00       	call   b7f <close>
      runcmd(pcmd->right);
 206:	83 c4 04             	add    $0x4,%esp
 209:	ff 73 08             	push   0x8(%ebx)
 20c:	e8 73 fe ff ff       	call   84 <runcmd>
    if(fork1() == 0)
 211:	e8 4f fe ff ff       	call   65 <fork1>
 216:	85 c0                	test   %eax,%eax
 218:	0f 85 bd fe ff ff    	jne    db <runcmd+0x57>
      runcmd(bcmd->cmd);
 21e:	83 ec 0c             	sub    $0xc,%esp
 221:	ff 73 04             	push   0x4(%ebx)
 224:	e8 5b fe ff ff       	call   84 <runcmd>

00000229 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
 229:	55                   	push   %ebp
 22a:	89 e5                	mov    %esp,%ebp
 22c:	53                   	push   %ebx
 22d:	83 ec 10             	sub    $0x10,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
 230:	68 a4 00 00 00       	push   $0xa4
 235:	e8 b0 0c 00 00       	call   eea <malloc>
 23a:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 23c:	83 c4 0c             	add    $0xc,%esp
 23f:	68 a4 00 00 00       	push   $0xa4
 244:	6a 00                	push   $0x0
 246:	50                   	push   %eax
 247:	e8 d0 07 00 00       	call   a1c <memset>
  cmd->type = EXEC;
 24c:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  return (struct cmd*)cmd;
}
 252:	89 d8                	mov    %ebx,%eax
 254:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 257:	c9                   	leave  
 258:	c3                   	ret    

00000259 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
 259:	55                   	push   %ebp
 25a:	89 e5                	mov    %esp,%ebp
 25c:	53                   	push   %ebx
 25d:	83 ec 10             	sub    $0x10,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
 260:	6a 18                	push   $0x18
 262:	e8 83 0c 00 00       	call   eea <malloc>
 267:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 269:	83 c4 0c             	add    $0xc,%esp
 26c:	6a 18                	push   $0x18
 26e:	6a 00                	push   $0x0
 270:	50                   	push   %eax
 271:	e8 a6 07 00 00       	call   a1c <memset>
  cmd->type = REDIR;
 276:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  cmd->cmd = subcmd;
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->file = file;
 282:	8b 45 0c             	mov    0xc(%ebp),%eax
 285:	89 43 08             	mov    %eax,0x8(%ebx)
  cmd->efile = efile;
 288:	8b 45 10             	mov    0x10(%ebp),%eax
 28b:	89 43 0c             	mov    %eax,0xc(%ebx)
  cmd->mode = mode;
 28e:	8b 45 14             	mov    0x14(%ebp),%eax
 291:	89 43 10             	mov    %eax,0x10(%ebx)
  cmd->fd = fd;
 294:	8b 45 18             	mov    0x18(%ebp),%eax
 297:	89 43 14             	mov    %eax,0x14(%ebx)
  return (struct cmd*)cmd;
}
 29a:	89 d8                	mov    %ebx,%eax
 29c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 29f:	c9                   	leave  
 2a0:	c3                   	ret    

000002a1 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
 2a1:	55                   	push   %ebp
 2a2:	89 e5                	mov    %esp,%ebp
 2a4:	53                   	push   %ebx
 2a5:	83 ec 10             	sub    $0x10,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
 2a8:	6a 0c                	push   $0xc
 2aa:	e8 3b 0c 00 00       	call   eea <malloc>
 2af:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 2b1:	83 c4 0c             	add    $0xc,%esp
 2b4:	6a 0c                	push   $0xc
 2b6:	6a 00                	push   $0x0
 2b8:	50                   	push   %eax
 2b9:	e8 5e 07 00 00       	call   a1c <memset>
  cmd->type = PIPE;
 2be:	c7 03 03 00 00 00    	movl   $0x3,(%ebx)
  cmd->left = left;
 2c4:	8b 45 08             	mov    0x8(%ebp),%eax
 2c7:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->right = right;
 2ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cd:	89 43 08             	mov    %eax,0x8(%ebx)
  return (struct cmd*)cmd;
}
 2d0:	89 d8                	mov    %ebx,%eax
 2d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2d5:	c9                   	leave  
 2d6:	c3                   	ret    

000002d7 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
 2d7:	55                   	push   %ebp
 2d8:	89 e5                	mov    %esp,%ebp
 2da:	53                   	push   %ebx
 2db:	83 ec 10             	sub    $0x10,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
 2de:	6a 0c                	push   $0xc
 2e0:	e8 05 0c 00 00       	call   eea <malloc>
 2e5:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 2e7:	83 c4 0c             	add    $0xc,%esp
 2ea:	6a 0c                	push   $0xc
 2ec:	6a 00                	push   $0x0
 2ee:	50                   	push   %eax
 2ef:	e8 28 07 00 00       	call   a1c <memset>
  cmd->type = LIST;
 2f4:	c7 03 04 00 00 00    	movl   $0x4,(%ebx)
  cmd->left = left;
 2fa:	8b 45 08             	mov    0x8(%ebp),%eax
 2fd:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->right = right;
 300:	8b 45 0c             	mov    0xc(%ebp),%eax
 303:	89 43 08             	mov    %eax,0x8(%ebx)
  return (struct cmd*)cmd;
}
 306:	89 d8                	mov    %ebx,%eax
 308:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 30b:	c9                   	leave  
 30c:	c3                   	ret    

0000030d <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
 30d:	55                   	push   %ebp
 30e:	89 e5                	mov    %esp,%ebp
 310:	53                   	push   %ebx
 311:	83 ec 10             	sub    $0x10,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
 314:	6a 08                	push   $0x8
 316:	e8 cf 0b 00 00       	call   eea <malloc>
 31b:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 31d:	83 c4 0c             	add    $0xc,%esp
 320:	6a 08                	push   $0x8
 322:	6a 00                	push   $0x0
 324:	50                   	push   %eax
 325:	e8 f2 06 00 00       	call   a1c <memset>
  cmd->type = BACK;
 32a:	c7 03 05 00 00 00    	movl   $0x5,(%ebx)
  cmd->cmd = subcmd;
 330:	8b 45 08             	mov    0x8(%ebp),%eax
 333:	89 43 04             	mov    %eax,0x4(%ebx)
  return (struct cmd*)cmd;
}
 336:	89 d8                	mov    %ebx,%eax
 338:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 33b:	c9                   	leave  
 33c:	c3                   	ret    

0000033d <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
 33d:	55                   	push   %ebp
 33e:	89 e5                	mov    %esp,%ebp
 340:	57                   	push   %edi
 341:	56                   	push   %esi
 342:	53                   	push   %ebx
 343:	83 ec 0c             	sub    $0xc,%esp
 346:	8b 75 0c             	mov    0xc(%ebp),%esi
 349:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *s;
  int ret;

  s = *ps;
 34c:	8b 45 08             	mov    0x8(%ebp),%eax
 34f:	8b 18                	mov    (%eax),%ebx
  while(s < es && strchr(whitespace, *s))
 351:	eb 03                	jmp    356 <gettoken+0x19>
    s++;
 353:	83 c3 01             	add    $0x1,%ebx
  while(s < es && strchr(whitespace, *s))
 356:	39 f3                	cmp    %esi,%ebx
 358:	73 18                	jae    372 <gettoken+0x35>
 35a:	83 ec 08             	sub    $0x8,%esp
 35d:	0f be 03             	movsbl (%ebx),%eax
 360:	50                   	push   %eax
 361:	68 d8 10 00 00       	push   $0x10d8
 366:	e8 ca 06 00 00       	call   a35 <strchr>
 36b:	83 c4 10             	add    $0x10,%esp
 36e:	85 c0                	test   %eax,%eax
 370:	75 e1                	jne    353 <gettoken+0x16>
  if(q)
 372:	85 ff                	test   %edi,%edi
 374:	74 02                	je     378 <gettoken+0x3b>
    *q = s;
 376:	89 1f                	mov    %ebx,(%edi)
  ret = *s;
 378:	0f b6 03             	movzbl (%ebx),%eax
 37b:	0f be f8             	movsbl %al,%edi
  switch(*s){
 37e:	3c 3c                	cmp    $0x3c,%al
 380:	7f 27                	jg     3a9 <gettoken+0x6c>
 382:	3c 3b                	cmp    $0x3b,%al
 384:	7d 13                	jge    399 <gettoken+0x5c>
 386:	84 c0                	test   %al,%al
 388:	74 12                	je     39c <gettoken+0x5f>
 38a:	78 41                	js     3cd <gettoken+0x90>
 38c:	3c 26                	cmp    $0x26,%al
 38e:	74 09                	je     399 <gettoken+0x5c>
 390:	7c 3b                	jl     3cd <gettoken+0x90>
 392:	83 e8 28             	sub    $0x28,%eax
 395:	3c 01                	cmp    $0x1,%al
 397:	77 34                	ja     3cd <gettoken+0x90>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
 399:	83 c3 01             	add    $0x1,%ebx
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
 39c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3a0:	74 77                	je     419 <gettoken+0xdc>
    *eq = s;
 3a2:	8b 45 14             	mov    0x14(%ebp),%eax
 3a5:	89 18                	mov    %ebx,(%eax)
 3a7:	eb 70                	jmp    419 <gettoken+0xdc>
  switch(*s){
 3a9:	3c 3e                	cmp    $0x3e,%al
 3ab:	75 0d                	jne    3ba <gettoken+0x7d>
    s++;
 3ad:	8d 43 01             	lea    0x1(%ebx),%eax
    if(*s == '>'){
 3b0:	80 7b 01 3e          	cmpb   $0x3e,0x1(%ebx)
 3b4:	74 0a                	je     3c0 <gettoken+0x83>
    s++;
 3b6:	89 c3                	mov    %eax,%ebx
 3b8:	eb e2                	jmp    39c <gettoken+0x5f>
  switch(*s){
 3ba:	3c 7c                	cmp    $0x7c,%al
 3bc:	75 0f                	jne    3cd <gettoken+0x90>
 3be:	eb d9                	jmp    399 <gettoken+0x5c>
      s++;
 3c0:	83 c3 02             	add    $0x2,%ebx
      ret = '+';
 3c3:	bf 2b 00 00 00       	mov    $0x2b,%edi
 3c8:	eb d2                	jmp    39c <gettoken+0x5f>
      s++;
 3ca:	83 c3 01             	add    $0x1,%ebx
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
 3cd:	39 f3                	cmp    %esi,%ebx
 3cf:	73 37                	jae    408 <gettoken+0xcb>
 3d1:	83 ec 08             	sub    $0x8,%esp
 3d4:	0f be 03             	movsbl (%ebx),%eax
 3d7:	50                   	push   %eax
 3d8:	68 d8 10 00 00       	push   $0x10d8
 3dd:	e8 53 06 00 00       	call   a35 <strchr>
 3e2:	83 c4 10             	add    $0x10,%esp
 3e5:	85 c0                	test   %eax,%eax
 3e7:	75 26                	jne    40f <gettoken+0xd2>
 3e9:	83 ec 08             	sub    $0x8,%esp
 3ec:	0f be 03             	movsbl (%ebx),%eax
 3ef:	50                   	push   %eax
 3f0:	68 d0 10 00 00       	push   $0x10d0
 3f5:	e8 3b 06 00 00       	call   a35 <strchr>
 3fa:	83 c4 10             	add    $0x10,%esp
 3fd:	85 c0                	test   %eax,%eax
 3ff:	74 c9                	je     3ca <gettoken+0x8d>
    ret = 'a';
 401:	bf 61 00 00 00       	mov    $0x61,%edi
 406:	eb 94                	jmp    39c <gettoken+0x5f>
 408:	bf 61 00 00 00       	mov    $0x61,%edi
 40d:	eb 8d                	jmp    39c <gettoken+0x5f>
 40f:	bf 61 00 00 00       	mov    $0x61,%edi
 414:	eb 86                	jmp    39c <gettoken+0x5f>

  while(s < es && strchr(whitespace, *s))
    s++;
 416:	83 c3 01             	add    $0x1,%ebx
  while(s < es && strchr(whitespace, *s))
 419:	39 f3                	cmp    %esi,%ebx
 41b:	73 18                	jae    435 <gettoken+0xf8>
 41d:	83 ec 08             	sub    $0x8,%esp
 420:	0f be 03             	movsbl (%ebx),%eax
 423:	50                   	push   %eax
 424:	68 d8 10 00 00       	push   $0x10d8
 429:	e8 07 06 00 00       	call   a35 <strchr>
 42e:	83 c4 10             	add    $0x10,%esp
 431:	85 c0                	test   %eax,%eax
 433:	75 e1                	jne    416 <gettoken+0xd9>
  *ps = s;
 435:	8b 45 08             	mov    0x8(%ebp),%eax
 438:	89 18                	mov    %ebx,(%eax)
  return ret;
}
 43a:	89 f8                	mov    %edi,%eax
 43c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 43f:	5b                   	pop    %ebx
 440:	5e                   	pop    %esi
 441:	5f                   	pop    %edi
 442:	5d                   	pop    %ebp
 443:	c3                   	ret    

00000444 <peek>:

int
peek(char **ps, char *es, char *toks)
{
 444:	55                   	push   %ebp
 445:	89 e5                	mov    %esp,%ebp
 447:	57                   	push   %edi
 448:	56                   	push   %esi
 449:	53                   	push   %ebx
 44a:	83 ec 0c             	sub    $0xc,%esp
 44d:	8b 7d 08             	mov    0x8(%ebp),%edi
 450:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *s;

  s = *ps;
 453:	8b 1f                	mov    (%edi),%ebx
  while(s < es && strchr(whitespace, *s))
 455:	eb 03                	jmp    45a <peek+0x16>
    s++;
 457:	83 c3 01             	add    $0x1,%ebx
  while(s < es && strchr(whitespace, *s))
 45a:	39 f3                	cmp    %esi,%ebx
 45c:	73 18                	jae    476 <peek+0x32>
 45e:	83 ec 08             	sub    $0x8,%esp
 461:	0f be 03             	movsbl (%ebx),%eax
 464:	50                   	push   %eax
 465:	68 d8 10 00 00       	push   $0x10d8
 46a:	e8 c6 05 00 00       	call   a35 <strchr>
 46f:	83 c4 10             	add    $0x10,%esp
 472:	85 c0                	test   %eax,%eax
 474:	75 e1                	jne    457 <peek+0x13>
  *ps = s;
 476:	89 1f                	mov    %ebx,(%edi)
  return *s && strchr(toks, *s);
 478:	0f b6 03             	movzbl (%ebx),%eax
 47b:	84 c0                	test   %al,%al
 47d:	75 0d                	jne    48c <peek+0x48>
 47f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 484:	8d 65 f4             	lea    -0xc(%ebp),%esp
 487:	5b                   	pop    %ebx
 488:	5e                   	pop    %esi
 489:	5f                   	pop    %edi
 48a:	5d                   	pop    %ebp
 48b:	c3                   	ret    
  return *s && strchr(toks, *s);
 48c:	83 ec 08             	sub    $0x8,%esp
 48f:	0f be c0             	movsbl %al,%eax
 492:	50                   	push   %eax
 493:	ff 75 10             	push   0x10(%ebp)
 496:	e8 9a 05 00 00       	call   a35 <strchr>
 49b:	83 c4 10             	add    $0x10,%esp
 49e:	85 c0                	test   %eax,%eax
 4a0:	74 07                	je     4a9 <peek+0x65>
 4a2:	b8 01 00 00 00       	mov    $0x1,%eax
 4a7:	eb db                	jmp    484 <peek+0x40>
 4a9:	b8 00 00 00 00       	mov    $0x0,%eax
 4ae:	eb d4                	jmp    484 <peek+0x40>

000004b0 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	57                   	push   %edi
 4b4:	56                   	push   %esi
 4b5:	53                   	push   %ebx
 4b6:	83 ec 1c             	sub    $0x1c,%esp
 4b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
 4bc:	8b 75 10             	mov    0x10(%ebp),%esi
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
 4bf:	eb 28                	jmp    4e9 <parseredirs+0x39>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
      panic("missing file for redirection");
 4c1:	83 ec 0c             	sub    $0xc,%esp
 4c4:	68 a8 0f 00 00       	push   $0xfa8
 4c9:	e8 7d fb ff ff       	call   4b <panic>
    switch(tok){
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
 4ce:	83 ec 0c             	sub    $0xc,%esp
 4d1:	6a 00                	push   $0x0
 4d3:	6a 00                	push   $0x0
 4d5:	ff 75 e0             	push   -0x20(%ebp)
 4d8:	ff 75 e4             	push   -0x1c(%ebp)
 4db:	ff 75 08             	push   0x8(%ebp)
 4de:	e8 76 fd ff ff       	call   259 <redircmd>
 4e3:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
 4e6:	83 c4 20             	add    $0x20,%esp
  while(peek(ps, es, "<>")){
 4e9:	83 ec 04             	sub    $0x4,%esp
 4ec:	68 c5 0f 00 00       	push   $0xfc5
 4f1:	56                   	push   %esi
 4f2:	57                   	push   %edi
 4f3:	e8 4c ff ff ff       	call   444 <peek>
 4f8:	83 c4 10             	add    $0x10,%esp
 4fb:	85 c0                	test   %eax,%eax
 4fd:	74 76                	je     575 <parseredirs+0xc5>
    tok = gettoken(ps, es, 0, 0);
 4ff:	6a 00                	push   $0x0
 501:	6a 00                	push   $0x0
 503:	56                   	push   %esi
 504:	57                   	push   %edi
 505:	e8 33 fe ff ff       	call   33d <gettoken>
 50a:	89 c3                	mov    %eax,%ebx
    if(gettoken(ps, es, &q, &eq) != 'a')
 50c:	8d 45 e0             	lea    -0x20(%ebp),%eax
 50f:	50                   	push   %eax
 510:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 513:	50                   	push   %eax
 514:	56                   	push   %esi
 515:	57                   	push   %edi
 516:	e8 22 fe ff ff       	call   33d <gettoken>
 51b:	83 c4 20             	add    $0x20,%esp
 51e:	83 f8 61             	cmp    $0x61,%eax
 521:	75 9e                	jne    4c1 <parseredirs+0x11>
    switch(tok){
 523:	83 fb 3c             	cmp    $0x3c,%ebx
 526:	74 a6                	je     4ce <parseredirs+0x1e>
 528:	83 fb 3e             	cmp    $0x3e,%ebx
 52b:	74 25                	je     552 <parseredirs+0xa2>
 52d:	83 fb 2b             	cmp    $0x2b,%ebx
 530:	75 b7                	jne    4e9 <parseredirs+0x39>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
 532:	83 ec 0c             	sub    $0xc,%esp
 535:	6a 01                	push   $0x1
 537:	68 01 02 00 00       	push   $0x201
 53c:	ff 75 e0             	push   -0x20(%ebp)
 53f:	ff 75 e4             	push   -0x1c(%ebp)
 542:	ff 75 08             	push   0x8(%ebp)
 545:	e8 0f fd ff ff       	call   259 <redircmd>
 54a:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
 54d:	83 c4 20             	add    $0x20,%esp
 550:	eb 97                	jmp    4e9 <parseredirs+0x39>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
 552:	83 ec 0c             	sub    $0xc,%esp
 555:	6a 01                	push   $0x1
 557:	68 01 02 00 00       	push   $0x201
 55c:	ff 75 e0             	push   -0x20(%ebp)
 55f:	ff 75 e4             	push   -0x1c(%ebp)
 562:	ff 75 08             	push   0x8(%ebp)
 565:	e8 ef fc ff ff       	call   259 <redircmd>
 56a:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
 56d:	83 c4 20             	add    $0x20,%esp
 570:	e9 74 ff ff ff       	jmp    4e9 <parseredirs+0x39>
    }
  }
  return cmd;
}
 575:	8b 45 08             	mov    0x8(%ebp),%eax
 578:	8d 65 f4             	lea    -0xc(%ebp),%esp
 57b:	5b                   	pop    %ebx
 57c:	5e                   	pop    %esi
 57d:	5f                   	pop    %edi
 57e:	5d                   	pop    %ebp
 57f:	c3                   	ret    

00000580 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
 580:	55                   	push   %ebp
 581:	89 e5                	mov    %esp,%ebp
 583:	57                   	push   %edi
 584:	56                   	push   %esi
 585:	53                   	push   %ebx
 586:	83 ec 30             	sub    $0x30,%esp
 589:	8b 75 08             	mov    0x8(%ebp),%esi
 58c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
 58f:	68 c8 0f 00 00       	push   $0xfc8
 594:	57                   	push   %edi
 595:	56                   	push   %esi
 596:	e8 a9 fe ff ff       	call   444 <peek>
 59b:	83 c4 10             	add    $0x10,%esp
 59e:	85 c0                	test   %eax,%eax
 5a0:	75 1d                	jne    5bf <parseexec+0x3f>
 5a2:	89 c3                	mov    %eax,%ebx
    return parseblock(ps, es);

  ret = execcmd();
 5a4:	e8 80 fc ff ff       	call   229 <execcmd>
 5a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
 5ac:	83 ec 04             	sub    $0x4,%esp
 5af:	57                   	push   %edi
 5b0:	56                   	push   %esi
 5b1:	50                   	push   %eax
 5b2:	e8 f9 fe ff ff       	call   4b0 <parseredirs>
 5b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  while(!peek(ps, es, "|)&;")){
 5ba:	83 c4 10             	add    $0x10,%esp
 5bd:	eb 35                	jmp    5f4 <parseexec+0x74>
    return parseblock(ps, es);
 5bf:	83 ec 08             	sub    $0x8,%esp
 5c2:	57                   	push   %edi
 5c3:	56                   	push   %esi
 5c4:	e8 8f 01 00 00       	call   758 <parseblock>
 5c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 5cc:	83 c4 10             	add    $0x10,%esp
 5cf:	e9 8a 00 00 00       	jmp    65e <parseexec+0xde>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
      panic("syntax");
 5d4:	83 ec 0c             	sub    $0xc,%esp
 5d7:	68 ca 0f 00 00       	push   $0xfca
 5dc:	e8 6a fa ff ff       	call   4b <panic>
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
 5e1:	83 ec 04             	sub    $0x4,%esp
 5e4:	57                   	push   %edi
 5e5:	56                   	push   %esi
 5e6:	ff 75 d4             	push   -0x2c(%ebp)
 5e9:	e8 c2 fe ff ff       	call   4b0 <parseredirs>
 5ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 5f1:	83 c4 10             	add    $0x10,%esp
  while(!peek(ps, es, "|)&;")){
 5f4:	83 ec 04             	sub    $0x4,%esp
 5f7:	68 df 0f 00 00       	push   $0xfdf
 5fc:	57                   	push   %edi
 5fd:	56                   	push   %esi
 5fe:	e8 41 fe ff ff       	call   444 <peek>
 603:	83 c4 10             	add    $0x10,%esp
 606:	85 c0                	test   %eax,%eax
 608:	75 41                	jne    64b <parseexec+0xcb>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
 60a:	8d 45 e0             	lea    -0x20(%ebp),%eax
 60d:	50                   	push   %eax
 60e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 611:	50                   	push   %eax
 612:	57                   	push   %edi
 613:	56                   	push   %esi
 614:	e8 24 fd ff ff       	call   33d <gettoken>
 619:	83 c4 10             	add    $0x10,%esp
 61c:	85 c0                	test   %eax,%eax
 61e:	74 2b                	je     64b <parseexec+0xcb>
    if(tok != 'a')
 620:	83 f8 61             	cmp    $0x61,%eax
 623:	75 af                	jne    5d4 <parseexec+0x54>
    cmd->argv[argc] = q;
 625:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 628:	8b 55 d0             	mov    -0x30(%ebp),%edx
 62b:	89 44 9a 04          	mov    %eax,0x4(%edx,%ebx,4)
    cmd->eargv[argc] = eq;
 62f:	8b 45 e0             	mov    -0x20(%ebp),%eax
 632:	89 44 9a 54          	mov    %eax,0x54(%edx,%ebx,4)
    argc++;
 636:	83 c3 01             	add    $0x1,%ebx
    if(argc >= MAXARGS)
 639:	83 fb 13             	cmp    $0x13,%ebx
 63c:	7e a3                	jle    5e1 <parseexec+0x61>
      panic("too many args");
 63e:	83 ec 0c             	sub    $0xc,%esp
 641:	68 d1 0f 00 00       	push   $0xfd1
 646:	e8 00 fa ff ff       	call   4b <panic>
  }
  cmd->argv[argc] = 0;
 64b:	8b 45 d0             	mov    -0x30(%ebp),%eax
 64e:	c7 44 98 04 00 00 00 	movl   $0x0,0x4(%eax,%ebx,4)
 655:	00 
  cmd->eargv[argc] = 0;
 656:	c7 44 98 54 00 00 00 	movl   $0x0,0x54(%eax,%ebx,4)
 65d:	00 
  return ret;
}
 65e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 661:	8d 65 f4             	lea    -0xc(%ebp),%esp
 664:	5b                   	pop    %ebx
 665:	5e                   	pop    %esi
 666:	5f                   	pop    %edi
 667:	5d                   	pop    %ebp
 668:	c3                   	ret    

00000669 <parsepipe>:
{
 669:	55                   	push   %ebp
 66a:	89 e5                	mov    %esp,%ebp
 66c:	57                   	push   %edi
 66d:	56                   	push   %esi
 66e:	53                   	push   %ebx
 66f:	83 ec 14             	sub    $0x14,%esp
 672:	8b 75 08             	mov    0x8(%ebp),%esi
 675:	8b 7d 0c             	mov    0xc(%ebp),%edi
  cmd = parseexec(ps, es);
 678:	57                   	push   %edi
 679:	56                   	push   %esi
 67a:	e8 01 ff ff ff       	call   580 <parseexec>
 67f:	89 c3                	mov    %eax,%ebx
  if(peek(ps, es, "|")){
 681:	83 c4 0c             	add    $0xc,%esp
 684:	68 e4 0f 00 00       	push   $0xfe4
 689:	57                   	push   %edi
 68a:	56                   	push   %esi
 68b:	e8 b4 fd ff ff       	call   444 <peek>
 690:	83 c4 10             	add    $0x10,%esp
 693:	85 c0                	test   %eax,%eax
 695:	75 0a                	jne    6a1 <parsepipe+0x38>
}
 697:	89 d8                	mov    %ebx,%eax
 699:	8d 65 f4             	lea    -0xc(%ebp),%esp
 69c:	5b                   	pop    %ebx
 69d:	5e                   	pop    %esi
 69e:	5f                   	pop    %edi
 69f:	5d                   	pop    %ebp
 6a0:	c3                   	ret    
    gettoken(ps, es, 0, 0);
 6a1:	6a 00                	push   $0x0
 6a3:	6a 00                	push   $0x0
 6a5:	57                   	push   %edi
 6a6:	56                   	push   %esi
 6a7:	e8 91 fc ff ff       	call   33d <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
 6ac:	83 c4 08             	add    $0x8,%esp
 6af:	57                   	push   %edi
 6b0:	56                   	push   %esi
 6b1:	e8 b3 ff ff ff       	call   669 <parsepipe>
 6b6:	83 c4 08             	add    $0x8,%esp
 6b9:	50                   	push   %eax
 6ba:	53                   	push   %ebx
 6bb:	e8 e1 fb ff ff       	call   2a1 <pipecmd>
 6c0:	89 c3                	mov    %eax,%ebx
 6c2:	83 c4 10             	add    $0x10,%esp
  return cmd;
 6c5:	eb d0                	jmp    697 <parsepipe+0x2e>

000006c7 <parseline>:
{
 6c7:	55                   	push   %ebp
 6c8:	89 e5                	mov    %esp,%ebp
 6ca:	57                   	push   %edi
 6cb:	56                   	push   %esi
 6cc:	53                   	push   %ebx
 6cd:	83 ec 14             	sub    $0x14,%esp
 6d0:	8b 75 08             	mov    0x8(%ebp),%esi
 6d3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  cmd = parsepipe(ps, es);
 6d6:	57                   	push   %edi
 6d7:	56                   	push   %esi
 6d8:	e8 8c ff ff ff       	call   669 <parsepipe>
 6dd:	89 c3                	mov    %eax,%ebx
  while(peek(ps, es, "&")){
 6df:	83 c4 10             	add    $0x10,%esp
 6e2:	eb 18                	jmp    6fc <parseline+0x35>
    gettoken(ps, es, 0, 0);
 6e4:	6a 00                	push   $0x0
 6e6:	6a 00                	push   $0x0
 6e8:	57                   	push   %edi
 6e9:	56                   	push   %esi
 6ea:	e8 4e fc ff ff       	call   33d <gettoken>
    cmd = backcmd(cmd);
 6ef:	89 1c 24             	mov    %ebx,(%esp)
 6f2:	e8 16 fc ff ff       	call   30d <backcmd>
 6f7:	89 c3                	mov    %eax,%ebx
 6f9:	83 c4 10             	add    $0x10,%esp
  while(peek(ps, es, "&")){
 6fc:	83 ec 04             	sub    $0x4,%esp
 6ff:	68 e6 0f 00 00       	push   $0xfe6
 704:	57                   	push   %edi
 705:	56                   	push   %esi
 706:	e8 39 fd ff ff       	call   444 <peek>
 70b:	83 c4 10             	add    $0x10,%esp
 70e:	85 c0                	test   %eax,%eax
 710:	75 d2                	jne    6e4 <parseline+0x1d>
  if(peek(ps, es, ";")){
 712:	83 ec 04             	sub    $0x4,%esp
 715:	68 e2 0f 00 00       	push   $0xfe2
 71a:	57                   	push   %edi
 71b:	56                   	push   %esi
 71c:	e8 23 fd ff ff       	call   444 <peek>
 721:	83 c4 10             	add    $0x10,%esp
 724:	85 c0                	test   %eax,%eax
 726:	75 0a                	jne    732 <parseline+0x6b>
}
 728:	89 d8                	mov    %ebx,%eax
 72a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 72d:	5b                   	pop    %ebx
 72e:	5e                   	pop    %esi
 72f:	5f                   	pop    %edi
 730:	5d                   	pop    %ebp
 731:	c3                   	ret    
    gettoken(ps, es, 0, 0);
 732:	6a 00                	push   $0x0
 734:	6a 00                	push   $0x0
 736:	57                   	push   %edi
 737:	56                   	push   %esi
 738:	e8 00 fc ff ff       	call   33d <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
 73d:	83 c4 08             	add    $0x8,%esp
 740:	57                   	push   %edi
 741:	56                   	push   %esi
 742:	e8 80 ff ff ff       	call   6c7 <parseline>
 747:	83 c4 08             	add    $0x8,%esp
 74a:	50                   	push   %eax
 74b:	53                   	push   %ebx
 74c:	e8 86 fb ff ff       	call   2d7 <listcmd>
 751:	89 c3                	mov    %eax,%ebx
 753:	83 c4 10             	add    $0x10,%esp
  return cmd;
 756:	eb d0                	jmp    728 <parseline+0x61>

00000758 <parseblock>:
{
 758:	55                   	push   %ebp
 759:	89 e5                	mov    %esp,%ebp
 75b:	57                   	push   %edi
 75c:	56                   	push   %esi
 75d:	53                   	push   %ebx
 75e:	83 ec 10             	sub    $0x10,%esp
 761:	8b 5d 08             	mov    0x8(%ebp),%ebx
 764:	8b 75 0c             	mov    0xc(%ebp),%esi
  if(!peek(ps, es, "("))
 767:	68 c8 0f 00 00       	push   $0xfc8
 76c:	56                   	push   %esi
 76d:	53                   	push   %ebx
 76e:	e8 d1 fc ff ff       	call   444 <peek>
 773:	83 c4 10             	add    $0x10,%esp
 776:	85 c0                	test   %eax,%eax
 778:	74 4b                	je     7c5 <parseblock+0x6d>
  gettoken(ps, es, 0, 0);
 77a:	6a 00                	push   $0x0
 77c:	6a 00                	push   $0x0
 77e:	56                   	push   %esi
 77f:	53                   	push   %ebx
 780:	e8 b8 fb ff ff       	call   33d <gettoken>
  cmd = parseline(ps, es);
 785:	83 c4 08             	add    $0x8,%esp
 788:	56                   	push   %esi
 789:	53                   	push   %ebx
 78a:	e8 38 ff ff ff       	call   6c7 <parseline>
 78f:	89 c7                	mov    %eax,%edi
  if(!peek(ps, es, ")"))
 791:	83 c4 0c             	add    $0xc,%esp
 794:	68 04 10 00 00       	push   $0x1004
 799:	56                   	push   %esi
 79a:	53                   	push   %ebx
 79b:	e8 a4 fc ff ff       	call   444 <peek>
 7a0:	83 c4 10             	add    $0x10,%esp
 7a3:	85 c0                	test   %eax,%eax
 7a5:	74 2b                	je     7d2 <parseblock+0x7a>
  gettoken(ps, es, 0, 0);
 7a7:	6a 00                	push   $0x0
 7a9:	6a 00                	push   $0x0
 7ab:	56                   	push   %esi
 7ac:	53                   	push   %ebx
 7ad:	e8 8b fb ff ff       	call   33d <gettoken>
  cmd = parseredirs(cmd, ps, es);
 7b2:	83 c4 0c             	add    $0xc,%esp
 7b5:	56                   	push   %esi
 7b6:	53                   	push   %ebx
 7b7:	57                   	push   %edi
 7b8:	e8 f3 fc ff ff       	call   4b0 <parseredirs>
}
 7bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
 7c0:	5b                   	pop    %ebx
 7c1:	5e                   	pop    %esi
 7c2:	5f                   	pop    %edi
 7c3:	5d                   	pop    %ebp
 7c4:	c3                   	ret    
    panic("parseblock");
 7c5:	83 ec 0c             	sub    $0xc,%esp
 7c8:	68 e8 0f 00 00       	push   $0xfe8
 7cd:	e8 79 f8 ff ff       	call   4b <panic>
    panic("syntax - missing )");
 7d2:	83 ec 0c             	sub    $0xc,%esp
 7d5:	68 f3 0f 00 00       	push   $0xff3
 7da:	e8 6c f8 ff ff       	call   4b <panic>

000007df <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
 7df:	55                   	push   %ebp
 7e0:	89 e5                	mov    %esp,%ebp
 7e2:	53                   	push   %ebx
 7e3:	83 ec 04             	sub    $0x4,%esp
 7e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
 7e9:	85 db                	test   %ebx,%ebx
 7eb:	74 1f                	je     80c <nulterminate+0x2d>
    return 0;

  switch(cmd->type){
 7ed:	8b 03                	mov    (%ebx),%eax
 7ef:	83 f8 05             	cmp    $0x5,%eax
 7f2:	77 18                	ja     80c <nulterminate+0x2d>
 7f4:	ff 24 85 44 10 00 00 	jmp    *0x1044(,%eax,4)
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
      *ecmd->eargv[i] = 0;
 7fb:	8b 54 83 54          	mov    0x54(%ebx,%eax,4),%edx
 7ff:	c6 02 00             	movb   $0x0,(%edx)
    for(i=0; ecmd->argv[i]; i++)
 802:	83 c0 01             	add    $0x1,%eax
 805:	83 7c 83 04 00       	cmpl   $0x0,0x4(%ebx,%eax,4)
 80a:	75 ef                	jne    7fb <nulterminate+0x1c>
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
 80c:	89 d8                	mov    %ebx,%eax
 80e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 811:	c9                   	leave  
 812:	c3                   	ret    
  switch(cmd->type){
 813:	b8 00 00 00 00       	mov    $0x0,%eax
 818:	eb eb                	jmp    805 <nulterminate+0x26>
    nulterminate(rcmd->cmd);
 81a:	83 ec 0c             	sub    $0xc,%esp
 81d:	ff 73 04             	push   0x4(%ebx)
 820:	e8 ba ff ff ff       	call   7df <nulterminate>
    *rcmd->efile = 0;
 825:	8b 43 0c             	mov    0xc(%ebx),%eax
 828:	c6 00 00             	movb   $0x0,(%eax)
    break;
 82b:	83 c4 10             	add    $0x10,%esp
 82e:	eb dc                	jmp    80c <nulterminate+0x2d>
    nulterminate(pcmd->left);
 830:	83 ec 0c             	sub    $0xc,%esp
 833:	ff 73 04             	push   0x4(%ebx)
 836:	e8 a4 ff ff ff       	call   7df <nulterminate>
    nulterminate(pcmd->right);
 83b:	83 c4 04             	add    $0x4,%esp
 83e:	ff 73 08             	push   0x8(%ebx)
 841:	e8 99 ff ff ff       	call   7df <nulterminate>
    break;
 846:	83 c4 10             	add    $0x10,%esp
 849:	eb c1                	jmp    80c <nulterminate+0x2d>
    nulterminate(lcmd->left);
 84b:	83 ec 0c             	sub    $0xc,%esp
 84e:	ff 73 04             	push   0x4(%ebx)
 851:	e8 89 ff ff ff       	call   7df <nulterminate>
    nulterminate(lcmd->right);
 856:	83 c4 04             	add    $0x4,%esp
 859:	ff 73 08             	push   0x8(%ebx)
 85c:	e8 7e ff ff ff       	call   7df <nulterminate>
    break;
 861:	83 c4 10             	add    $0x10,%esp
 864:	eb a6                	jmp    80c <nulterminate+0x2d>
    nulterminate(bcmd->cmd);
 866:	83 ec 0c             	sub    $0xc,%esp
 869:	ff 73 04             	push   0x4(%ebx)
 86c:	e8 6e ff ff ff       	call   7df <nulterminate>
    break;
 871:	83 c4 10             	add    $0x10,%esp
 874:	eb 96                	jmp    80c <nulterminate+0x2d>

00000876 <parsecmd>:
{
 876:	55                   	push   %ebp
 877:	89 e5                	mov    %esp,%ebp
 879:	56                   	push   %esi
 87a:	53                   	push   %ebx
  es = s + strlen(s);
 87b:	8b 5d 08             	mov    0x8(%ebp),%ebx
 87e:	83 ec 0c             	sub    $0xc,%esp
 881:	53                   	push   %ebx
 882:	e8 7d 01 00 00       	call   a04 <strlen>
 887:	01 c3                	add    %eax,%ebx
  cmd = parseline(&s, es);
 889:	83 c4 08             	add    $0x8,%esp
 88c:	53                   	push   %ebx
 88d:	8d 45 08             	lea    0x8(%ebp),%eax
 890:	50                   	push   %eax
 891:	e8 31 fe ff ff       	call   6c7 <parseline>
 896:	89 c6                	mov    %eax,%esi
  peek(&s, es, "");
 898:	83 c4 0c             	add    $0xc,%esp
 89b:	68 92 0f 00 00       	push   $0xf92
 8a0:	53                   	push   %ebx
 8a1:	8d 45 08             	lea    0x8(%ebp),%eax
 8a4:	50                   	push   %eax
 8a5:	e8 9a fb ff ff       	call   444 <peek>
  if(s != es){
 8aa:	8b 45 08             	mov    0x8(%ebp),%eax
 8ad:	83 c4 10             	add    $0x10,%esp
 8b0:	39 d8                	cmp    %ebx,%eax
 8b2:	75 12                	jne    8c6 <parsecmd+0x50>
  nulterminate(cmd);
 8b4:	83 ec 0c             	sub    $0xc,%esp
 8b7:	56                   	push   %esi
 8b8:	e8 22 ff ff ff       	call   7df <nulterminate>
}
 8bd:	89 f0                	mov    %esi,%eax
 8bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
 8c2:	5b                   	pop    %ebx
 8c3:	5e                   	pop    %esi
 8c4:	5d                   	pop    %ebp
 8c5:	c3                   	ret    
    printf(2, "leftovers: %s\n", s);
 8c6:	83 ec 04             	sub    $0x4,%esp
 8c9:	50                   	push   %eax
 8ca:	68 06 10 00 00       	push   $0x1006
 8cf:	6a 02                	push   $0x2
 8d1:	e8 ee 03 00 00       	call   cc4 <printf>
    panic("syntax");
 8d6:	c7 04 24 ca 0f 00 00 	movl   $0xfca,(%esp)
 8dd:	e8 69 f7 ff ff       	call   4b <panic>

000008e2 <main>:
{
 8e2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 8e6:	83 e4 f0             	and    $0xfffffff0,%esp
 8e9:	ff 71 fc             	push   -0x4(%ecx)
 8ec:	55                   	push   %ebp
 8ed:	89 e5                	mov    %esp,%ebp
 8ef:	51                   	push   %ecx
 8f0:	83 ec 04             	sub    $0x4,%esp
  while((fd = open("console", O_RDWR)) >= 0){
 8f3:	83 ec 08             	sub    $0x8,%esp
 8f6:	6a 02                	push   $0x2
 8f8:	68 15 10 00 00       	push   $0x1015
 8fd:	e8 95 02 00 00       	call   b97 <open>
 902:	83 c4 10             	add    $0x10,%esp
 905:	85 c0                	test   %eax,%eax
 907:	78 21                	js     92a <main+0x48>
    if(fd >= 3){
 909:	83 f8 02             	cmp    $0x2,%eax
 90c:	7e e5                	jle    8f3 <main+0x11>
      close(fd);
 90e:	83 ec 0c             	sub    $0xc,%esp
 911:	50                   	push   %eax
 912:	e8 68 02 00 00       	call   b7f <close>
      break;
 917:	83 c4 10             	add    $0x10,%esp
 91a:	eb 0e                	jmp    92a <main+0x48>
    if(fork1() == 0)
 91c:	e8 44 f7 ff ff       	call   65 <fork1>
 921:	85 c0                	test   %eax,%eax
 923:	74 79                	je     99e <main+0xbc>
    wait();
 925:	e8 35 02 00 00       	call   b5f <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
 92a:	83 ec 08             	sub    $0x8,%esp
 92d:	68 c8 00 00 00       	push   $0xc8
 932:	68 00 11 00 00       	push   $0x1100
 937:	e8 c4 f6 ff ff       	call   0 <getcmd>
 93c:	83 c4 10             	add    $0x10,%esp
 93f:	85 c0                	test   %eax,%eax
 941:	78 70                	js     9b3 <main+0xd1>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
 943:	80 3d 00 11 00 00 63 	cmpb   $0x63,0x1100
 94a:	75 d0                	jne    91c <main+0x3a>
 94c:	80 3d 01 11 00 00 64 	cmpb   $0x64,0x1101
 953:	75 c7                	jne    91c <main+0x3a>
 955:	80 3d 02 11 00 00 20 	cmpb   $0x20,0x1102
 95c:	75 be                	jne    91c <main+0x3a>
      buf[strlen(buf)-1] = 0;  // chop \n
 95e:	83 ec 0c             	sub    $0xc,%esp
 961:	68 00 11 00 00       	push   $0x1100
 966:	e8 99 00 00 00       	call   a04 <strlen>
 96b:	c6 80 ff 10 00 00 00 	movb   $0x0,0x10ff(%eax)
      if(chdir(buf+3) < 0)
 972:	c7 04 24 03 11 00 00 	movl   $0x1103,(%esp)
 979:	e8 49 02 00 00       	call   bc7 <chdir>
 97e:	83 c4 10             	add    $0x10,%esp
 981:	85 c0                	test   %eax,%eax
 983:	79 a5                	jns    92a <main+0x48>
        printf(2, "cannot cd %s\n", buf+3);
 985:	83 ec 04             	sub    $0x4,%esp
 988:	68 03 11 00 00       	push   $0x1103
 98d:	68 1d 10 00 00       	push   $0x101d
 992:	6a 02                	push   $0x2
 994:	e8 2b 03 00 00       	call   cc4 <printf>
 999:	83 c4 10             	add    $0x10,%esp
      continue;
 99c:	eb 8c                	jmp    92a <main+0x48>
      runcmd(parsecmd(buf));
 99e:	83 ec 0c             	sub    $0xc,%esp
 9a1:	68 00 11 00 00       	push   $0x1100
 9a6:	e8 cb fe ff ff       	call   876 <parsecmd>
 9ab:	89 04 24             	mov    %eax,(%esp)
 9ae:	e8 d1 f6 ff ff       	call   84 <runcmd>
  exit();
 9b3:	e8 9f 01 00 00       	call   b57 <exit>

000009b8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 9b8:	55                   	push   %ebp
 9b9:	89 e5                	mov    %esp,%ebp
 9bb:	56                   	push   %esi
 9bc:	53                   	push   %ebx
 9bd:	8b 75 08             	mov    0x8(%ebp),%esi
 9c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 9c3:	89 f0                	mov    %esi,%eax
 9c5:	89 d1                	mov    %edx,%ecx
 9c7:	83 c2 01             	add    $0x1,%edx
 9ca:	89 c3                	mov    %eax,%ebx
 9cc:	83 c0 01             	add    $0x1,%eax
 9cf:	0f b6 09             	movzbl (%ecx),%ecx
 9d2:	88 0b                	mov    %cl,(%ebx)
 9d4:	84 c9                	test   %cl,%cl
 9d6:	75 ed                	jne    9c5 <strcpy+0xd>
    ;
  return os;
}
 9d8:	89 f0                	mov    %esi,%eax
 9da:	5b                   	pop    %ebx
 9db:	5e                   	pop    %esi
 9dc:	5d                   	pop    %ebp
 9dd:	c3                   	ret    

000009de <strcmp>:

int
strcmp(const char *p, const char *q)
{
 9de:	55                   	push   %ebp
 9df:	89 e5                	mov    %esp,%ebp
 9e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 9e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 9e7:	eb 06                	jmp    9ef <strcmp+0x11>
    p++, q++;
 9e9:	83 c1 01             	add    $0x1,%ecx
 9ec:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 9ef:	0f b6 01             	movzbl (%ecx),%eax
 9f2:	84 c0                	test   %al,%al
 9f4:	74 04                	je     9fa <strcmp+0x1c>
 9f6:	3a 02                	cmp    (%edx),%al
 9f8:	74 ef                	je     9e9 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 9fa:	0f b6 c0             	movzbl %al,%eax
 9fd:	0f b6 12             	movzbl (%edx),%edx
 a00:	29 d0                	sub    %edx,%eax
}
 a02:	5d                   	pop    %ebp
 a03:	c3                   	ret    

00000a04 <strlen>:

uint
strlen(const char *s)
{
 a04:	55                   	push   %ebp
 a05:	89 e5                	mov    %esp,%ebp
 a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 a0a:	b8 00 00 00 00       	mov    $0x0,%eax
 a0f:	eb 03                	jmp    a14 <strlen+0x10>
 a11:	83 c0 01             	add    $0x1,%eax
 a14:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
 a18:	75 f7                	jne    a11 <strlen+0xd>
    ;
  return n;
}
 a1a:	5d                   	pop    %ebp
 a1b:	c3                   	ret    

00000a1c <memset>:

void*
memset(void *dst, int c, uint n)
{
 a1c:	55                   	push   %ebp
 a1d:	89 e5                	mov    %esp,%ebp
 a1f:	57                   	push   %edi
 a20:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 a23:	89 d7                	mov    %edx,%edi
 a25:	8b 4d 10             	mov    0x10(%ebp),%ecx
 a28:	8b 45 0c             	mov    0xc(%ebp),%eax
 a2b:	fc                   	cld    
 a2c:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 a2e:	89 d0                	mov    %edx,%eax
 a30:	8b 7d fc             	mov    -0x4(%ebp),%edi
 a33:	c9                   	leave  
 a34:	c3                   	ret    

00000a35 <strchr>:

char*
strchr(const char *s, char c)
{
 a35:	55                   	push   %ebp
 a36:	89 e5                	mov    %esp,%ebp
 a38:	8b 45 08             	mov    0x8(%ebp),%eax
 a3b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 a3f:	eb 03                	jmp    a44 <strchr+0xf>
 a41:	83 c0 01             	add    $0x1,%eax
 a44:	0f b6 10             	movzbl (%eax),%edx
 a47:	84 d2                	test   %dl,%dl
 a49:	74 06                	je     a51 <strchr+0x1c>
    if(*s == c)
 a4b:	38 ca                	cmp    %cl,%dl
 a4d:	75 f2                	jne    a41 <strchr+0xc>
 a4f:	eb 05                	jmp    a56 <strchr+0x21>
      return (char*)s;
  return 0;
 a51:	b8 00 00 00 00       	mov    $0x0,%eax
}
 a56:	5d                   	pop    %ebp
 a57:	c3                   	ret    

00000a58 <gets>:

char*
gets(char *buf, int max)
{
 a58:	55                   	push   %ebp
 a59:	89 e5                	mov    %esp,%ebp
 a5b:	57                   	push   %edi
 a5c:	56                   	push   %esi
 a5d:	53                   	push   %ebx
 a5e:	83 ec 1c             	sub    $0x1c,%esp
 a61:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 a64:	bb 00 00 00 00       	mov    $0x0,%ebx
 a69:	89 de                	mov    %ebx,%esi
 a6b:	83 c3 01             	add    $0x1,%ebx
 a6e:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 a71:	7d 2e                	jge    aa1 <gets+0x49>
    cc = read(0, &c, 1);
 a73:	83 ec 04             	sub    $0x4,%esp
 a76:	6a 01                	push   $0x1
 a78:	8d 45 e7             	lea    -0x19(%ebp),%eax
 a7b:	50                   	push   %eax
 a7c:	6a 00                	push   $0x0
 a7e:	e8 ec 00 00 00       	call   b6f <read>
    if(cc < 1)
 a83:	83 c4 10             	add    $0x10,%esp
 a86:	85 c0                	test   %eax,%eax
 a88:	7e 17                	jle    aa1 <gets+0x49>
      break;
    buf[i++] = c;
 a8a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 a8e:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
 a91:	3c 0a                	cmp    $0xa,%al
 a93:	0f 94 c2             	sete   %dl
 a96:	3c 0d                	cmp    $0xd,%al
 a98:	0f 94 c0             	sete   %al
 a9b:	08 c2                	or     %al,%dl
 a9d:	74 ca                	je     a69 <gets+0x11>
    buf[i++] = c;
 a9f:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 aa1:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 aa5:	89 f8                	mov    %edi,%eax
 aa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
 aaa:	5b                   	pop    %ebx
 aab:	5e                   	pop    %esi
 aac:	5f                   	pop    %edi
 aad:	5d                   	pop    %ebp
 aae:	c3                   	ret    

00000aaf <stat>:

int
stat(const char *n, struct stat *st)
{
 aaf:	55                   	push   %ebp
 ab0:	89 e5                	mov    %esp,%ebp
 ab2:	56                   	push   %esi
 ab3:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 ab4:	83 ec 08             	sub    $0x8,%esp
 ab7:	6a 00                	push   $0x0
 ab9:	ff 75 08             	push   0x8(%ebp)
 abc:	e8 d6 00 00 00       	call   b97 <open>
  if(fd < 0)
 ac1:	83 c4 10             	add    $0x10,%esp
 ac4:	85 c0                	test   %eax,%eax
 ac6:	78 24                	js     aec <stat+0x3d>
 ac8:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 aca:	83 ec 08             	sub    $0x8,%esp
 acd:	ff 75 0c             	push   0xc(%ebp)
 ad0:	50                   	push   %eax
 ad1:	e8 d9 00 00 00       	call   baf <fstat>
 ad6:	89 c6                	mov    %eax,%esi
  close(fd);
 ad8:	89 1c 24             	mov    %ebx,(%esp)
 adb:	e8 9f 00 00 00       	call   b7f <close>
  return r;
 ae0:	83 c4 10             	add    $0x10,%esp
}
 ae3:	89 f0                	mov    %esi,%eax
 ae5:	8d 65 f8             	lea    -0x8(%ebp),%esp
 ae8:	5b                   	pop    %ebx
 ae9:	5e                   	pop    %esi
 aea:	5d                   	pop    %ebp
 aeb:	c3                   	ret    
    return -1;
 aec:	be ff ff ff ff       	mov    $0xffffffff,%esi
 af1:	eb f0                	jmp    ae3 <stat+0x34>

00000af3 <atoi>:

int
atoi(const char *s)
{
 af3:	55                   	push   %ebp
 af4:	89 e5                	mov    %esp,%ebp
 af6:	53                   	push   %ebx
 af7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 afa:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 aff:	eb 10                	jmp    b11 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 b01:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
 b04:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
 b07:	83 c1 01             	add    $0x1,%ecx
 b0a:	0f be c0             	movsbl %al,%eax
 b0d:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
  while('0' <= *s && *s <= '9')
 b11:	0f b6 01             	movzbl (%ecx),%eax
 b14:	8d 58 d0             	lea    -0x30(%eax),%ebx
 b17:	80 fb 09             	cmp    $0x9,%bl
 b1a:	76 e5                	jbe    b01 <atoi+0xe>
  return n;
}
 b1c:	89 d0                	mov    %edx,%eax
 b1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 b21:	c9                   	leave  
 b22:	c3                   	ret    

00000b23 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 b23:	55                   	push   %ebp
 b24:	89 e5                	mov    %esp,%ebp
 b26:	56                   	push   %esi
 b27:	53                   	push   %ebx
 b28:	8b 75 08             	mov    0x8(%ebp),%esi
 b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 b2e:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
 b31:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
 b33:	eb 0d                	jmp    b42 <memmove+0x1f>
    *dst++ = *src++;
 b35:	0f b6 01             	movzbl (%ecx),%eax
 b38:	88 02                	mov    %al,(%edx)
 b3a:	8d 49 01             	lea    0x1(%ecx),%ecx
 b3d:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
 b40:	89 d8                	mov    %ebx,%eax
 b42:	8d 58 ff             	lea    -0x1(%eax),%ebx
 b45:	85 c0                	test   %eax,%eax
 b47:	7f ec                	jg     b35 <memmove+0x12>
  return vdst;
}
 b49:	89 f0                	mov    %esi,%eax
 b4b:	5b                   	pop    %ebx
 b4c:	5e                   	pop    %esi
 b4d:	5d                   	pop    %ebp
 b4e:	c3                   	ret    

00000b4f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 b4f:	b8 01 00 00 00       	mov    $0x1,%eax
 b54:	cd 40                	int    $0x40
 b56:	c3                   	ret    

00000b57 <exit>:
SYSCALL(exit)
 b57:	b8 02 00 00 00       	mov    $0x2,%eax
 b5c:	cd 40                	int    $0x40
 b5e:	c3                   	ret    

00000b5f <wait>:
SYSCALL(wait)
 b5f:	b8 03 00 00 00       	mov    $0x3,%eax
 b64:	cd 40                	int    $0x40
 b66:	c3                   	ret    

00000b67 <pipe>:
SYSCALL(pipe)
 b67:	b8 04 00 00 00       	mov    $0x4,%eax
 b6c:	cd 40                	int    $0x40
 b6e:	c3                   	ret    

00000b6f <read>:
SYSCALL(read)
 b6f:	b8 05 00 00 00       	mov    $0x5,%eax
 b74:	cd 40                	int    $0x40
 b76:	c3                   	ret    

00000b77 <write>:
SYSCALL(write)
 b77:	b8 10 00 00 00       	mov    $0x10,%eax
 b7c:	cd 40                	int    $0x40
 b7e:	c3                   	ret    

00000b7f <close>:
SYSCALL(close)
 b7f:	b8 15 00 00 00       	mov    $0x15,%eax
 b84:	cd 40                	int    $0x40
 b86:	c3                   	ret    

00000b87 <kill>:
SYSCALL(kill)
 b87:	b8 06 00 00 00       	mov    $0x6,%eax
 b8c:	cd 40                	int    $0x40
 b8e:	c3                   	ret    

00000b8f <exec>:
SYSCALL(exec)
 b8f:	b8 07 00 00 00       	mov    $0x7,%eax
 b94:	cd 40                	int    $0x40
 b96:	c3                   	ret    

00000b97 <open>:
SYSCALL(open)
 b97:	b8 0f 00 00 00       	mov    $0xf,%eax
 b9c:	cd 40                	int    $0x40
 b9e:	c3                   	ret    

00000b9f <mknod>:
SYSCALL(mknod)
 b9f:	b8 11 00 00 00       	mov    $0x11,%eax
 ba4:	cd 40                	int    $0x40
 ba6:	c3                   	ret    

00000ba7 <unlink>:
SYSCALL(unlink)
 ba7:	b8 12 00 00 00       	mov    $0x12,%eax
 bac:	cd 40                	int    $0x40
 bae:	c3                   	ret    

00000baf <fstat>:
SYSCALL(fstat)
 baf:	b8 08 00 00 00       	mov    $0x8,%eax
 bb4:	cd 40                	int    $0x40
 bb6:	c3                   	ret    

00000bb7 <link>:
SYSCALL(link)
 bb7:	b8 13 00 00 00       	mov    $0x13,%eax
 bbc:	cd 40                	int    $0x40
 bbe:	c3                   	ret    

00000bbf <mkdir>:
SYSCALL(mkdir)
 bbf:	b8 14 00 00 00       	mov    $0x14,%eax
 bc4:	cd 40                	int    $0x40
 bc6:	c3                   	ret    

00000bc7 <chdir>:
SYSCALL(chdir)
 bc7:	b8 09 00 00 00       	mov    $0x9,%eax
 bcc:	cd 40                	int    $0x40
 bce:	c3                   	ret    

00000bcf <dup>:
SYSCALL(dup)
 bcf:	b8 0a 00 00 00       	mov    $0xa,%eax
 bd4:	cd 40                	int    $0x40
 bd6:	c3                   	ret    

00000bd7 <getpid>:
SYSCALL(getpid)
 bd7:	b8 0b 00 00 00       	mov    $0xb,%eax
 bdc:	cd 40                	int    $0x40
 bde:	c3                   	ret    

00000bdf <sbrk>:
SYSCALL(sbrk)
 bdf:	b8 0c 00 00 00       	mov    $0xc,%eax
 be4:	cd 40                	int    $0x40
 be6:	c3                   	ret    

00000be7 <sleep>:
SYSCALL(sleep)
 be7:	b8 0d 00 00 00       	mov    $0xd,%eax
 bec:	cd 40                	int    $0x40
 bee:	c3                   	ret    

00000bef <uptime>:
SYSCALL(uptime)
 bef:	b8 0e 00 00 00       	mov    $0xe,%eax
 bf4:	cd 40                	int    $0x40
 bf6:	c3                   	ret    

00000bf7 <yield>:
SYSCALL(yield)
 bf7:	b8 16 00 00 00       	mov    $0x16,%eax
 bfc:	cd 40                	int    $0x40
 bfe:	c3                   	ret    

00000bff <shutdown>:
SYSCALL(shutdown)
 bff:	b8 17 00 00 00       	mov    $0x17,%eax
 c04:	cd 40                	int    $0x40
 c06:	c3                   	ret    

00000c07 <getpagetableentry>:
SYSCALL(getpagetableentry)
 c07:	b8 18 00 00 00       	mov    $0x18,%eax
 c0c:	cd 40                	int    $0x40
 c0e:	c3                   	ret    

00000c0f <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 c0f:	b8 19 00 00 00       	mov    $0x19,%eax
 c14:	cd 40                	int    $0x40
 c16:	c3                   	ret    

00000c17 <dumppagetable>:
 c17:	b8 1a 00 00 00       	mov    $0x1a,%eax
 c1c:	cd 40                	int    $0x40
 c1e:	c3                   	ret    

00000c1f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 c1f:	55                   	push   %ebp
 c20:	89 e5                	mov    %esp,%ebp
 c22:	83 ec 1c             	sub    $0x1c,%esp
 c25:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 c28:	6a 01                	push   $0x1
 c2a:	8d 55 f4             	lea    -0xc(%ebp),%edx
 c2d:	52                   	push   %edx
 c2e:	50                   	push   %eax
 c2f:	e8 43 ff ff ff       	call   b77 <write>
}
 c34:	83 c4 10             	add    $0x10,%esp
 c37:	c9                   	leave  
 c38:	c3                   	ret    

00000c39 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 c39:	55                   	push   %ebp
 c3a:	89 e5                	mov    %esp,%ebp
 c3c:	57                   	push   %edi
 c3d:	56                   	push   %esi
 c3e:	53                   	push   %ebx
 c3f:	83 ec 2c             	sub    $0x2c,%esp
 c42:	89 45 d0             	mov    %eax,-0x30(%ebp)
 c45:	89 d0                	mov    %edx,%eax
 c47:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 c49:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 c4d:	0f 95 c1             	setne  %cl
 c50:	c1 ea 1f             	shr    $0x1f,%edx
 c53:	84 d1                	test   %dl,%cl
 c55:	74 44                	je     c9b <printint+0x62>
    neg = 1;
    x = -xx;
 c57:	f7 d8                	neg    %eax
 c59:	89 c1                	mov    %eax,%ecx
    neg = 1;
 c5b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 c62:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 c67:	89 c8                	mov    %ecx,%eax
 c69:	ba 00 00 00 00       	mov    $0x0,%edx
 c6e:	f7 f6                	div    %esi
 c70:	89 df                	mov    %ebx,%edi
 c72:	83 c3 01             	add    $0x1,%ebx
 c75:	0f b6 92 bc 10 00 00 	movzbl 0x10bc(%edx),%edx
 c7c:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 c80:	89 ca                	mov    %ecx,%edx
 c82:	89 c1                	mov    %eax,%ecx
 c84:	39 d6                	cmp    %edx,%esi
 c86:	76 df                	jbe    c67 <printint+0x2e>
  if(neg)
 c88:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 c8c:	74 31                	je     cbf <printint+0x86>
    buf[i++] = '-';
 c8e:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 c93:	8d 5f 02             	lea    0x2(%edi),%ebx
 c96:	8b 75 d0             	mov    -0x30(%ebp),%esi
 c99:	eb 17                	jmp    cb2 <printint+0x79>
    x = xx;
 c9b:	89 c1                	mov    %eax,%ecx
  neg = 0;
 c9d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 ca4:	eb bc                	jmp    c62 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 ca6:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 cab:	89 f0                	mov    %esi,%eax
 cad:	e8 6d ff ff ff       	call   c1f <putc>
  while(--i >= 0)
 cb2:	83 eb 01             	sub    $0x1,%ebx
 cb5:	79 ef                	jns    ca6 <printint+0x6d>
}
 cb7:	83 c4 2c             	add    $0x2c,%esp
 cba:	5b                   	pop    %ebx
 cbb:	5e                   	pop    %esi
 cbc:	5f                   	pop    %edi
 cbd:	5d                   	pop    %ebp
 cbe:	c3                   	ret    
 cbf:	8b 75 d0             	mov    -0x30(%ebp),%esi
 cc2:	eb ee                	jmp    cb2 <printint+0x79>

00000cc4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 cc4:	55                   	push   %ebp
 cc5:	89 e5                	mov    %esp,%ebp
 cc7:	57                   	push   %edi
 cc8:	56                   	push   %esi
 cc9:	53                   	push   %ebx
 cca:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 ccd:	8d 45 10             	lea    0x10(%ebp),%eax
 cd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 cd3:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
 cdd:	eb 14                	jmp    cf3 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 cdf:	89 fa                	mov    %edi,%edx
 ce1:	8b 45 08             	mov    0x8(%ebp),%eax
 ce4:	e8 36 ff ff ff       	call   c1f <putc>
 ce9:	eb 05                	jmp    cf0 <printf+0x2c>
      }
    } else if(state == '%'){
 ceb:	83 fe 25             	cmp    $0x25,%esi
 cee:	74 25                	je     d15 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 cf0:	83 c3 01             	add    $0x1,%ebx
 cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
 cf6:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 cfa:	84 c0                	test   %al,%al
 cfc:	0f 84 20 01 00 00    	je     e22 <printf+0x15e>
    c = fmt[i] & 0xff;
 d02:	0f be f8             	movsbl %al,%edi
 d05:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 d08:	85 f6                	test   %esi,%esi
 d0a:	75 df                	jne    ceb <printf+0x27>
      if(c == '%'){
 d0c:	83 f8 25             	cmp    $0x25,%eax
 d0f:	75 ce                	jne    cdf <printf+0x1b>
        state = '%';
 d11:	89 c6                	mov    %eax,%esi
 d13:	eb db                	jmp    cf0 <printf+0x2c>
      if(c == 'd'){
 d15:	83 f8 25             	cmp    $0x25,%eax
 d18:	0f 84 cf 00 00 00    	je     ded <printf+0x129>
 d1e:	0f 8c dd 00 00 00    	jl     e01 <printf+0x13d>
 d24:	83 f8 78             	cmp    $0x78,%eax
 d27:	0f 8f d4 00 00 00    	jg     e01 <printf+0x13d>
 d2d:	83 f8 63             	cmp    $0x63,%eax
 d30:	0f 8c cb 00 00 00    	jl     e01 <printf+0x13d>
 d36:	83 e8 63             	sub    $0x63,%eax
 d39:	83 f8 15             	cmp    $0x15,%eax
 d3c:	0f 87 bf 00 00 00    	ja     e01 <printf+0x13d>
 d42:	ff 24 85 64 10 00 00 	jmp    *0x1064(,%eax,4)
        printint(fd, *ap, 10, 1);
 d49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 d4c:	8b 17                	mov    (%edi),%edx
 d4e:	83 ec 0c             	sub    $0xc,%esp
 d51:	6a 01                	push   $0x1
 d53:	b9 0a 00 00 00       	mov    $0xa,%ecx
 d58:	8b 45 08             	mov    0x8(%ebp),%eax
 d5b:	e8 d9 fe ff ff       	call   c39 <printint>
        ap++;
 d60:	83 c7 04             	add    $0x4,%edi
 d63:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 d66:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 d69:	be 00 00 00 00       	mov    $0x0,%esi
 d6e:	eb 80                	jmp    cf0 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 d70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 d73:	8b 17                	mov    (%edi),%edx
 d75:	83 ec 0c             	sub    $0xc,%esp
 d78:	6a 00                	push   $0x0
 d7a:	b9 10 00 00 00       	mov    $0x10,%ecx
 d7f:	8b 45 08             	mov    0x8(%ebp),%eax
 d82:	e8 b2 fe ff ff       	call   c39 <printint>
        ap++;
 d87:	83 c7 04             	add    $0x4,%edi
 d8a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 d8d:	83 c4 10             	add    $0x10,%esp
      state = 0;
 d90:	be 00 00 00 00       	mov    $0x0,%esi
 d95:	e9 56 ff ff ff       	jmp    cf0 <printf+0x2c>
        s = (char*)*ap;
 d9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 d9d:	8b 30                	mov    (%eax),%esi
        ap++;
 d9f:	83 c0 04             	add    $0x4,%eax
 da2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 da5:	85 f6                	test   %esi,%esi
 da7:	75 15                	jne    dbe <printf+0xfa>
          s = "(null)";
 da9:	be 5c 10 00 00       	mov    $0x105c,%esi
 dae:	eb 0e                	jmp    dbe <printf+0xfa>
          putc(fd, *s);
 db0:	0f be d2             	movsbl %dl,%edx
 db3:	8b 45 08             	mov    0x8(%ebp),%eax
 db6:	e8 64 fe ff ff       	call   c1f <putc>
          s++;
 dbb:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 dbe:	0f b6 16             	movzbl (%esi),%edx
 dc1:	84 d2                	test   %dl,%dl
 dc3:	75 eb                	jne    db0 <printf+0xec>
      state = 0;
 dc5:	be 00 00 00 00       	mov    $0x0,%esi
 dca:	e9 21 ff ff ff       	jmp    cf0 <printf+0x2c>
        putc(fd, *ap);
 dcf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 dd2:	0f be 17             	movsbl (%edi),%edx
 dd5:	8b 45 08             	mov    0x8(%ebp),%eax
 dd8:	e8 42 fe ff ff       	call   c1f <putc>
        ap++;
 ddd:	83 c7 04             	add    $0x4,%edi
 de0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 de3:	be 00 00 00 00       	mov    $0x0,%esi
 de8:	e9 03 ff ff ff       	jmp    cf0 <printf+0x2c>
        putc(fd, c);
 ded:	89 fa                	mov    %edi,%edx
 def:	8b 45 08             	mov    0x8(%ebp),%eax
 df2:	e8 28 fe ff ff       	call   c1f <putc>
      state = 0;
 df7:	be 00 00 00 00       	mov    $0x0,%esi
 dfc:	e9 ef fe ff ff       	jmp    cf0 <printf+0x2c>
        putc(fd, '%');
 e01:	ba 25 00 00 00       	mov    $0x25,%edx
 e06:	8b 45 08             	mov    0x8(%ebp),%eax
 e09:	e8 11 fe ff ff       	call   c1f <putc>
        putc(fd, c);
 e0e:	89 fa                	mov    %edi,%edx
 e10:	8b 45 08             	mov    0x8(%ebp),%eax
 e13:	e8 07 fe ff ff       	call   c1f <putc>
      state = 0;
 e18:	be 00 00 00 00       	mov    $0x0,%esi
 e1d:	e9 ce fe ff ff       	jmp    cf0 <printf+0x2c>
    }
  }
}
 e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
 e25:	5b                   	pop    %ebx
 e26:	5e                   	pop    %esi
 e27:	5f                   	pop    %edi
 e28:	5d                   	pop    %ebp
 e29:	c3                   	ret    

00000e2a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e2a:	55                   	push   %ebp
 e2b:	89 e5                	mov    %esp,%ebp
 e2d:	57                   	push   %edi
 e2e:	56                   	push   %esi
 e2f:	53                   	push   %ebx
 e30:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e33:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e36:	a1 c8 11 00 00       	mov    0x11c8,%eax
 e3b:	eb 02                	jmp    e3f <free+0x15>
 e3d:	89 d0                	mov    %edx,%eax
 e3f:	39 c8                	cmp    %ecx,%eax
 e41:	73 04                	jae    e47 <free+0x1d>
 e43:	39 08                	cmp    %ecx,(%eax)
 e45:	77 12                	ja     e59 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e47:	8b 10                	mov    (%eax),%edx
 e49:	39 c2                	cmp    %eax,%edx
 e4b:	77 f0                	ja     e3d <free+0x13>
 e4d:	39 c8                	cmp    %ecx,%eax
 e4f:	72 08                	jb     e59 <free+0x2f>
 e51:	39 ca                	cmp    %ecx,%edx
 e53:	77 04                	ja     e59 <free+0x2f>
 e55:	89 d0                	mov    %edx,%eax
 e57:	eb e6                	jmp    e3f <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 e59:	8b 73 fc             	mov    -0x4(%ebx),%esi
 e5c:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 e5f:	8b 10                	mov    (%eax),%edx
 e61:	39 d7                	cmp    %edx,%edi
 e63:	74 19                	je     e7e <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 e65:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 e68:	8b 50 04             	mov    0x4(%eax),%edx
 e6b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 e6e:	39 ce                	cmp    %ecx,%esi
 e70:	74 1b                	je     e8d <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 e72:	89 08                	mov    %ecx,(%eax)
  freep = p;
 e74:	a3 c8 11 00 00       	mov    %eax,0x11c8
}
 e79:	5b                   	pop    %ebx
 e7a:	5e                   	pop    %esi
 e7b:	5f                   	pop    %edi
 e7c:	5d                   	pop    %ebp
 e7d:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 e7e:	03 72 04             	add    0x4(%edx),%esi
 e81:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 e84:	8b 10                	mov    (%eax),%edx
 e86:	8b 12                	mov    (%edx),%edx
 e88:	89 53 f8             	mov    %edx,-0x8(%ebx)
 e8b:	eb db                	jmp    e68 <free+0x3e>
    p->s.size += bp->s.size;
 e8d:	03 53 fc             	add    -0x4(%ebx),%edx
 e90:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 e93:	8b 53 f8             	mov    -0x8(%ebx),%edx
 e96:	89 10                	mov    %edx,(%eax)
 e98:	eb da                	jmp    e74 <free+0x4a>

00000e9a <morecore>:

static Header*
morecore(uint nu)
{
 e9a:	55                   	push   %ebp
 e9b:	89 e5                	mov    %esp,%ebp
 e9d:	53                   	push   %ebx
 e9e:	83 ec 04             	sub    $0x4,%esp
 ea1:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 ea3:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 ea8:	77 05                	ja     eaf <morecore+0x15>
    nu = 4096;
 eaa:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 eaf:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 eb6:	83 ec 0c             	sub    $0xc,%esp
 eb9:	50                   	push   %eax
 eba:	e8 20 fd ff ff       	call   bdf <sbrk>
  if(p == (char*)-1)
 ebf:	83 c4 10             	add    $0x10,%esp
 ec2:	83 f8 ff             	cmp    $0xffffffff,%eax
 ec5:	74 1c                	je     ee3 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 ec7:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 eca:	83 c0 08             	add    $0x8,%eax
 ecd:	83 ec 0c             	sub    $0xc,%esp
 ed0:	50                   	push   %eax
 ed1:	e8 54 ff ff ff       	call   e2a <free>
  return freep;
 ed6:	a1 c8 11 00 00       	mov    0x11c8,%eax
 edb:	83 c4 10             	add    $0x10,%esp
}
 ede:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 ee1:	c9                   	leave  
 ee2:	c3                   	ret    
    return 0;
 ee3:	b8 00 00 00 00       	mov    $0x0,%eax
 ee8:	eb f4                	jmp    ede <morecore+0x44>

00000eea <malloc>:

void*
malloc(uint nbytes)
{
 eea:	55                   	push   %ebp
 eeb:	89 e5                	mov    %esp,%ebp
 eed:	53                   	push   %ebx
 eee:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ef1:	8b 45 08             	mov    0x8(%ebp),%eax
 ef4:	8d 58 07             	lea    0x7(%eax),%ebx
 ef7:	c1 eb 03             	shr    $0x3,%ebx
 efa:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 efd:	8b 0d c8 11 00 00    	mov    0x11c8,%ecx
 f03:	85 c9                	test   %ecx,%ecx
 f05:	74 04                	je     f0b <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f07:	8b 01                	mov    (%ecx),%eax
 f09:	eb 4a                	jmp    f55 <malloc+0x6b>
    base.s.ptr = freep = prevp = &base;
 f0b:	c7 05 c8 11 00 00 cc 	movl   $0x11cc,0x11c8
 f12:	11 00 00 
 f15:	c7 05 cc 11 00 00 cc 	movl   $0x11cc,0x11cc
 f1c:	11 00 00 
    base.s.size = 0;
 f1f:	c7 05 d0 11 00 00 00 	movl   $0x0,0x11d0
 f26:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 f29:	b9 cc 11 00 00       	mov    $0x11cc,%ecx
 f2e:	eb d7                	jmp    f07 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 f30:	74 19                	je     f4b <malloc+0x61>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 f32:	29 da                	sub    %ebx,%edx
 f34:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 f37:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 f3a:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 f3d:	89 0d c8 11 00 00    	mov    %ecx,0x11c8
      return (void*)(p + 1);
 f43:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 f49:	c9                   	leave  
 f4a:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 f4b:	8b 10                	mov    (%eax),%edx
 f4d:	89 11                	mov    %edx,(%ecx)
 f4f:	eb ec                	jmp    f3d <malloc+0x53>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f51:	89 c1                	mov    %eax,%ecx
 f53:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 f55:	8b 50 04             	mov    0x4(%eax),%edx
 f58:	39 da                	cmp    %ebx,%edx
 f5a:	73 d4                	jae    f30 <malloc+0x46>
    if(p == freep)
 f5c:	39 05 c8 11 00 00    	cmp    %eax,0x11c8
 f62:	75 ed                	jne    f51 <malloc+0x67>
      if((p = morecore(nunits)) == 0)
 f64:	89 d8                	mov    %ebx,%eax
 f66:	e8 2f ff ff ff       	call   e9a <morecore>
 f6b:	85 c0                	test   %eax,%eax
 f6d:	75 e2                	jne    f51 <malloc+0x67>
 f6f:	eb d5                	jmp    f46 <malloc+0x5c>
