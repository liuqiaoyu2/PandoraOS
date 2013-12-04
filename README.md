PandoraOS(潘多拉操作系统)
=========

A Operating System based on x86

[我们的论坛](http://www.0xaa55bbs.com)

内核的代码和说明都在Core文件夹里面。  
无视SETENV.BAT。这个批命令用于设置编译的环境变量。  
Core\INCLUDE文件夹是包含的头文件，INC后缀的是汇编NASM的包含文件，有一些定义。  
Core\PROC16文件夹是一些16位的小程序的实现部分。用%include包含里面的文件可以获取相应的功能。  
Core\BOOT文件夹里面的文件是引导部分的程序，目前C的部分还没有弄出来。
