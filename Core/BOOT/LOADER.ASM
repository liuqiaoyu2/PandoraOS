%include "SYSINF.INC"

org LODR_ORG
bits 16

Start:
mov ax,cs
mov ds,ax
mov ss,ax
mov sp,LODR_ORG
cld
mov si,szHello
call PrintText

cli
hlt



;打印文本的函数
;参数：
;	si=文本
;返回：
;	dx=0x000F
;	ax=0x0E00
PrintText:
	mov dx,0x000F	;颜色：白色，页：0
	mov ah,0x0E		;功能：打印单字
.ShowChar:
	lodsb			;读取一个字符
	or al,al		;判断是否为0
	jz .ShowOver	;是的话就返回
	int 0x10		;否则就打印
	jmp .ShowChar	;继续打印下一个字符
.ShowOver:
	ret				;返回

szHello db "Hello World!",0xD,0xA,0
