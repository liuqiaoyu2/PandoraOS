;��ʾ16�������ֵĺ���
;���룺
	;ax=����
;���أ�
	;ax=0
	;cx=0
	;dx=7
ShowHex:
	mov cx,4			;4����λ
	mov dx,7			;ͼ��ģʽ�µ���ɫ
.ShowNum:				;ѭ����ʾ��λ
	push ax				;����AX
	shr ax,12			;ȡ���λ
	cmp al,10			;�ж��Ƿ�С��10
	jb .LessThan10		;�ǵĻ�����
	add al,'A'-'0'-10	;����ʹ����ʾΪA-F
.LessThan10:			;С��10
	add al,'0'			;��Ϊ0-9
	mov ah,0x0E			;��ʾ�ַ��Ĺ���
	int 0x10			;�ж�
	pop ax				;ȡ��AX
	shl ax,4			;������һ����λ
	loop .ShowNum		;ѭ����ʾ��һ����λ
	ret					;����