;��ʾ���ֵĺ���
;���룺
	;ax=����
;���أ�
	;ax�ƻ�(ah=0x0e,al=���һ�������ַ���ASCII��)
	;cx=0
	;dx=7
ShowDec:
	xor cx,cx		;cx����������
.PushNums:			;�Ȱ�ÿ����λ��ѹ���ջ
	xor dx,dx		;���������16λ
	div word[cs:.10];ax����10
	push dx			;ѹ������
	inc cx			;λ����1
	or ax,ax		;�ж��Ƿ����
	jnz .PushNums	;���ǵĻ�������
	mov dx,7		;ͼ��ģʽ����ɫ
.ShowNums:			;�ٰѶ�ջ�е���λȡ��
	pop ax			;ȡ������
	add al,'0'		;����ASCII��
	mov ah,0x0E		;��ʾ�ı��Ĺ���
	int 0x10		;��ʾ�ı�
	loop .ShowNums	;ѭ����ʾ�����ı�
	ret				;����
.10	dw	10			;���������ĳ���