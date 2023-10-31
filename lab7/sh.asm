
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
       5:	83 ec 10             	sub    $0x10,%esp
       8:	8b 5d 08             	mov    0x8(%ebp),%ebx
       b:	8b 75 0c             	mov    0xc(%ebp),%esi
  printf(2, "$ ");
       e:	c7 44 24 04 fc 10 00 	movl   $0x10fc,0x4(%esp)
      15:	00 
      16:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      1d:	e8 2a 0e 00 00       	call   e4c <printf>
  memset(buf, 0, nbuf);
      22:	89 74 24 08          	mov    %esi,0x8(%esp)
      26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      2d:	00 
      2e:	89 1c 24             	mov    %ebx,(%esp)
      31:	e8 44 0b 00 00       	call   b7a <memset>
  gets(buf, nbuf);
      36:	89 74 24 04          	mov    %esi,0x4(%esp)
      3a:	89 1c 24             	mov    %ebx,(%esp)
      3d:	e8 70 0b 00 00       	call   bb2 <gets>
  if(buf[0] == 0) // EOF
      42:	80 3b 00             	cmpb   $0x0,(%ebx)
      45:	75 07                	jne    4e <getcmd+0x4e>
    return -1;
      47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      4c:	eb 05                	jmp    53 <getcmd+0x53>
  return 0;
      4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
      53:	83 c4 10             	add    $0x10,%esp
      56:	5b                   	pop    %ebx
      57:	5e                   	pop    %esi
      58:	5d                   	pop    %ebp
      59:	c3                   	ret    

0000005a <panic>:
  exit();
}

void
panic(char *s)
{
      5a:	55                   	push   %ebp
      5b:	89 e5                	mov    %esp,%ebp
      5d:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
      60:	8b 45 08             	mov    0x8(%ebp),%eax
      63:	89 44 24 08          	mov    %eax,0x8(%esp)
      67:	c7 44 24 04 99 11 00 	movl   $0x1199,0x4(%esp)
      6e:	00 
      6f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      76:	e8 d1 0d 00 00       	call   e4c <printf>
  exit();
      7b:	e8 3d 0c 00 00       	call   cbd <exit>

00000080 <fork1>:
}

int
fork1(void)
{
      80:	55                   	push   %ebp
      81:	89 e5                	mov    %esp,%ebp
      83:	83 ec 18             	sub    $0x18,%esp
  int pid;

  pid = fork();
      86:	e8 2a 0c 00 00       	call   cb5 <fork>
  if(pid == -1)
      8b:	83 f8 ff             	cmp    $0xffffffff,%eax
      8e:	75 0c                	jne    9c <fork1+0x1c>
    panic("fork");
      90:	c7 04 24 ff 10 00 00 	movl   $0x10ff,(%esp)
      97:	e8 be ff ff ff       	call   5a <panic>
  return pid;
}
      9c:	c9                   	leave  
      9d:	c3                   	ret    

0000009e <runcmd>:
{
      9e:	55                   	push   %ebp
      9f:	89 e5                	mov    %esp,%ebp
      a1:	53                   	push   %ebx
      a2:	83 ec 24             	sub    $0x24,%esp
      a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(cmd == 0)
      a8:	85 db                	test   %ebx,%ebx
      aa:	75 05                	jne    b1 <runcmd+0x13>
    exit();
      ac:	e8 0c 0c 00 00       	call   cbd <exit>
  switch(cmd->type){
      b1:	8b 03                	mov    (%ebx),%eax
      b3:	83 f8 05             	cmp    $0x5,%eax
      b6:	77 07                	ja     bf <runcmd+0x21>
      b8:	ff 24 85 b4 11 00 00 	jmp    *0x11b4(,%eax,4)
    panic("runcmd");
      bf:	c7 04 24 04 11 00 00 	movl   $0x1104,(%esp)
      c6:	e8 8f ff ff ff       	call   5a <panic>
    if(ecmd->argv[0] == 0)
      cb:	8b 43 04             	mov    0x4(%ebx),%eax
      ce:	85 c0                	test   %eax,%eax
      d0:	75 05                	jne    d7 <runcmd+0x39>
      exit();
      d2:	e8 e6 0b 00 00       	call   cbd <exit>
    exec(ecmd->argv[0], ecmd->argv);
      d7:	8d 53 04             	lea    0x4(%ebx),%edx
      da:	89 54 24 04          	mov    %edx,0x4(%esp)
      de:	89 04 24             	mov    %eax,(%esp)
      e1:	e8 0f 0c 00 00       	call   cf5 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      e6:	8b 43 04             	mov    0x4(%ebx),%eax
      e9:	89 44 24 08          	mov    %eax,0x8(%esp)
      ed:	c7 44 24 04 0b 11 00 	movl   $0x110b,0x4(%esp)
      f4:	00 
      f5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      fc:	e8 4b 0d 00 00       	call   e4c <printf>
    break;
     101:	e9 47 01 00 00       	jmp    24d <runcmd+0x1af>
    close(rcmd->fd);
     106:	8b 43 14             	mov    0x14(%ebx),%eax
     109:	89 04 24             	mov    %eax,(%esp)
     10c:	e8 d4 0b 00 00       	call   ce5 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     111:	8b 43 08             	mov    0x8(%ebx),%eax
     114:	8b 53 10             	mov    0x10(%ebx),%edx
     117:	89 54 24 04          	mov    %edx,0x4(%esp)
     11b:	89 04 24             	mov    %eax,(%esp)
     11e:	e8 da 0b 00 00       	call   cfd <open>
     123:	85 c0                	test   %eax,%eax
     125:	79 20                	jns    147 <runcmd+0xa9>
      printf(2, "open %s failed\n", rcmd->file);
     127:	8b 43 08             	mov    0x8(%ebx),%eax
     12a:	89 44 24 08          	mov    %eax,0x8(%esp)
     12e:	c7 44 24 04 1b 11 00 	movl   $0x111b,0x4(%esp)
     135:	00 
     136:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     13d:	e8 0a 0d 00 00       	call   e4c <printf>
      exit();
     142:	e8 76 0b 00 00       	call   cbd <exit>
    runcmd(rcmd->cmd);
     147:	8b 43 04             	mov    0x4(%ebx),%eax
     14a:	89 04 24             	mov    %eax,(%esp)
     14d:	e8 4c ff ff ff       	call   9e <runcmd>
    if(fork1() == 0)
     152:	e8 29 ff ff ff       	call   80 <fork1>
     157:	85 c0                	test   %eax,%eax
     159:	75 0b                	jne    166 <runcmd+0xc8>
      runcmd(lcmd->left);
     15b:	8b 43 04             	mov    0x4(%ebx),%eax
     15e:	89 04 24             	mov    %eax,(%esp)
     161:	e8 38 ff ff ff       	call   9e <runcmd>
    wait();
     166:	e8 5a 0b 00 00       	call   cc5 <wait>
    runcmd(lcmd->right);
     16b:	8b 43 08             	mov    0x8(%ebx),%eax
     16e:	89 04 24             	mov    %eax,(%esp)
     171:	e8 28 ff ff ff       	call   9e <runcmd>
    if(pipe(p) < 0)
     176:	8d 45 f0             	lea    -0x10(%ebp),%eax
     179:	89 04 24             	mov    %eax,(%esp)
     17c:	e8 4c 0b 00 00       	call   ccd <pipe>
     181:	85 c0                	test   %eax,%eax
     183:	79 0c                	jns    191 <runcmd+0xf3>
      panic("pipe");
     185:	c7 04 24 2b 11 00 00 	movl   $0x112b,(%esp)
     18c:	e8 c9 fe ff ff       	call   5a <panic>
    if(fork1() == 0){
     191:	e8 ea fe ff ff       	call   80 <fork1>
     196:	85 c0                	test   %eax,%eax
     198:	75 38                	jne    1d2 <runcmd+0x134>
      close(1);
     19a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     1a1:	e8 3f 0b 00 00       	call   ce5 <close>
      dup(p[1]);
     1a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1a9:	89 04 24             	mov    %eax,(%esp)
     1ac:	e8 84 0b 00 00       	call   d35 <dup>
      close(p[0]);
     1b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     1b4:	89 04 24             	mov    %eax,(%esp)
     1b7:	e8 29 0b 00 00       	call   ce5 <close>
      close(p[1]);
     1bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1bf:	89 04 24             	mov    %eax,(%esp)
     1c2:	e8 1e 0b 00 00       	call   ce5 <close>
      runcmd(pcmd->left);
     1c7:	8b 43 04             	mov    0x4(%ebx),%eax
     1ca:	89 04 24             	mov    %eax,(%esp)
     1cd:	e8 cc fe ff ff       	call   9e <runcmd>
    if(fork1() == 0){
     1d2:	e8 a9 fe ff ff       	call   80 <fork1>
     1d7:	85 c0                	test   %eax,%eax
     1d9:	75 38                	jne    213 <runcmd+0x175>
      close(0);
     1db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1e2:	e8 fe 0a 00 00       	call   ce5 <close>
      dup(p[0]);
     1e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     1ea:	89 04 24             	mov    %eax,(%esp)
     1ed:	e8 43 0b 00 00       	call   d35 <dup>
      close(p[0]);
     1f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
     1f5:	89 04 24             	mov    %eax,(%esp)
     1f8:	e8 e8 0a 00 00       	call   ce5 <close>
      close(p[1]);
     1fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     200:	89 04 24             	mov    %eax,(%esp)
     203:	e8 dd 0a 00 00       	call   ce5 <close>
      runcmd(pcmd->right);
     208:	8b 43 08             	mov    0x8(%ebx),%eax
     20b:	89 04 24             	mov    %eax,(%esp)
     20e:	e8 8b fe ff ff       	call   9e <runcmd>
    close(p[0]);
     213:	8b 45 f0             	mov    -0x10(%ebp),%eax
     216:	89 04 24             	mov    %eax,(%esp)
     219:	e8 c7 0a 00 00       	call   ce5 <close>
    close(p[1]);
     21e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     221:	89 04 24             	mov    %eax,(%esp)
     224:	e8 bc 0a 00 00       	call   ce5 <close>
    wait();
     229:	e8 97 0a 00 00       	call   cc5 <wait>
    wait();
     22e:	e8 92 0a 00 00       	call   cc5 <wait>
    break;
     233:	eb 18                	jmp    24d <runcmd+0x1af>
    if(fork1() == 0)
     235:	e8 46 fe ff ff       	call   80 <fork1>
     23a:	85 c0                	test   %eax,%eax
     23c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
     240:	75 0b                	jne    24d <runcmd+0x1af>
      runcmd(bcmd->cmd);
     242:	8b 43 04             	mov    0x4(%ebx),%eax
     245:	89 04 24             	mov    %eax,(%esp)
     248:	e8 51 fe ff ff       	call   9e <runcmd>
  exit();
     24d:	e8 6b 0a 00 00       	call   cbd <exit>

00000252 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     252:	55                   	push   %ebp
     253:	89 e5                	mov    %esp,%ebp
     255:	53                   	push   %ebx
     256:	83 ec 14             	sub    $0x14,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     259:	c7 04 24 a4 00 00 00 	movl   $0xa4,(%esp)
     260:	e8 07 0e 00 00       	call   106c <malloc>
     265:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
     267:	c7 44 24 08 a4 00 00 	movl   $0xa4,0x8(%esp)
     26e:	00 
     26f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     276:	00 
     277:	89 04 24             	mov    %eax,(%esp)
     27a:	e8 fb 08 00 00       	call   b7a <memset>
  cmd->type = EXEC;
     27f:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  return (struct cmd*)cmd;
}
     285:	89 d8                	mov    %ebx,%eax
     287:	83 c4 14             	add    $0x14,%esp
     28a:	5b                   	pop    %ebx
     28b:	5d                   	pop    %ebp
     28c:	c3                   	ret    

0000028d <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     28d:	55                   	push   %ebp
     28e:	89 e5                	mov    %esp,%ebp
     290:	53                   	push   %ebx
     291:	83 ec 14             	sub    $0x14,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     294:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     29b:	e8 cc 0d 00 00       	call   106c <malloc>
     2a0:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
     2a2:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     2a9:	00 
     2aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     2b1:	00 
     2b2:	89 04 24             	mov    %eax,(%esp)
     2b5:	e8 c0 08 00 00       	call   b7a <memset>
  cmd->type = REDIR;
     2ba:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  cmd->cmd = subcmd;
     2c0:	8b 45 08             	mov    0x8(%ebp),%eax
     2c3:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->file = file;
     2c6:	8b 45 0c             	mov    0xc(%ebp),%eax
     2c9:	89 43 08             	mov    %eax,0x8(%ebx)
  cmd->efile = efile;
     2cc:	8b 45 10             	mov    0x10(%ebp),%eax
     2cf:	89 43 0c             	mov    %eax,0xc(%ebx)
  cmd->mode = mode;
     2d2:	8b 45 14             	mov    0x14(%ebp),%eax
     2d5:	89 43 10             	mov    %eax,0x10(%ebx)
  cmd->fd = fd;
     2d8:	8b 45 18             	mov    0x18(%ebp),%eax
     2db:	89 43 14             	mov    %eax,0x14(%ebx)
  return (struct cmd*)cmd;
}
     2de:	89 d8                	mov    %ebx,%eax
     2e0:	83 c4 14             	add    $0x14,%esp
     2e3:	5b                   	pop    %ebx
     2e4:	5d                   	pop    %ebp
     2e5:	c3                   	ret    

000002e6 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     2e6:	55                   	push   %ebp
     2e7:	89 e5                	mov    %esp,%ebp
     2e9:	53                   	push   %ebx
     2ea:	83 ec 14             	sub    $0x14,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2ed:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     2f4:	e8 73 0d 00 00       	call   106c <malloc>
     2f9:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
     2fb:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     302:	00 
     303:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     30a:	00 
     30b:	89 04 24             	mov    %eax,(%esp)
     30e:	e8 67 08 00 00       	call   b7a <memset>
  cmd->type = PIPE;
     313:	c7 03 03 00 00 00    	movl   $0x3,(%ebx)
  cmd->left = left;
     319:	8b 45 08             	mov    0x8(%ebp),%eax
     31c:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->right = right;
     31f:	8b 45 0c             	mov    0xc(%ebp),%eax
     322:	89 43 08             	mov    %eax,0x8(%ebx)
  return (struct cmd*)cmd;
}
     325:	89 d8                	mov    %ebx,%eax
     327:	83 c4 14             	add    $0x14,%esp
     32a:	5b                   	pop    %ebx
     32b:	5d                   	pop    %ebp
     32c:	c3                   	ret    

0000032d <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     32d:	55                   	push   %ebp
     32e:	89 e5                	mov    %esp,%ebp
     330:	53                   	push   %ebx
     331:	83 ec 14             	sub    $0x14,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     334:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     33b:	e8 2c 0d 00 00       	call   106c <malloc>
     340:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
     342:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     349:	00 
     34a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     351:	00 
     352:	89 04 24             	mov    %eax,(%esp)
     355:	e8 20 08 00 00       	call   b7a <memset>
  cmd->type = LIST;
     35a:	c7 03 04 00 00 00    	movl   $0x4,(%ebx)
  cmd->left = left;
     360:	8b 45 08             	mov    0x8(%ebp),%eax
     363:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->right = right;
     366:	8b 45 0c             	mov    0xc(%ebp),%eax
     369:	89 43 08             	mov    %eax,0x8(%ebx)
  return (struct cmd*)cmd;
}
     36c:	89 d8                	mov    %ebx,%eax
     36e:	83 c4 14             	add    $0x14,%esp
     371:	5b                   	pop    %ebx
     372:	5d                   	pop    %ebp
     373:	c3                   	ret    

