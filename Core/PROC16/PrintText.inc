;��ӡ�ı��ĺ���
;������
	;si=�ı�
;���أ�
	;si=�ı�ĩβ
	;dx=7
	;ax=0x0E00
PrintText:
	mov ah,0x0E		;��ӡ�ı��Ĺ���
	mov dx,7		;ͼ��ģʽ��ɫ
.ShowChar:			;ѭ����ʾ�ַ�
	lodsb			;�����ַ�
	or al,al		;�ж��Ƿ��ַ�β
	jz .EndOfString	;�ַ�β������
	int 0x10		;������ʾ�ַ�
	jmp .ShowChar	;ѭ����ʾ�ַ�
.EndOfString:		;ѭ���˳�
	ret				;����