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



;��ӡ�ı��ĺ���
;������
;	si=�ı�
;���أ�
;	dx=0x000F
;	ax=0x0E00
PrintText:
	mov dx,0x000F	;��ɫ����ɫ��ҳ��0
	mov ah,0x0E		;���ܣ���ӡ����
.ShowChar:
	lodsb			;��ȡһ���ַ�
	or al,al		;�ж��Ƿ�Ϊ0
	jz .ShowOver	;�ǵĻ��ͷ���
	int 0x10		;����ʹ�ӡ
	jmp .ShowChar	;������ӡ��һ���ַ�
.ShowOver:
	ret				;����

szHello db "Hello World!",0xD,0xA,0