00000374 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     374:	55                   	push   %ebp
     375:	89 e5                	mov    %esp,%ebp
     377:	53                   	push   %ebx
     378:	83 ec 14             	sub    $0x14,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     37b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     382:	e8 e5 0c 00 00       	call   106c <malloc>
     387:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
     389:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     390:	00 
     391:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     398:	00 
     399:	89 04 24             	mov    %eax,(%esp)
     39c:	e8 d9 07 00 00       	call   b7a <memset>
  cmd->type = BACK;
     3a1:	c7 03 05 00 00 00    	movl   $0x5,(%ebx)
  cmd->cmd = subcmd;
     3a7:	8b 45 08             	mov    0x8(%ebp),%eax
     3aa:	89 43 04             	mov    %eax,0x4(%ebx)
  return (struct cmd*)cmd;
}
     3ad:	89 d8                	mov    %ebx,%eax
     3af:	83 c4 14             	add    $0x14,%esp
     3b2:	5b                   	pop    %ebx
     3b3:	5d                   	pop    %ebp
     3b4:	c3                   	ret    

000003b5 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     3b5:	55                   	push   %ebp
     3b6:	89 e5                	mov    %esp,%ebp
     3b8:	57                   	push   %edi
     3b9:	56                   	push   %esi
     3ba:	53                   	push   %ebx
     3bb:	83 ec 1c             	sub    $0x1c,%esp
     3be:	8b 75 0c             	mov    0xc(%ebp),%esi
     3c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *s;
  int ret;

  s = *ps;
     3c4:	8b 45 08             	mov    0x8(%ebp),%eax
     3c7:	8b 18                	mov    (%eax),%ebx
  while(s < es && strchr(whitespace, *s))
     3c9:	eb 03                	jmp    3ce <gettoken+0x19>
    s++;
     3cb:	83 c3 01             	add    $0x1,%ebx
  while(s < es && strchr(whitespace, *s))
     3ce:	39 f3                	cmp    %esi,%ebx
     3d0:	73 17                	jae    3e9 <gettoken+0x34>
     3d2:	0f be 03             	movsbl (%ebx),%eax
     3d5:	89 44 24 04          	mov    %eax,0x4(%esp)
     3d9:	c7 04 24 04 12 00 00 	movl   $0x1204,(%esp)
     3e0:	e8 ac 07 00 00       	call   b91 <strchr>
     3e5:	85 c0                	test   %eax,%eax
     3e7:	75 e2                	jne    3cb <gettoken+0x16>
  if(q)
     3e9:	85 ff                	test   %edi,%edi
     3eb:	74 02                	je     3ef <gettoken+0x3a>
    *q = s;
     3ed:	89 1f                	mov    %ebx,(%edi)
  ret = *s;
     3ef:	0f b6 03             	movzbl (%ebx),%eax
     3f2:	0f be f8             	movsbl %al,%edi
  switch(*s){
     3f5:	3c 29                	cmp    $0x29,%al
     3f7:	7f 19                	jg     412 <gettoken+0x5d>
     3f9:	3c 28                	cmp    $0x28,%al
     3fb:	7d 2b                	jge    428 <gettoken+0x73>
     3fd:	84 c0                	test   %al,%al
     3ff:	0f 84 8c 00 00 00    	je     491 <gettoken+0xdc>
     405:	3c 26                	cmp    $0x26,%al
     407:	75 3f                	jne    448 <gettoken+0x93>
     409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
     410:	eb 16                	jmp    428 <gettoken+0x73>
     412:	3c 3e                	cmp    $0x3e,%al
     414:	74 1c                	je     432 <gettoken+0x7d>
     416:	3c 3e                	cmp    $0x3e,%al
     418:	7f 0a                	jg     424 <gettoken+0x6f>
     41a:	83 e8 3b             	sub    $0x3b,%eax
     41d:	3c 01                	cmp    $0x1,%al
     41f:	90                   	nop
     420:	77 26                	ja     448 <gettoken+0x93>
     422:	eb 04                	jmp    428 <gettoken+0x73>
     424:	3c 7c                	cmp    $0x7c,%al
     426:	75 20                	jne    448 <gettoken+0x93>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     428:	83 c3 01             	add    $0x1,%ebx
     42b:	90                   	nop
     42c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    break;
     430:	eb 5f                	jmp    491 <gettoken+0xdc>
  case '>':
    s++;
     432:	8d 43 01             	lea    0x1(%ebx),%eax
    if(*s == '>'){
     435:	80 7b 01 3e          	cmpb   $0x3e,0x1(%ebx)
     439:	75 46                	jne    481 <gettoken+0xcc>
      ret = '+';
      s++;
     43b:	83 c3 02             	add    $0x2,%ebx
      ret = '+';
     43e:	bf 2b 00 00 00       	mov    $0x2b,%edi
     443:	eb 4c                	jmp    491 <gettoken+0xdc>
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
     445:	83 c3 01             	add    $0x1,%ebx
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     448:	39 f3                	cmp    %esi,%ebx
     44a:	73 39                	jae    485 <gettoken+0xd0>
     44c:	0f be 03             	movsbl (%ebx),%eax
     44f:	89 44 24 04          	mov    %eax,0x4(%esp)
     453:	c7 04 24 04 12 00 00 	movl   $0x1204,(%esp)
     45a:	e8 32 07 00 00       	call   b91 <strchr>
     45f:	85 c0                	test   %eax,%eax
     461:	75 29                	jne    48c <gettoken+0xd7>
     463:	0f be 03             	movsbl (%ebx),%eax
     466:	89 44 24 04          	mov    %eax,0x4(%esp)
     46a:	c7 04 24 fc 11 00 00 	movl   $0x11fc,(%esp)
     471:	e8 1b 07 00 00       	call   b91 <strchr>
     476:	85 c0                	test   %eax,%eax
     478:	74 cb                	je     445 <gettoken+0x90>
    ret = 'a';
     47a:	bf 61 00 00 00       	mov    $0x61,%edi
     47f:	eb 10                	jmp    491 <gettoken+0xdc>
    s++;
     481:	89 c3                	mov    %eax,%ebx
     483:	eb 0c                	jmp    491 <gettoken+0xdc>
    ret = 'a';
     485:	bf 61 00 00 00       	mov    $0x61,%edi
     48a:	eb 05                	jmp    491 <gettoken+0xdc>
     48c:	bf 61 00 00 00       	mov    $0x61,%edi
    break;
  }
  if(eq)
     491:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     495:	74 0a                	je     4a1 <gettoken+0xec>
    *eq = s;
     497:	8b 45 14             	mov    0x14(%ebp),%eax
     49a:	89 18                	mov    %ebx,(%eax)
     49c:	eb 03                	jmp    4a1 <gettoken+0xec>

  while(s < es && strchr(whitespace, *s))
    s++;
     49e:	83 c3 01             	add    $0x1,%ebx
  while(s < es && strchr(whitespace, *s))
     4a1:	39 f3                	cmp    %esi,%ebx
     4a3:	73 17                	jae    4bc <gettoken+0x107>
     4a5:	0f be 03             	movsbl (%ebx),%eax
     4a8:	89 44 24 04          	mov    %eax,0x4(%esp)
     4ac:	c7 04 24 04 12 00 00 	movl   $0x1204,(%esp)
     4b3:	e8 d9 06 00 00       	call   b91 <strchr>
     4b8:	85 c0                	test   %eax,%eax
     4ba:	75 e2                	jne    49e <gettoken+0xe9>
  *ps = s;
     4bc:	8b 45 08             	mov    0x8(%ebp),%eax
     4bf:	89 18                	mov    %ebx,(%eax)
  return ret;
}
     4c1:	89 f8                	mov    %edi,%eax
     4c3:	83 c4 1c             	add    $0x1c,%esp
     4c6:	5b                   	pop    %ebx
     4c7:	5e                   	pop    %esi
     4c8:	5f                   	pop    %edi
     4c9:	5d                   	pop    %ebp
     4ca:	c3                   	ret    

