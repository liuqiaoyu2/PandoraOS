;���һ�����з��ĺ���
;���أ�
	;ax=0x0E0A
ShowCrLf:
	mov ax,0x0E0D	;���һ��Cr
	int 0x10
	mov al,0x0A		;���һ��Lf
	int 0x10
	ret