;输出一个TAB的函数
;返回：
	;ax=0x0E09
ShowTAB:
	mov ax,0x0E09	;输出一个TAB
	int 0x10
	ret