000004cb <peek>:

int
peek(char **ps, char *es, char *toks)
{
     4cb:	55                   	push   %ebp
     4cc:	89 e5                	mov    %esp,%ebp
     4ce:	57                   	push   %edi
     4cf:	56                   	push   %esi
     4d0:	53                   	push   %ebx
     4d1:	83 ec 1c             	sub    $0x1c,%esp
     4d4:	8b 7d 08             	mov    0x8(%ebp),%edi
     4d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *s;

  s = *ps;
     4da:	8b 1f                	mov    (%edi),%ebx
  while(s < es && strchr(whitespace, *s))
     4dc:	eb 03                	jmp    4e1 <peek+0x16>
    s++;
     4de:	83 c3 01             	add    $0x1,%ebx
  while(s < es && strchr(whitespace, *s))
     4e1:	39 f3                	cmp    %esi,%ebx
     4e3:	73 17                	jae    4fc <peek+0x31>
     4e5:	0f be 03             	movsbl (%ebx),%eax
     4e8:	89 44 24 04          	mov    %eax,0x4(%esp)
     4ec:	c7 04 24 04 12 00 00 	movl   $0x1204,(%esp)
     4f3:	e8 99 06 00 00       	call   b91 <strchr>
     4f8:	85 c0                	test   %eax,%eax
     4fa:	75 e2                	jne    4de <peek+0x13>
  *ps = s;
     4fc:	89 1f                	mov    %ebx,(%edi)
  return *s && strchr(toks, *s);
     4fe:	0f b6 03             	movzbl (%ebx),%eax
     501:	84 c0                	test   %al,%al
     503:	74 1d                	je     522 <peek+0x57>
     505:	0f be c0             	movsbl %al,%eax
     508:	89 44 24 04          	mov    %eax,0x4(%esp)
     50c:	8b 45 10             	mov    0x10(%ebp),%eax
     50f:	89 04 24             	mov    %eax,(%esp)
     512:	e8 7a 06 00 00       	call   b91 <strchr>
     517:	85 c0                	test   %eax,%eax
     519:	74 0e                	je     529 <peek+0x5e>
     51b:	b8 01 00 00 00       	mov    $0x1,%eax
     520:	eb 0c                	jmp    52e <peek+0x63>
     522:	b8 00 00 00 00       	mov    $0x0,%eax
     527:	eb 05                	jmp    52e <peek+0x63>
     529:	b8 00 00 00 00       	mov    $0x0,%eax
}
     52e:	83 c4 1c             	add    $0x1c,%esp
     531:	5b                   	pop    %ebx
     532:	5e                   	pop    %esi
     533:	5f                   	pop    %edi
     534:	5d                   	pop    %ebp
     535:	c3                   	ret    

00000536 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     536:	55                   	push   %ebp
     537:	89 e5                	mov    %esp,%ebp
     539:	57                   	push   %edi
     53a:	56                   	push   %esi
     53b:	53                   	push   %ebx
     53c:	83 ec 3c             	sub    $0x3c,%esp
     53f:	8b 7d 0c             	mov    0xc(%ebp),%edi
     542:	8b 75 10             	mov    0x10(%ebp),%esi
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     545:	e9 e6 00 00 00       	jmp    630 <parseredirs+0xfa>
    tok = gettoken(ps, es, 0, 0);
     54a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     551:	00 
     552:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     559:	00 
     55a:	89 74 24 04          	mov    %esi,0x4(%esp)
     55e:	89 3c 24             	mov    %edi,(%esp)
     561:	e8 4f fe ff ff       	call   3b5 <gettoken>
     566:	89 c3                	mov    %eax,%ebx
    if(gettoken(ps, es, &q, &eq) != 'a')
     568:	8d 45 e0             	lea    -0x20(%ebp),%eax
     56b:	89 44 24 0c          	mov    %eax,0xc(%esp)
     56f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     572:	89 44 24 08          	mov    %eax,0x8(%esp)
     576:	89 74 24 04          	mov    %esi,0x4(%esp)
     57a:	89 3c 24             	mov    %edi,(%esp)
     57d:	e8 33 fe ff ff       	call   3b5 <gettoken>
     582:	83 f8 61             	cmp    $0x61,%eax
     585:	74 0c                	je     593 <parseredirs+0x5d>
      panic("missing file for redirection");
     587:	c7 04 24 30 11 00 00 	movl   $0x1130,(%esp)
     58e:	e8 c7 fa ff ff       	call   5a <panic>
    switch(tok){
     593:	83 fb 3c             	cmp    $0x3c,%ebx
     596:	74 10                	je     5a8 <parseredirs+0x72>
     598:	83 fb 3e             	cmp    $0x3e,%ebx
     59b:	74 39                	je     5d6 <parseredirs+0xa0>
     59d:	83 fb 2b             	cmp    $0x2b,%ebx
     5a0:	0f 85 8a 00 00 00    	jne    630 <parseredirs+0xfa>
     5a6:	eb 5c                	jmp    604 <parseredirs+0xce>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5a8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     5af:	00 
     5b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     5b7:	00 
     5b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
     5bb:	89 44 24 08          	mov    %eax,0x8(%esp)
     5bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     5c2:	89 44 24 04          	mov    %eax,0x4(%esp)
     5c6:	8b 45 08             	mov    0x8(%ebp),%eax
     5c9:	89 04 24             	mov    %eax,(%esp)
     5cc:	e8 bc fc ff ff       	call   28d <redircmd>
     5d1:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     5d4:	eb 5a                	jmp    630 <parseredirs+0xfa>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     5d6:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     5dd:	00 
     5de:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     5e5:	00 
     5e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
     5e9:	89 44 24 08          	mov    %eax,0x8(%esp)
     5ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     5f0:	89 44 24 04          	mov    %eax,0x4(%esp)
     5f4:	8b 45 08             	mov    0x8(%ebp),%eax
     5f7:	89 04 24             	mov    %eax,(%esp)
     5fa:	e8 8e fc ff ff       	call   28d <redircmd>
     5ff:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     602:	eb 2c                	jmp    630 <parseredirs+0xfa>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     604:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     60b:	00 
     60c:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     613:	00 
     614:	8b 45 e0             	mov    -0x20(%ebp),%eax
     617:	89 44 24 08          	mov    %eax,0x8(%esp)
     61b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     61e:	89 44 24 04          	mov    %eax,0x4(%esp)
     622:	8b 45 08             	mov    0x8(%ebp),%eax
     625:	89 04 24             	mov    %eax,(%esp)
     628:	e8 60 fc ff ff       	call   28d <redircmd>
     62d:	89 45 08             	mov    %eax,0x8(%ebp)
  while(peek(ps, es, "<>")){
     630:	c7 44 24 08 4d 11 00 	movl   $0x114d,0x8(%esp)
     637:	00 
     638:	89 74 24 04          	mov    %esi,0x4(%esp)
     63c:	89 3c 24             	mov    %edi,(%esp)
     63f:	e8 87 fe ff ff       	call   4cb <peek>
     644:	85 c0                	test   %eax,%eax
     646:	0f 85 fe fe ff ff    	jne    54a <parseredirs+0x14>
      break;
    }
  }
  return cmd;
}
     64c:	8b 45 08             	mov    0x8(%ebp),%eax
     64f:	83 c4 3c             	add    $0x3c,%esp
     652:	5b                   	pop    %ebx
     653:	5e                   	pop    %esi
     654:	5f                   	pop    %edi
     655:	5d                   	pop    %ebp
     656:	c3                   	ret    

00000657 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     657:	55                   	push   %ebp
     658:	89 e5                	mov    %esp,%ebp
     65a:	57                   	push   %edi
     65b:	56                   	push   %esi
     65c:	53                   	push   %ebx
     65d:	83 ec 3c             	sub    $0x3c,%esp
     660:	8b 75 08             	mov    0x8(%ebp),%esi
     663:	8b 7d 0c             	mov    0xc(%ebp),%edi
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     666:	c7 44 24 08 50 11 00 	movl   $0x1150,0x8(%esp)
     66d:	00 
     66e:	89 7c 24 04          	mov    %edi,0x4(%esp)
     672:	89 34 24             	mov    %esi,(%esp)
     675:	e8 51 fe ff ff       	call   4cb <peek>
     67a:	85 c0                	test   %eax,%eax
     67c:	74 11                	je     68f <parseexec+0x38>
    return parseblock(ps, es);
     67e:	89 7c 24 04          	mov    %edi,0x4(%esp)
     682:	89 34 24             	mov    %esi,(%esp)
     685:	e8 f5 01 00 00       	call   87f <parseblock>
     68a:	e9 be 00 00 00       	jmp    74d <parseexec+0xf6>

  ret = execcmd();
     68f:	e8 be fb ff ff       	call   252 <execcmd>
     694:	89 45 d0             	mov    %eax,-0x30(%ebp)
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     697:	89 7c 24 08          	mov    %edi,0x8(%esp)
     69b:	89 74 24 04          	mov    %esi,0x4(%esp)
     69f:	89 04 24             	mov    %eax,(%esp)
     6a2:	e8 8f fe ff ff       	call   536 <parseredirs>
     6a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  argc = 0;
     6aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  while(!peek(ps, es, "|)&;")){
     6af:	eb 6a                	jmp    71b <parseexec+0xc4>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     6b1:	8d 45 e0             	lea    -0x20(%ebp),%eax
     6b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
     6b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     6bb:	89 44 24 08          	mov    %eax,0x8(%esp)
     6bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
     6c3:	89 34 24             	mov    %esi,(%esp)
     6c6:	e8 ea fc ff ff       	call   3b5 <gettoken>
     6cb:	85 c0                	test   %eax,%eax
     6cd:	74 68                	je     737 <parseexec+0xe0>
      break;
    if(tok != 'a')
     6cf:	83 f8 61             	cmp    $0x61,%eax
     6d2:	74 0c                	je     6e0 <parseexec+0x89>
      panic("syntax");
     6d4:	c7 04 24 52 11 00 00 	movl   $0x1152,(%esp)
     6db:	e8 7a f9 ff ff       	call   5a <panic>
    cmd->argv[argc] = q;
     6e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     6e3:	8b 55 d0             	mov    -0x30(%ebp),%edx
     6e6:	89 44 9a 04          	mov    %eax,0x4(%edx,%ebx,4)
    cmd->eargv[argc] = eq;
     6ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
     6ed:	89 44 9a 54          	mov    %eax,0x54(%edx,%ebx,4)
    argc++;
     6f1:	83 c3 01             	add    $0x1,%ebx
    if(argc >= MAXARGS)
     6f4:	83 fb 13             	cmp    $0x13,%ebx
     6f7:	7e 0c                	jle    705 <parseexec+0xae>
      panic("too many args");
     6f9:	c7 04 24 59 11 00 00 	movl   $0x1159,(%esp)
     700:	e8 55 f9 ff ff       	call   5a <panic>
    ret = parseredirs(ret, ps, es);
     705:	89 7c 24 08          	mov    %edi,0x8(%esp)
     709:	89 74 24 04          	mov    %esi,0x4(%esp)
     70d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     710:	89 04 24             	mov    %eax,(%esp)
     713:	e8 1e fe ff ff       	call   536 <parseredirs>
     718:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  while(!peek(ps, es, "|)&;")){
     71b:	c7 44 24 08 67 11 00 	movl   $0x1167,0x8(%esp)
     722:	00 
     723:	89 7c 24 04          	mov    %edi,0x4(%esp)
     727:	89 34 24             	mov    %esi,(%esp)
     72a:	e8 9c fd ff ff       	call   4cb <peek>
     72f:	85 c0                	test   %eax,%eax
     731:	0f 84 7a ff ff ff    	je     6b1 <parseexec+0x5a>
  }
  cmd->argv[argc] = 0;
     737:	8b 45 d0             	mov    -0x30(%ebp),%eax
     73a:	c7 44 98 04 00 00 00 	movl   $0x0,0x4(%eax,%ebx,4)
     741:	00 
  cmd->eargv[argc] = 0;
     742:	c7 44 98 54 00 00 00 	movl   $0x0,0x54(%eax,%ebx,4)
     749:	00 
  return ret;
     74a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
     74d:	83 c4 3c             	add    $0x3c,%esp
     750:	5b                   	pop    %ebx
     751:	5e                   	pop    %esi
     752:	5f                   	pop    %edi
     753:	5d                   	pop    %ebp
     754:	c3                   	ret    

00000755 <parsepipe>:
{
     755:	55                   	push   %ebp
     756:	89 e5                	mov    %esp,%ebp
     758:	57                   	push   %edi
     759:	56                   	push   %esi
     75a:	53                   	push   %ebx
     75b:	83 ec 1c             	sub    $0x1c,%esp
     75e:	8b 5d 08             	mov    0x8(%ebp),%ebx
     761:	8b 75 0c             	mov    0xc(%ebp),%esi
  cmd = parseexec(ps, es);
     764:	89 74 24 04          	mov    %esi,0x4(%esp)
     768:	89 1c 24             	mov    %ebx,(%esp)
     76b:	e8 e7 fe ff ff       	call   657 <parseexec>
     770:	89 c7                	mov    %eax,%edi
  if(peek(ps, es, "|")){
     772:	c7 44 24 08 6c 11 00 	movl   $0x116c,0x8(%esp)
     779:	00 
     77a:	89 74 24 04          	mov    %esi,0x4(%esp)
     77e:	89 1c 24             	mov    %ebx,(%esp)
     781:	e8 45 fd ff ff       	call   4cb <peek>
     786:	85 c0                	test   %eax,%eax
     788:	74 36                	je     7c0 <parsepipe+0x6b>
    gettoken(ps, es, 0, 0);
     78a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     791:	00 
     792:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     799:	00 
     79a:	89 74 24 04          	mov    %esi,0x4(%esp)
     79e:	89 1c 24             	mov    %ebx,(%esp)
     7a1:	e8 0f fc ff ff       	call   3b5 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     7a6:	89 74 24 04          	mov    %esi,0x4(%esp)
     7aa:	89 1c 24             	mov    %ebx,(%esp)
     7ad:	e8 a3 ff ff ff       	call   755 <parsepipe>
     7b2:	89 44 24 04          	mov    %eax,0x4(%esp)
     7b6:	89 3c 24             	mov    %edi,(%esp)
     7b9:	e8 28 fb ff ff       	call   2e6 <pipecmd>
     7be:	89 c7                	mov    %eax,%edi
}
     7c0:	89 f8                	mov    %edi,%eax
     7c2:	83 c4 1c             	add    $0x1c,%esp
     7c5:	5b                   	pop    %ebx
     7c6:	5e                   	pop    %esi
     7c7:	5f                   	pop    %edi
     7c8:	5d                   	pop    %ebp
     7c9:	c3                   	ret    

000007ca <parseline>:
{
     7ca:	55                   	push   %ebp
     7cb:	89 e5                	mov    %esp,%ebp
     7cd:	57                   	push   %edi
     7ce:	56                   	push   %esi
     7cf:	53                   	push   %ebx
     7d0:	83 ec 1c             	sub    $0x1c,%esp
     7d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
     7d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  cmd = parsepipe(ps, es);
     7d9:	89 74 24 04          	mov    %esi,0x4(%esp)
     7dd:	89 1c 24             	mov    %ebx,(%esp)
     7e0:	e8 70 ff ff ff       	call   755 <parsepipe>
     7e5:	89 c7                	mov    %eax,%edi
  while(peek(ps, es, "&")){
     7e7:	eb 26                	jmp    80f <parseline+0x45>
    gettoken(ps, es, 0, 0);
     7e9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     7f0:	00 
     7f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7f8:	00 
     7f9:	89 74 24 04          	mov    %esi,0x4(%esp)
     7fd:	89 1c 24             	mov    %ebx,(%esp)
     800:	e8 b0 fb ff ff       	call   3b5 <gettoken>
    cmd = backcmd(cmd);
     805:	89 3c 24             	mov    %edi,(%esp)
     808:	e8 67 fb ff ff       	call   374 <backcmd>
     80d:	89 c7                	mov    %eax,%edi
  while(peek(ps, es, "&")){
     80f:	c7 44 24 08 6e 11 00 	movl   $0x116e,0x8(%esp)
     816:	00 
     817:	89 74 24 04          	mov    %esi,0x4(%esp)
     81b:	89 1c 24             	mov    %ebx,(%esp)
     81e:	e8 a8 fc ff ff       	call   4cb <peek>
     823:	85 c0                	test   %eax,%eax
     825:	75 c2                	jne    7e9 <parseline+0x1f>
  if(peek(ps, es, ";")){
     827:	c7 44 24 08 6a 11 00 	movl   $0x116a,0x8(%esp)
     82e:	00 
     82f:	89 74 24 04          	mov    %esi,0x4(%esp)
     833:	89 1c 24             	mov    %ebx,(%esp)
     836:	e8 90 fc ff ff       	call   4cb <peek>
     83b:	85 c0                	test   %eax,%eax
     83d:	74 36                	je     875 <parseline+0xab>
    gettoken(ps, es, 0, 0);
     83f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     846:	00 
     847:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     84e:	00 
     84f:	89 74 24 04          	mov    %esi,0x4(%esp)
     853:	89 1c 24             	mov    %ebx,(%esp)
     856:	e8 5a fb ff ff       	call   3b5 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     85b:	89 74 24 04          	mov    %esi,0x4(%esp)
     85f:	89 1c 24             	mov    %ebx,(%esp)
     862:	e8 63 ff ff ff       	call   7ca <parseline>
     867:	89 44 24 04          	mov    %eax,0x4(%esp)
     86b:	89 3c 24             	mov    %edi,(%esp)
     86e:	e8 ba fa ff ff       	call   32d <listcmd>
     873:	89 c7                	mov    %eax,%edi
}
     875:	89 f8                	mov    %edi,%eax
     877:	83 c4 1c             	add    $0x1c,%esp
     87a:	5b                   	pop    %ebx
     87b:	5e                   	pop    %esi
     87c:	5f                   	pop    %edi
     87d:	5d                   	pop    %ebp
     87e:	c3                   	ret    

0000087f <parseblock>:
{
     87f:	55                   	push   %ebp
     880:	89 e5                	mov    %esp,%ebp
     882:	57                   	push   %edi
     883:	56                   	push   %esi
     884:	53                   	push   %ebx
     885:	83 ec 1c             	sub    $0x1c,%esp
     888:	8b 5d 08             	mov    0x8(%ebp),%ebx
     88b:	8b 75 0c             	mov    0xc(%ebp),%esi
  if(!peek(ps, es, "("))
     88e:	c7 44 24 08 50 11 00 	movl   $0x1150,0x8(%esp)
     895:	00 
     896:	89 74 24 04          	mov    %esi,0x4(%esp)
     89a:	89 1c 24             	mov    %ebx,(%esp)
     89d:	e8 29 fc ff ff       	call   4cb <peek>
     8a2:	85 c0                	test   %eax,%eax
     8a4:	75 0c                	jne    8b2 <parseblock+0x33>
    panic("parseblock");
     8a6:	c7 04 24 70 11 00 00 	movl   $0x1170,(%esp)
     8ad:	e8 a8 f7 ff ff       	call   5a <panic>
  gettoken(ps, es, 0, 0);
     8b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8b9:	00 
     8ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8c1:	00 
     8c2:	89 74 24 04          	mov    %esi,0x4(%esp)
     8c6:	89 1c 24             	mov    %ebx,(%esp)
     8c9:	e8 e7 fa ff ff       	call   3b5 <gettoken>
  cmd = parseline(ps, es);
     8ce:	89 74 24 04          	mov    %esi,0x4(%esp)
     8d2:	89 1c 24             	mov    %ebx,(%esp)
     8d5:	e8 f0 fe ff ff       	call   7ca <parseline>
     8da:	89 c7                	mov    %eax,%edi
  if(!peek(ps, es, ")"))
     8dc:	c7 44 24 08 8c 11 00 	movl   $0x118c,0x8(%esp)
     8e3:	00 
     8e4:	89 74 24 04          	mov    %esi,0x4(%esp)
     8e8:	89 1c 24             	mov    %ebx,(%esp)
     8eb:	e8 db fb ff ff       	call   4cb <peek>
     8f0:	85 c0                	test   %eax,%eax
     8f2:	75 0c                	jne    900 <parseblock+0x81>
    panic("syntax - missing )");
     8f4:	c7 04 24 7b 11 00 00 	movl   $0x117b,(%esp)
     8fb:	e8 5a f7 ff ff       	call   5a <panic>
  gettoken(ps, es, 0, 0);
     900:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     907:	00 
     908:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     90f:	00 
     910:	89 74 24 04          	mov    %esi,0x4(%esp)
     914:	89 1c 24             	mov    %ebx,(%esp)
     917:	e8 99 fa ff ff       	call   3b5 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     91c:	89 74 24 08          	mov    %esi,0x8(%esp)
     920:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     924:	89 3c 24             	mov    %edi,(%esp)
     927:	e8 0a fc ff ff       	call   536 <parseredirs>
}
     92c:	83 c4 1c             	add    $0x1c,%esp
     92f:	5b                   	pop    %ebx
     930:	5e                   	pop    %esi
     931:	5f                   	pop    %edi
     932:	5d                   	pop    %ebp
     933:	c3                   	ret    

00000934 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     934:	55                   	push   %ebp
     935:	89 e5                	mov    %esp,%ebp
     937:	53                   	push   %ebx
     938:	83 ec 14             	sub    $0x14,%esp
     93b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     93e:	85 db                	test   %ebx,%ebx
     940:	74 7a                	je     9bc <nulterminate+0x88>
    return 0;

  switch(cmd->type){
     942:	8b 03                	mov    (%ebx),%eax
     944:	83 f8 05             	cmp    $0x5,%eax
     947:	77 6f                	ja     9b8 <nulterminate+0x84>
     949:	ff 24 85 cc 11 00 00 	jmp    *0x11cc(,%eax,4)
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
      *ecmd->eargv[i] = 0;
     950:	8b 44 93 54          	mov    0x54(%ebx,%edx,4),%eax
     954:	c6 00 00             	movb   $0x0,(%eax)
    for(i=0; ecmd->argv[i]; i++)
     957:	83 c2 01             	add    $0x1,%edx
     95a:	eb 05                	jmp    961 <nulterminate+0x2d>
  switch(cmd->type){
     95c:	ba 00 00 00 00       	mov    $0x0,%edx
    for(i=0; ecmd->argv[i]; i++)
     961:	83 7c 93 04 00       	cmpl   $0x0,0x4(%ebx,%edx,4)
     966:	75 e8                	jne    950 <nulterminate+0x1c>
     968:	eb 4e                	jmp    9b8 <nulterminate+0x84>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     96a:	8b 43 04             	mov    0x4(%ebx),%eax
     96d:	89 04 24             	mov    %eax,(%esp)
     970:	e8 bf ff ff ff       	call   934 <nulterminate>
    *rcmd->efile = 0;
     975:	8b 43 0c             	mov    0xc(%ebx),%eax
     978:	c6 00 00             	movb   $0x0,(%eax)
    break;
     97b:	eb 3b                	jmp    9b8 <nulterminate+0x84>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
    nulterminate(pcmd->left);
     97d:	8b 43 04             	mov    0x4(%ebx),%eax
     980:	89 04 24             	mov    %eax,(%esp)
     983:	e8 ac ff ff ff       	call   934 <nulterminate>
    nulterminate(pcmd->right);
     988:	8b 43 08             	mov    0x8(%ebx),%eax
     98b:	89 04 24             	mov    %eax,(%esp)
     98e:	e8 a1 ff ff ff       	call   934 <nulterminate>
    break;
     993:	eb 23                	jmp    9b8 <nulterminate+0x84>

  case LIST:
    lcmd = (struct listcmd*)cmd;
    nulterminate(lcmd->left);
     995:	8b 43 04             	mov    0x4(%ebx),%eax
     998:	89 04 24             	mov    %eax,(%esp)
     99b:	e8 94 ff ff ff       	call   934 <nulterminate>
    nulterminate(lcmd->right);
     9a0:	8b 43 08             	mov    0x8(%ebx),%eax
     9a3:	89 04 24             	mov    %eax,(%esp)
     9a6:	e8 89 ff ff ff       	call   934 <nulterminate>
    break;
     9ab:	eb 0b                	jmp    9b8 <nulterminate+0x84>

  case BACK:
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
     9ad:	8b 43 04             	mov    0x4(%ebx),%eax
     9b0:	89 04 24             	mov    %eax,(%esp)
     9b3:	e8 7c ff ff ff       	call   934 <nulterminate>
    break;
  }
  return cmd;
     9b8:	89 d8                	mov    %ebx,%eax
     9ba:	eb 05                	jmp    9c1 <nulterminate+0x8d>
    return 0;
     9bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
     9c1:	83 c4 14             	add    $0x14,%esp
     9c4:	5b                   	pop    %ebx
     9c5:	5d                   	pop    %ebp
     9c6:	c3                   	ret    

000009c7 <parsecmd>:
{
     9c7:	55                   	push   %ebp
     9c8:	89 e5                	mov    %esp,%ebp
     9ca:	56                   	push   %esi
     9cb:	53                   	push   %ebx
     9cc:	83 ec 10             	sub    $0x10,%esp
  es = s + strlen(s);
     9cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
     9d2:	89 1c 24             	mov    %ebx,(%esp)
     9d5:	e8 86 01 00 00       	call   b60 <strlen>
     9da:	01 c3                	add    %eax,%ebx
  cmd = parseline(&s, es);
     9dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     9e0:	8d 45 08             	lea    0x8(%ebp),%eax
     9e3:	89 04 24             	mov    %eax,(%esp)
     9e6:	e8 df fd ff ff       	call   7ca <parseline>
     9eb:	89 c6                	mov    %eax,%esi
  peek(&s, es, "");
     9ed:	c7 44 24 08 1a 11 00 	movl   $0x111a,0x8(%esp)
     9f4:	00 
     9f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     9f9:	8d 45 08             	lea    0x8(%ebp),%eax
     9fc:	89 04 24             	mov    %eax,(%esp)
     9ff:	e8 c7 fa ff ff       	call   4cb <peek>
  if(s != es){
     a04:	8b 45 08             	mov    0x8(%ebp),%eax
     a07:	39 d8                	cmp    %ebx,%eax
     a09:	74 24                	je     a2f <parsecmd+0x68>
    printf(2, "leftovers: %s\n", s);
     a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
     a0f:	c7 44 24 04 8e 11 00 	movl   $0x118e,0x4(%esp)
     a16:	00 
     a17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     a1e:	e8 29 04 00 00       	call   e4c <printf>
    panic("syntax");
     a23:	c7 04 24 52 11 00 00 	movl   $0x1152,(%esp)
     a2a:	e8 2b f6 ff ff       	call   5a <panic>
  nulterminate(cmd);
     a2f:	89 34 24             	mov    %esi,(%esp)
     a32:	e8 fd fe ff ff       	call   934 <nulterminate>
}
     a37:	89 f0                	mov    %esi,%eax
     a39:	83 c4 10             	add    $0x10,%esp
     a3c:	5b                   	pop    %ebx
     a3d:	5e                   	pop    %esi
     a3e:	5d                   	pop    %ebp
     a3f:	c3                   	ret    

00000a40 <main>:
{
     a40:	55                   	push   %ebp
     a41:	89 e5                	mov    %esp,%ebp
     a43:	83 e4 f0             	and    $0xfffffff0,%esp
     a46:	83 ec 10             	sub    $0x10,%esp
  while((fd = open("console", O_RDWR)) >= 0){
     a49:	eb 12                	jmp    a5d <main+0x1d>
    if(fd >= 3){
     a4b:	83 f8 02             	cmp    $0x2,%eax
     a4e:	7e 0d                	jle    a5d <main+0x1d>
      close(fd);
     a50:	89 04 24             	mov    %eax,(%esp)
     a53:	e8 8d 02 00 00       	call   ce5 <close>
      break;
     a58:	e9 9e 00 00 00       	jmp    afb <main+0xbb>
  while((fd = open("console", O_RDWR)) >= 0){
     a5d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     a64:	00 
     a65:	c7 04 24 9d 11 00 00 	movl   $0x119d,(%esp)
     a6c:	e8 8c 02 00 00       	call   cfd <open>
     a71:	85 c0                	test   %eax,%eax
     a73:	79 d6                	jns    a4b <main+0xb>
     a75:	e9 81 00 00 00       	jmp    afb <main+0xbb>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     a7a:	80 3d 20 12 00 00 63 	cmpb   $0x63,0x1220
     a81:	75 53                	jne    ad6 <main+0x96>
     a83:	80 3d 21 12 00 00 64 	cmpb   $0x64,0x1221
     a8a:	75 4a                	jne    ad6 <main+0x96>
     a8c:	80 3d 22 12 00 00 20 	cmpb   $0x20,0x1222
     a93:	75 41                	jne    ad6 <main+0x96>
      buf[strlen(buf)-1] = 0;  // chop \n
     a95:	c7 04 24 20 12 00 00 	movl   $0x1220,(%esp)
     a9c:	e8 bf 00 00 00       	call   b60 <strlen>
     aa1:	c6 80 1f 12 00 00 00 	movb   $0x0,0x121f(%eax)
      if(chdir(buf+3) < 0)
     aa8:	c7 04 24 23 12 00 00 	movl   $0x1223,(%esp)
     aaf:	e8 79 02 00 00       	call   d2d <chdir>
     ab4:	85 c0                	test   %eax,%eax
     ab6:	79 43                	jns    afb <main+0xbb>
        printf(2, "cannot cd %s\n", buf+3);
     ab8:	c7 44 24 08 23 12 00 	movl   $0x1223,0x8(%esp)
     abf:	00 
     ac0:	c7 44 24 04 a5 11 00 	movl   $0x11a5,0x4(%esp)
     ac7:	00 
     ac8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     acf:	e8 78 03 00 00       	call   e4c <printf>
      continue;
     ad4:	eb 25                	jmp    afb <main+0xbb>
    if(fork1() == 0)
     ad6:	e8 a5 f5 ff ff       	call   80 <fork1>
     adb:	85 c0                	test   %eax,%eax
     add:	8d 76 00             	lea    0x0(%esi),%esi
     ae0:	75 14                	jne    af6 <main+0xb6>
      runcmd(parsecmd(buf));
     ae2:	c7 04 24 20 12 00 00 	movl   $0x1220,(%esp)
     ae9:	e8 d9 fe ff ff       	call   9c7 <parsecmd>
     aee:	89 04 24             	mov    %eax,(%esp)
     af1:	e8 a8 f5 ff ff       	call   9e <runcmd>
    wait();
     af6:	e8 ca 01 00 00       	call   cc5 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     afb:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
     b02:	00 
     b03:	c7 04 24 20 12 00 00 	movl   $0x1220,(%esp)
     b0a:	e8 f1 f4 ff ff       	call   0 <getcmd>
     b0f:	85 c0                	test   %eax,%eax
     b11:	0f 89 63 ff ff ff    	jns    a7a <main+0x3a>
  exit();
     b17:	e8 a1 01 00 00       	call   cbd <exit>

00000b1c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
     b1c:	55                   	push   %ebp
     b1d:	89 e5                	mov    %esp,%ebp
     b1f:	53                   	push   %ebx
     b20:	8b 45 08             	mov    0x8(%ebp),%eax
     b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     b26:	89 c2                	mov    %eax,%edx
     b28:	0f b6 19             	movzbl (%ecx),%ebx
     b2b:	88 1a                	mov    %bl,(%edx)
     b2d:	8d 52 01             	lea    0x1(%edx),%edx
     b30:	8d 49 01             	lea    0x1(%ecx),%ecx
     b33:	84 db                	test   %bl,%bl
     b35:	75 f1                	jne    b28 <strcpy+0xc>
    ;
  return os;
}
     b37:	5b                   	pop    %ebx
     b38:	5d                   	pop    %ebp
     b39:	c3                   	ret    

00000b3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
     b3a:	55                   	push   %ebp
     b3b:	89 e5                	mov    %esp,%ebp
     b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
     b40:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
     b43:	eb 06                	jmp    b4b <strcmp+0x11>
    p++, q++;
     b45:	83 c1 01             	add    $0x1,%ecx
     b48:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
     b4b:	0f b6 01             	movzbl (%ecx),%eax
     b4e:	84 c0                	test   %al,%al
     b50:	74 04                	je     b56 <strcmp+0x1c>
     b52:	3a 02                	cmp    (%edx),%al
     b54:	74 ef                	je     b45 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
     b56:	0f b6 c0             	movzbl %al,%eax
     b59:	0f b6 12             	movzbl (%edx),%edx
     b5c:	29 d0                	sub    %edx,%eax
}
     b5e:	5d                   	pop    %ebp
     b5f:	c3                   	ret    

00000b60 <strlen>:

uint
strlen(const char *s)
{
     b60:	55                   	push   %ebp
     b61:	89 e5                	mov    %esp,%ebp
     b63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
     b66:	ba 00 00 00 00       	mov    $0x0,%edx
     b6b:	eb 03                	jmp    b70 <strlen+0x10>
     b6d:	83 c2 01             	add    $0x1,%edx
     b70:	89 d0                	mov    %edx,%eax
     b72:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
     b76:	75 f5                	jne    b6d <strlen+0xd>
    ;
  return n;
}
     b78:	5d                   	pop    %ebp
     b79:	c3                   	ret    

00000b7a <memset>:

void*
memset(void *dst, int c, uint n)
{
     b7a:	55                   	push   %ebp
     b7b:	89 e5                	mov    %esp,%ebp
     b7d:	57                   	push   %edi
     b7e:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
     b81:	89 d7                	mov    %edx,%edi
     b83:	8b 4d 10             	mov    0x10(%ebp),%ecx
     b86:	8b 45 0c             	mov    0xc(%ebp),%eax
     b89:	fc                   	cld    
     b8a:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
     b8c:	89 d0                	mov    %edx,%eax
     b8e:	5f                   	pop    %edi
     b8f:	5d                   	pop    %ebp
     b90:	c3                   	ret    

00000b91 <strchr>:

char*
strchr(const char *s, char c)
{
     b91:	55                   	push   %ebp
     b92:	89 e5                	mov    %esp,%ebp
     b94:	8b 45 08             	mov    0x8(%ebp),%eax
     b97:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
     b9b:	eb 07                	jmp    ba4 <strchr+0x13>
    if(*s == c)
     b9d:	38 ca                	cmp    %cl,%dl
     b9f:	74 0f                	je     bb0 <strchr+0x1f>
  for(; *s; s++)
     ba1:	83 c0 01             	add    $0x1,%eax
     ba4:	0f b6 10             	movzbl (%eax),%edx
     ba7:	84 d2                	test   %dl,%dl
     ba9:	75 f2                	jne    b9d <strchr+0xc>
      return (char*)s;
  return 0;
     bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
     bb0:	5d                   	pop    %ebp
     bb1:	c3                   	ret    

00000bb2 <gets>:

char*
gets(char *buf, int max)
{
     bb2:	55                   	push   %ebp
     bb3:	89 e5                	mov    %esp,%ebp
     bb5:	57                   	push   %edi
     bb6:	56                   	push   %esi
     bb7:	53                   	push   %ebx
     bb8:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     bbb:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
     bc0:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
     bc3:	eb 36                	jmp    bfb <gets+0x49>
    cc = read(0, &c, 1);
     bc5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     bcc:	00 
     bcd:	89 7c 24 04          	mov    %edi,0x4(%esp)
     bd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     bd8:	e8 f8 00 00 00       	call   cd5 <read>
    if(cc < 1)
     bdd:	85 c0                	test   %eax,%eax
     bdf:	7e 26                	jle    c07 <gets+0x55>
      break;
    buf[i++] = c;
     be1:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
     be5:	8b 4d 08             	mov    0x8(%ebp),%ecx
     be8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
     beb:	3c 0a                	cmp    $0xa,%al
     bed:	0f 94 c2             	sete   %dl
     bf0:	3c 0d                	cmp    $0xd,%al
     bf2:	0f 94 c0             	sete   %al
    buf[i++] = c;
     bf5:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
     bf7:	08 c2                	or     %al,%dl
     bf9:	75 0a                	jne    c05 <gets+0x53>
  for(i=0; i+1 < max; ){
     bfb:	8d 73 01             	lea    0x1(%ebx),%esi
     bfe:	3b 75 0c             	cmp    0xc(%ebp),%esi
     c01:	7c c2                	jl     bc5 <gets+0x13>
     c03:	eb 02                	jmp    c07 <gets+0x55>
    buf[i++] = c;
     c05:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
     c07:	8b 45 08             	mov    0x8(%ebp),%eax
     c0a:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
     c0e:	83 c4 2c             	add    $0x2c,%esp
     c11:	5b                   	pop    %ebx
     c12:	5e                   	pop    %esi
     c13:	5f                   	pop    %edi
     c14:	5d                   	pop    %ebp
     c15:	c3                   	ret    

00000c16 <stat>:

int
stat(const char *n, struct stat *st)
{
     c16:	55                   	push   %ebp
     c17:	89 e5                	mov    %esp,%ebp
     c19:	56                   	push   %esi
     c1a:	53                   	push   %ebx
     c1b:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     c1e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     c25:	00 
     c26:	8b 45 08             	mov    0x8(%ebp),%eax
     c29:	89 04 24             	mov    %eax,(%esp)
     c2c:	e8 cc 00 00 00       	call   cfd <open>
     c31:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
     c33:	85 c0                	test   %eax,%eax
     c35:	78 1d                	js     c54 <stat+0x3e>
    return -1;
  r = fstat(fd, st);
     c37:	8b 45 0c             	mov    0xc(%ebp),%eax
     c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
     c3e:	89 1c 24             	mov    %ebx,(%esp)
     c41:	e8 cf 00 00 00       	call   d15 <fstat>
     c46:	89 c6                	mov    %eax,%esi
  close(fd);
     c48:	89 1c 24             	mov    %ebx,(%esp)
     c4b:	e8 95 00 00 00       	call   ce5 <close>
  return r;
     c50:	89 f0                	mov    %esi,%eax
     c52:	eb 05                	jmp    c59 <stat+0x43>
    return -1;
     c54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
     c59:	83 c4 10             	add    $0x10,%esp
     c5c:	5b                   	pop    %ebx
     c5d:	5e                   	pop    %esi
     c5e:	5d                   	pop    %ebp
     c5f:	c3                   	ret    

00000c60 <atoi>:

int
atoi(const char *s)
{
     c60:	55                   	push   %ebp
     c61:	89 e5                	mov    %esp,%ebp
     c63:	53                   	push   %ebx
     c64:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
     c67:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
     c6c:	eb 0f                	jmp    c7d <atoi+0x1d>
    n = n*10 + *s++ - '0';
     c6e:	8d 04 80             	lea    (%eax,%eax,4),%eax
     c71:	01 c0                	add    %eax,%eax
     c73:	83 c2 01             	add    $0x1,%edx
     c76:	0f be c9             	movsbl %cl,%ecx
     c79:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
     c7d:	0f b6 0a             	movzbl (%edx),%ecx
     c80:	8d 59 d0             	lea    -0x30(%ecx),%ebx
     c83:	80 fb 09             	cmp    $0x9,%bl
     c86:	76 e6                	jbe    c6e <atoi+0xe>
  return n;
}
     c88:	5b                   	pop    %ebx
     c89:	5d                   	pop    %ebp
     c8a:	c3                   	ret    

00000c8b <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     c8b:	55                   	push   %ebp
     c8c:	89 e5                	mov    %esp,%ebp
     c8e:	56                   	push   %esi
     c8f:	53                   	push   %ebx
     c90:	8b 45 08             	mov    0x8(%ebp),%eax
     c93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
     c96:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
     c99:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
     c9b:	eb 0d                	jmp    caa <memmove+0x1f>
    *dst++ = *src++;
     c9d:	0f b6 13             	movzbl (%ebx),%edx
     ca0:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
     ca2:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
     ca4:	8d 5b 01             	lea    0x1(%ebx),%ebx
     ca7:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
     caa:	8d 72 ff             	lea    -0x1(%edx),%esi
     cad:	85 d2                	test   %edx,%edx
     caf:	7f ec                	jg     c9d <memmove+0x12>
  return vdst;
}
     cb1:	5b                   	pop    %ebx
     cb2:	5e                   	pop    %esi
     cb3:	5d                   	pop    %ebp
     cb4:	c3                   	ret    

00000cb5 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     cb5:	b8 01 00 00 00       	mov    $0x1,%eax
     cba:	cd 40                	int    $0x40
     cbc:	c3                   	ret    

00000cbd <exit>:
SYSCALL(exit)
     cbd:	b8 02 00 00 00       	mov    $0x2,%eax
     cc2:	cd 40                	int    $0x40
     cc4:	c3                   	ret    

00000cc5 <wait>:
SYSCALL(wait)
     cc5:	b8 03 00 00 00       	mov    $0x3,%eax
     cca:	cd 40                	int    $0x40
     ccc:	c3                   	ret    

00000ccd <pipe>:
SYSCALL(pipe)
     ccd:	b8 04 00 00 00       	mov    $0x4,%eax
     cd2:	cd 40                	int    $0x40
     cd4:	c3                   	ret    

00000cd5 <read>:
SYSCALL(read)
     cd5:	b8 05 00 00 00       	mov    $0x5,%eax
     cda:	cd 40                	int    $0x40
     cdc:	c3                   	ret    

00000cdd <write>:
SYSCALL(write)
     cdd:	b8 10 00 00 00       	mov    $0x10,%eax
     ce2:	cd 40                	int    $0x40
     ce4:	c3                   	ret    

00000ce5 <close>:
SYSCALL(close)
     ce5:	b8 15 00 00 00       	mov    $0x15,%eax
     cea:	cd 40                	int    $0x40
     cec:	c3                   	ret    

00000ced <kill>:
SYSCALL(kill)
     ced:	b8 06 00 00 00       	mov    $0x6,%eax
     cf2:	cd 40                	int    $0x40
     cf4:	c3                   	ret    

00000cf5 <exec>:
SYSCALL(exec)
     cf5:	b8 07 00 00 00       	mov    $0x7,%eax
     cfa:	cd 40                	int    $0x40
     cfc:	c3                   	ret    

00000cfd <open>:
SYSCALL(open)
     cfd:	b8 0f 00 00 00       	mov    $0xf,%eax
     d02:	cd 40                	int    $0x40
     d04:	c3                   	ret    

00000d05 <mknod>:
SYSCALL(mknod)
     d05:	b8 11 00 00 00       	mov    $0x11,%eax
     d0a:	cd 40                	int    $0x40
     d0c:	c3                   	ret    

00000d0d <unlink>:
SYSCALL(unlink)
     d0d:	b8 12 00 00 00       	mov    $0x12,%eax
     d12:	cd 40                	int    $0x40
     d14:	c3                   	ret    

00000d15 <fstat>:
SYSCALL(fstat)
     d15:	b8 08 00 00 00       	mov    $0x8,%eax
     d1a:	cd 40                	int    $0x40
     d1c:	c3                   	ret    

00000d1d <link>:
SYSCALL(link)
     d1d:	b8 13 00 00 00       	mov    $0x13,%eax
     d22:	cd 40                	int    $0x40
     d24:	c3                   	ret    

00000d25 <mkdir>:
SYSCALL(mkdir)
     d25:	b8 14 00 00 00       	mov    $0x14,%eax
     d2a:	cd 40                	int    $0x40
     d2c:	c3                   	ret    

00000d2d <chdir>:
SYSCALL(chdir)
     d2d:	b8 09 00 00 00       	mov    $0x9,%eax
     d32:	cd 40                	int    $0x40
     d34:	c3                   	ret    

00000d35 <dup>:
SYSCALL(dup)
     d35:	b8 0a 00 00 00       	mov    $0xa,%eax
     d3a:	cd 40                	int    $0x40
     d3c:	c3                   	ret    

00000d3d <getpid>:
SYSCALL(getpid)
     d3d:	b8 0b 00 00 00       	mov    $0xb,%eax
     d42:	cd 40                	int    $0x40
     d44:	c3                   	ret    

00000d45 <sbrk>:
SYSCALL(sbrk)
     d45:	b8 0c 00 00 00       	mov    $0xc,%eax
     d4a:	cd 40                	int    $0x40
     d4c:	c3                   	ret    

00000d4d <sleep>:
SYSCALL(sleep)
     d4d:	b8 0d 00 00 00       	mov    $0xd,%eax
     d52:	cd 40                	int    $0x40
     d54:	c3                   	ret    

00000d55 <uptime>:
SYSCALL(uptime)
     d55:	b8 0e 00 00 00       	mov    $0xe,%eax
     d5a:	cd 40                	int    $0x40
     d5c:	c3                   	ret    

00000d5d <yield>:
SYSCALL(yield)
     d5d:	b8 16 00 00 00       	mov    $0x16,%eax
     d62:	cd 40                	int    $0x40
     d64:	c3                   	ret    

00000d65 <shutdown>:
SYSCALL(shutdown)
     d65:	b8 17 00 00 00       	mov    $0x17,%eax
     d6a:	cd 40                	int    $0x40
     d6c:	c3                   	ret    

00000d6d <writecount>:
SYSCALL(writecount)
     d6d:	b8 18 00 00 00       	mov    $0x18,%eax
     d72:	cd 40                	int    $0x40
     d74:	c3                   	ret    

00000d75 <setwritecount>:
SYSCALL(setwritecount)
     d75:	b8 19 00 00 00       	mov    $0x19,%eax
     d7a:	cd 40                	int    $0x40
     d7c:	c3                   	ret    

00000d7d <settickets>:
SYSCALL(settickets)
     d7d:	b8 1a 00 00 00       	mov    $0x1a,%eax
     d82:	cd 40                	int    $0x40
     d84:	c3                   	ret    

00000d85 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
     d85:	b8 1b 00 00 00       	mov    $0x1b,%eax
     d8a:	cd 40                	int    $0x40
     d8c:	c3                   	ret    

00000d8d <getpagetableentry>:
SYSCALL(getpagetableentry)
     d8d:	b8 1c 00 00 00       	mov    $0x1c,%eax
     d92:	cd 40                	int    $0x40
     d94:	c3                   	ret    

00000d95 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
     d95:	b8 1d 00 00 00       	mov    $0x1d,%eax
     d9a:	cd 40                	int    $0x40
     d9c:	c3                   	ret    

00000d9d <dumppagetable>:
     d9d:	b8 1e 00 00 00       	mov    $0x1e,%eax
     da2:	cd 40                	int    $0x40
     da4:	c3                   	ret    
     da5:	66 90                	xchg   %ax,%ax
     da7:	66 90                	xchg   %ax,%ax
     da9:	66 90                	xchg   %ax,%ax
     dab:	66 90                	xchg   %ax,%ax
     dad:	66 90                	xchg   %ax,%ax
     daf:	90                   	nop

00000db0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     db0:	55                   	push   %ebp
     db1:	89 e5                	mov    %esp,%ebp
     db3:	83 ec 18             	sub    $0x18,%esp
     db6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
     db9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     dc0:	00 
     dc1:	8d 55 f4             	lea    -0xc(%ebp),%edx
     dc4:	89 54 24 04          	mov    %edx,0x4(%esp)
     dc8:	89 04 24             	mov    %eax,(%esp)
     dcb:	e8 0d ff ff ff       	call   cdd <write>
}
     dd0:	c9                   	leave  
     dd1:	c3                   	ret    

00000dd2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     dd2:	55                   	push   %ebp
     dd3:	89 e5                	mov    %esp,%ebp
     dd5:	57                   	push   %edi
     dd6:	56                   	push   %esi
     dd7:	53                   	push   %ebx
     dd8:	83 ec 2c             	sub    $0x2c,%esp
     ddb:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     ddd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     de1:	0f 95 c3             	setne  %bl
     de4:	89 d0                	mov    %edx,%eax
     de6:	c1 e8 1f             	shr    $0x1f,%eax
     de9:	84 c3                	test   %al,%bl
     deb:	74 0b                	je     df8 <printint+0x26>
    neg = 1;
    x = -xx;
     ded:	f7 da                	neg    %edx
    neg = 1;
     def:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
     df6:	eb 07                	jmp    dff <printint+0x2d>
  neg = 0;
     df8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
     dff:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
     e04:	8d 5e 01             	lea    0x1(%esi),%ebx
     e07:	89 d0                	mov    %edx,%eax
     e09:	ba 00 00 00 00       	mov    $0x0,%edx
     e0e:	f7 f1                	div    %ecx
     e10:	0f b6 92 eb 11 00 00 	movzbl 0x11eb(%edx),%edx
     e17:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
     e1b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
     e1d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
     e1f:	85 c0                	test   %eax,%eax
     e21:	75 e1                	jne    e04 <printint+0x32>
  if(neg)
     e23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
     e27:	74 16                	je     e3f <printint+0x6d>
    buf[i++] = '-';
     e29:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
     e2e:	8d 5b 01             	lea    0x1(%ebx),%ebx
     e31:	eb 0c                	jmp    e3f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
     e33:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
     e38:	89 f8                	mov    %edi,%eax
     e3a:	e8 71 ff ff ff       	call   db0 <putc>
  while(--i >= 0)
     e3f:	83 eb 01             	sub    $0x1,%ebx
     e42:	79 ef                	jns    e33 <printint+0x61>
}
     e44:	83 c4 2c             	add    $0x2c,%esp
     e47:	5b                   	pop    %ebx
     e48:	5e                   	pop    %esi
     e49:	5f                   	pop    %edi
     e4a:	5d                   	pop    %ebp
     e4b:	c3                   	ret    

00000e4c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
     e4c:	55                   	push   %ebp
     e4d:	89 e5                	mov    %esp,%ebp
     e4f:	57                   	push   %edi
     e50:	56                   	push   %esi
     e51:	53                   	push   %ebx
     e52:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
     e55:	8d 45 10             	lea    0x10(%ebp),%eax
     e58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
     e5b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
     e60:	be 00 00 00 00       	mov    $0x0,%esi
     e65:	e9 23 01 00 00       	jmp    f8d <printf+0x141>
    c = fmt[i] & 0xff;
     e6a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
     e6d:	85 ff                	test   %edi,%edi
     e6f:	75 19                	jne    e8a <printf+0x3e>
      if(c == '%'){
     e71:	83 f8 25             	cmp    $0x25,%eax
     e74:	0f 84 0b 01 00 00    	je     f85 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
     e7a:	0f be d3             	movsbl %bl,%edx
     e7d:	8b 45 08             	mov    0x8(%ebp),%eax
     e80:	e8 2b ff ff ff       	call   db0 <putc>
     e85:	e9 00 01 00 00       	jmp    f8a <printf+0x13e>
      }
    } else if(state == '%'){
     e8a:	83 ff 25             	cmp    $0x25,%edi
     e8d:	0f 85 f7 00 00 00    	jne    f8a <printf+0x13e>
      if(c == 'd'){
     e93:	83 f8 64             	cmp    $0x64,%eax
     e96:	75 26                	jne    ebe <printf+0x72>
        printint(fd, *ap, 10, 1);
     e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     e9b:	8b 10                	mov    (%eax),%edx
     e9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ea4:	b9 0a 00 00 00       	mov    $0xa,%ecx
     ea9:	8b 45 08             	mov    0x8(%ebp),%eax
     eac:	e8 21 ff ff ff       	call   dd2 <printint>
        ap++;
     eb1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
     eb5:	66 bf 00 00          	mov    $0x0,%di
     eb9:	e9 cc 00 00 00       	jmp    f8a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
     ebe:	83 f8 78             	cmp    $0x78,%eax
     ec1:	0f 94 c1             	sete   %cl
     ec4:	83 f8 70             	cmp    $0x70,%eax
     ec7:	0f 94 c2             	sete   %dl
     eca:	08 d1                	or     %dl,%cl
     ecc:	74 27                	je     ef5 <printf+0xa9>
        printint(fd, *ap, 16, 0);
     ece:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ed1:	8b 10                	mov    (%eax),%edx
     ed3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     eda:	b9 10 00 00 00       	mov    $0x10,%ecx
     edf:	8b 45 08             	mov    0x8(%ebp),%eax
     ee2:	e8 eb fe ff ff       	call   dd2 <printint>
        ap++;
     ee7:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
     eeb:	bf 00 00 00 00       	mov    $0x0,%edi
     ef0:	e9 95 00 00 00       	jmp    f8a <printf+0x13e>
      } else if(c == 's'){
     ef5:	83 f8 73             	cmp    $0x73,%eax
     ef8:	75 37                	jne    f31 <printf+0xe5>
        s = (char*)*ap;
     efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     efd:	8b 18                	mov    (%eax),%ebx
        ap++;
     eff:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
     f03:	85 db                	test   %ebx,%ebx
     f05:	75 19                	jne    f20 <printf+0xd4>
          s = "(null)";
     f07:	bb e4 11 00 00       	mov    $0x11e4,%ebx
     f0c:	8b 7d 08             	mov    0x8(%ebp),%edi
     f0f:	eb 12                	jmp    f23 <printf+0xd7>
          putc(fd, *s);
     f11:	0f be d2             	movsbl %dl,%edx
     f14:	89 f8                	mov    %edi,%eax
     f16:	e8 95 fe ff ff       	call   db0 <putc>
          s++;
     f1b:	83 c3 01             	add    $0x1,%ebx
     f1e:	eb 03                	jmp    f23 <printf+0xd7>
     f20:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
     f23:	0f b6 13             	movzbl (%ebx),%edx
     f26:	84 d2                	test   %dl,%dl
     f28:	75 e7                	jne    f11 <printf+0xc5>
      state = 0;
     f2a:	bf 00 00 00 00       	mov    $0x0,%edi
     f2f:	eb 59                	jmp    f8a <printf+0x13e>
      } else if(c == 'c'){
     f31:	83 f8 63             	cmp    $0x63,%eax
     f34:	75 19                	jne    f4f <printf+0x103>
        putc(fd, *ap);
     f36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     f39:	0f be 10             	movsbl (%eax),%edx
     f3c:	8b 45 08             	mov    0x8(%ebp),%eax
     f3f:	e8 6c fe ff ff       	call   db0 <putc>
        ap++;
     f44:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
     f48:	bf 00 00 00 00       	mov    $0x0,%edi
     f4d:	eb 3b                	jmp    f8a <printf+0x13e>
      } else if(c == '%'){
     f4f:	83 f8 25             	cmp    $0x25,%eax
     f52:	75 12                	jne    f66 <printf+0x11a>
        putc(fd, c);
     f54:	0f be d3             	movsbl %bl,%edx
     f57:	8b 45 08             	mov    0x8(%ebp),%eax
     f5a:	e8 51 fe ff ff       	call   db0 <putc>
      state = 0;
     f5f:	bf 00 00 00 00       	mov    $0x0,%edi
     f64:	eb 24                	jmp    f8a <printf+0x13e>
        putc(fd, '%');
     f66:	ba 25 00 00 00       	mov    $0x25,%edx
     f6b:	8b 45 08             	mov    0x8(%ebp),%eax
     f6e:	e8 3d fe ff ff       	call   db0 <putc>
        putc(fd, c);
     f73:	0f be d3             	movsbl %bl,%edx
     f76:	8b 45 08             	mov    0x8(%ebp),%eax
     f79:	e8 32 fe ff ff       	call   db0 <putc>
      state = 0;
     f7e:	bf 00 00 00 00       	mov    $0x0,%edi
     f83:	eb 05                	jmp    f8a <printf+0x13e>
        state = '%';
     f85:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
     f8a:	83 c6 01             	add    $0x1,%esi
     f8d:	89 f0                	mov    %esi,%eax
     f8f:	03 45 0c             	add    0xc(%ebp),%eax
     f92:	0f b6 18             	movzbl (%eax),%ebx
     f95:	84 db                	test   %bl,%bl
     f97:	0f 85 cd fe ff ff    	jne    e6a <printf+0x1e>
    }
  }
}
     f9d:	83 c4 1c             	add    $0x1c,%esp
     fa0:	5b                   	pop    %ebx
     fa1:	5e                   	pop    %esi
     fa2:	5f                   	pop    %edi
     fa3:	5d                   	pop    %ebp
     fa4:	c3                   	ret    
     fa5:	66 90                	xchg   %ax,%ax
     fa7:	66 90                	xchg   %ax,%ax
     fa9:	66 90                	xchg   %ax,%ax
     fab:	66 90                	xchg   %ax,%ax
     fad:	66 90                	xchg   %ax,%ax
     faf:	90                   	nop

00000fb0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     fb0:	55                   	push   %ebp
     fb1:	89 e5                	mov    %esp,%ebp
     fb3:	57                   	push   %edi
     fb4:	56                   	push   %esi
     fb5:	53                   	push   %ebx
     fb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
     fb9:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fbc:	a1 e8 12 00 00       	mov    0x12e8,%eax
     fc1:	eb 15                	jmp    fd8 <free+0x28>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     fc3:	8b 10                	mov    (%eax),%edx
     fc5:	39 c2                	cmp    %eax,%edx
     fc7:	77 0d                	ja     fd6 <free+0x26>
     fc9:	39 c1                	cmp    %eax,%ecx
     fcb:	77 15                	ja     fe2 <free+0x32>
     fcd:	39 d1                	cmp    %edx,%ecx
     fcf:	90                   	nop
     fd0:	72 10                	jb     fe2 <free+0x32>
     fd2:	89 d0                	mov    %edx,%eax
     fd4:	eb 02                	jmp    fd8 <free+0x28>
     fd6:	89 d0                	mov    %edx,%eax
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fd8:	39 c1                	cmp    %eax,%ecx
     fda:	76 e7                	jbe    fc3 <free+0x13>
     fdc:	39 08                	cmp    %ecx,(%eax)
     fde:	66 90                	xchg   %ax,%ax
     fe0:	76 e1                	jbe    fc3 <free+0x13>
      break;
  if(bp + bp->s.size == p->s.ptr){
     fe2:	8b 73 fc             	mov    -0x4(%ebx),%esi
     fe5:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
     fe8:	8b 10                	mov    (%eax),%edx
     fea:	39 d7                	cmp    %edx,%edi
     fec:	75 0f                	jne    ffd <free+0x4d>
    bp->s.size += p->s.ptr->s.size;
     fee:	03 72 04             	add    0x4(%edx),%esi
     ff1:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
     ff4:	8b 10                	mov    (%eax),%edx
     ff6:	8b 12                	mov    (%edx),%edx
     ff8:	89 53 f8             	mov    %edx,-0x8(%ebx)
     ffb:	eb 03                	jmp    1000 <free+0x50>
  } else
    bp->s.ptr = p->s.ptr;
     ffd:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
    1000:	8b 50 04             	mov    0x4(%eax),%edx
    1003:	8d 34 d0             	lea    (%eax,%edx,8),%esi
    1006:	39 ce                	cmp    %ecx,%esi
    1008:	75 0d                	jne    1017 <free+0x67>
    p->s.size += bp->s.size;
    100a:	03 53 fc             	add    -0x4(%ebx),%edx
    100d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1010:	8b 53 f8             	mov    -0x8(%ebx),%edx
    1013:	89 10                	mov    %edx,(%eax)
    1015:	eb 02                	jmp    1019 <free+0x69>
  } else
    p->s.ptr = bp;
    1017:	89 08                	mov    %ecx,(%eax)
  freep = p;
    1019:	a3 e8 12 00 00       	mov    %eax,0x12e8
}
    101e:	5b                   	pop    %ebx
    101f:	5e                   	pop    %esi
    1020:	5f                   	pop    %edi
    1021:	5d                   	pop    %ebp
    1022:	c3                   	ret    

00001023 <morecore>:

static Header*
morecore(uint nu)
{
    1023:	55                   	push   %ebp
    1024:	89 e5                	mov    %esp,%ebp
    1026:	53                   	push   %ebx
    1027:	83 ec 14             	sub    $0x14,%esp
    102a:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
    102c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
    1031:	77 05                	ja     1038 <morecore+0x15>
    nu = 4096;
    1033:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
    1038:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
    103f:	89 04 24             	mov    %eax,(%esp)
    1042:	e8 fe fc ff ff       	call   d45 <sbrk>
  if(p == (char*)-1)
    1047:	83 f8 ff             	cmp    $0xffffffff,%eax
    104a:	74 15                	je     1061 <morecore+0x3e>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
    104c:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
    104f:	83 c0 08             	add    $0x8,%eax
    1052:	89 04 24             	mov    %eax,(%esp)
    1055:	e8 56 ff ff ff       	call   fb0 <free>
  return freep;
    105a:	a1 e8 12 00 00       	mov    0x12e8,%eax
    105f:	eb 05                	jmp    1066 <morecore+0x43>
    return 0;
    1061:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1066:	83 c4 14             	add    $0x14,%esp
    1069:	5b                   	pop    %ebx
    106a:	5d                   	pop    %ebp
    106b:	c3                   	ret    

0000106c <malloc>:

void*
malloc(uint nbytes)
{
    106c:	55                   	push   %ebp
    106d:	89 e5                	mov    %esp,%ebp
    106f:	53                   	push   %ebx
    1070:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1073:	8b 45 08             	mov    0x8(%ebp),%eax
    1076:	8d 58 07             	lea    0x7(%eax),%ebx
    1079:	c1 eb 03             	shr    $0x3,%ebx
    107c:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
    107f:	8b 0d e8 12 00 00    	mov    0x12e8,%ecx
    1085:	85 c9                	test   %ecx,%ecx
    1087:	75 23                	jne    10ac <malloc+0x40>
    base.s.ptr = freep = prevp = &base;
    1089:	c7 05 e8 12 00 00 ec 	movl   $0x12ec,0x12e8
    1090:	12 00 00 
    1093:	c7 05 ec 12 00 00 ec 	movl   $0x12ec,0x12ec
    109a:	12 00 00 
    base.s.size = 0;
    109d:	c7 05 f0 12 00 00 00 	movl   $0x0,0x12f0
    10a4:	00 00 00 
    base.s.ptr = freep = prevp = &base;
    10a7:	b9 ec 12 00 00       	mov    $0x12ec,%ecx
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10ac:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
    10ae:	8b 50 04             	mov    0x4(%eax),%edx
    10b1:	39 da                	cmp    %ebx,%edx
    10b3:	72 20                	jb     10d5 <malloc+0x69>
      if(p->s.size == nunits)
    10b5:	39 d3                	cmp    %edx,%ebx
    10b7:	75 06                	jne    10bf <malloc+0x53>
        prevp->s.ptr = p->s.ptr;
    10b9:	8b 10                	mov    (%eax),%edx
    10bb:	89 11                	mov    %edx,(%ecx)
    10bd:	eb 0b                	jmp    10ca <malloc+0x5e>
      else {
        p->s.size -= nunits;
    10bf:	29 da                	sub    %ebx,%edx
    10c1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    10c4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
    10c7:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
    10ca:	89 0d e8 12 00 00    	mov    %ecx,0x12e8
      return (void*)(p + 1);
    10d0:	83 c0 08             	add    $0x8,%eax
    10d3:	eb 1e                	jmp    10f3 <malloc+0x87>
    }
    if(p == freep)
    10d5:	3b 05 e8 12 00 00    	cmp    0x12e8,%eax
    10db:	75 0b                	jne    10e8 <malloc+0x7c>
      if((p = morecore(nunits)) == 0)
    10dd:	89 d8                	mov    %ebx,%eax
    10df:	e8 3f ff ff ff       	call   1023 <morecore>
    10e4:	85 c0                	test   %eax,%eax
    10e6:	74 06                	je     10ee <malloc+0x82>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10e8:	89 c1                	mov    %eax,%ecx
    10ea:	8b 00                	mov    (%eax),%eax
        return 0;
  }
    10ec:	eb c0                	jmp    10ae <malloc+0x42>
        return 0;
    10ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
    10f3:	83 c4 04             	add    $0x4,%esp
    10f6:	5b                   	pop    %ebx
    10f7:	5d                   	pop    %ebp
    10f8:	c3                   	ret    
