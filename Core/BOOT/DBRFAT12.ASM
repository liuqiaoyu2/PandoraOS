%include "SYSINF.INC"

org DBR_NEWPOS
bits 16

%include "BPBFLOPPY.INC"
Start:

;�Ȱѱ����0:BOOT_ORGת����0:DBR_NEWPOS
xor ax,ax						;���������
mov es,ax
mov ss,ax
mov ds,ax
mov si,BOOT_ORG					;Դ��������ʼ
mov sp,si						;ͬʱ���úö�ջ
mov di,DBR_NEWPOS				;Ŀ�꣺DBR���¼�
mov cx,DBR_SIZE					;�ֽ�����DBR�ĳߴ�
rep movsb						;ת�Ƶ�Ŀ��
jmp 0x0000:DBR_Continue

DBR_Continue:					;�˴���DBR_Continue��ʼ
.Read:							;��ȡ����FAT��
	mov di,[BPB.wSecsPerFAT]	;��ȡÿFAT������
	mov bx,FLOPPY_FAT_BUFFER	;��ȡ��FLOPPY_FAT_BUFFER��
	mov bp,[BPB.wReservedSecs]	;��λ��ʼ����
.ReadAllFATItems:
	mov ax,bp					;����LBA
	call ReadSector
	inc bp						;����LBA
	add bx,[BPB.wBytesPerSec]	;���û�����ָ�ָ��
	dec di						;������1������cx����ΪReadSector�ƻ�cx��
	jnz .ReadAllFATItems

GetDataStartLBA:				;�����������Ŀ�ʼλ��
	add bp,[BPB.wSecsPerFAT]	;bpָ���Ŀ¼����ʼλ��
	mov ax,SIZE_DIRENTRY		;�����Ŀ¼���ܴ�С
	mov cx,[BPB.wMaxRootItems]	;����CXΪ����Ŀ¼��Ϊ�������ļ���׼��
	mul cx						;��Ŀ¼��������ÿ��Ŀ¼���С
	div word[BPB.wBytesPerSec]	;�ٳ���ÿ�����ֽ�����Ϊ��Ŀ¼��ռ��������
	or dx,dx					;�жϳ��������Ƿ�Ϊ��
	jz .NoTail					;���ǵĻ�����
	inc ax						;�ǵĻ��жϸ�Ŀ¼��Ҫ��ռһ������
.NoTail:
	add ax,bp					;���ϸ�Ŀ¼���Ŀ�ʼλ��
	mov [g_wDataStartLBA],ax	;�����������Ŀ�ʼλ����
	
FindLoader:
	mov ax,bp					;��ȡ��Ŀ¼��
	mov bx,FLOPPY_DIR_BUFFER	;��ȡ����һ�黺����
	call ReadSector				;������
	
	mov si,bx					;׼���������ļ�
	mov cx,0x10					;һ��������0x10������
	call FindFile				;�������ļ�
	jc FoundFile				;�ҵ�����ת
	
	inc bp						;û�ҵ��������ȡ��һ������
	loop FindLoader				;ѭ��Ѱ��
	jmp LoadFailed				;�������и�Ŀ¼����û���ҵ����϶�����ʧ�ܡ�
	
FoundFile:						;�ҵ����ļ�
	mov bp,[si+FAT_DIRITEM.wFirstClusLO];��ȡ�ļ��״أ�FAT12�Ĵغ�ֻ��12λ��
	cmp bp,FAT12_MAXVALIDCLUS	;�غ��Ƿ�������Ϸ��غ�
	ja LoadFailed				;�ǣ�ʧ���˳�
	cmp bp,FAT12_MINVALIDCLUS	;�غ��Ƿ������С�Ϸ��غ�
	jb LoadFailed				;�ǣ�ʧ���˳�
	mov bx,LODR_ORG				;��ȡĿ��ΪLOADER.SYS����ʼλ��
ReadClusterChainToLoadLoader:	;��ʼ��ȡ����
	mov ax,bp					;���ôغ�
	call ReadCluster			;��ȡ��
	
	movzx cx,byte[BPB.bSecsPerCluster];׼���ƶ�������ָ��
.LoopAddOffs:
	add bx,[BPB.wBytesPerSec]	;�ƶ�������ָ��
	loop .LoopAddOffs			;����ÿ���������ƶ�
	
	mov si,bp					;��ȡ��һ������
	shr si,1
	add si,bp					;FAT12�Ĵغ������ڴ�λ�õļ���
	mov ax,[FLOPPY_FAT_BUFFER+si]
	test bp,1
	jz .FAT12Low
	shr ax,4
.FAT12Low:
	and ax,0xFFF				;��ȡ�ôغ�->ax
	cmp ax,FAT12_MAXVALIDCLUS	;�غ��Ƿ�������Ϸ��غ�
	ja LoadOK					;�ǣ��������
	cmp ax,FAT12_MINVALIDCLUS	;�غ��Ƿ������С�Ϸ��غ�
	jb LoadFailed				;�ǣ�ʧ���˳�
	mov bp,ax					;���ô����Ĵغ�Ϊ��һ��Ҫ��ȡ�Ĵ�
	jmp ReadClusterChainToLoadLoader;�����������
	
LoadOK:							;������ɣ�׼����ת
	xor ax,ax					;Ŀ���Ϊ0
	mov es,ax					;���������
	mov ss,ax
	mov ds,ax
	mov sp,LODR_ORG				;���úö�ջ
	jmp 0x0000:LODR_ORG			;��ת��LOADER.SYS��
	
LoadFailed:						;�������ʧ��
	mov si,.ErrText				;������ʾ�ı�
	mov cx,.ErrTextLen			;��������
	jmp ErrAndHlt				;��ӡ�ı�Ȼ�󵱻�
	.ErrText		db	"Could not found LOADER.SYS. System halted.";�Ҳ���LOADER.SYS��ϵͳ�Ѿ�����
	.ErrTextLen		equ	$-.ErrText
	
;��Ŀ¼�����ļ��ĺ���
	;si=�ļ�Ŀ¼��
	;cx=�ļ�Ŀ¼����
;���أ�
	;di=g_strLoaderFileNameĩβ
;����ҵ���
	;cf=1
	;cx=ʣ���ļ�����
	;si->�ļ�Ŀ¼����Ӧ����
;���û�ҵ���
	;cf=0
	;cx=0
	;si->�ļ�Ŀ¼��ĩβ
FindFile:
	push cx						;����cx����ѭ�������ļ�
		mov cx,SIZE_FILENAME	;׼�������ַ����Ƚ�
		mov di,g_strLoaderFileName
		repz cmpsb				;�Ƚ��ַ���
		jcxz .FoundFile			;����ַ���ƥ�䣬�϶��ҵ��ļ�
		add si,SIZE_DIRENTRY-SIZE_FILENAME
		add si,cx				;�����޸�ָ��ָ����һ���ļ�Ŀ¼��
	pop cx						;�ָ�cx����ѭ��
	loop FindFile				;ѭ�������ļ�
	clc							;���û�ҵ���CF=0
	ret							;����
.FoundFile:						;����ҵ�
	pop cx						;�ָ���ջƽ�⣨��������ʱ��cx���ڶ�ջ��
	sub si,SIZE_FILENAME		;�޸�ָ��ָ��ǰ�ļ�Ŀ¼��
	stc							;�ҵ��ı�־��CF=1
	ret							;����

;��ȡ���̵ĺ���
	;ax=LBA
	;bx=������
;���أ�
	;si=ʣ�����Դ���
	;ax=int 0x13���
	;cx=����:������
	;dx=��ͷ:������
ReadSector:
	mov si,3					;��������
	xor dx,dx
	div word[BPB.wSecsPerCylinder]
	inc dx						;dx=����
	mov cl,dl
	xor dx,dx
	div word[BPB.wHeads]		;ax=���棬dx=��ͷ
	mov ch,al
	mov dh,dl
	mov dl,0					;������0
.Retry:
	mov ax,0x0201				;��ȡһ������
	int 0x13					;��ȡ
	jnc .ReadOK					;��ȡ�ɹ�����ת
	dec si
	jnz .Retry
	mov si,.ReadErr				;��ȡʧ�ܣ������˳�
	mov cx,.ReadErrLen
	jmp ErrAndHlt
.ReadErr		db	"Unable to read from floppy. System halted."
.ReadErrLen		equ	$-.ReadErr
.ReadOK:						;��ȡOK��
	ret


;��ȡ�صĺ���
	;ax=�غ�
	;bx=������
;���أ�
	;si=ʣ�����Դ���
	;ax=int 0x13���
	;cx=0
	;dx=��ͷ:������
ReadCluster:
	movzx cx,byte[BPB.bSecsPerCluster]
	sub ax,2					;�غŜpȥ2
	mul cx						;�ٳ�ÿ��������
	add ax,[g_wDataStartLBA]	;�ټ�������������ʼ����
.ReadNextSec:					;Ϊ�������������ÿ����������ȡ��
	push cx
	push ax
	call ReadSector
	pop ax
	pop cx
	inc ax
	add bx,[BPB.wBytesPerSec]
	loop .ReadNextSec
	ret
	
;��ʾ����Ȼ�󵱻��ĺ���
	;si=������ʾ�ı�
	;cx=�ı�����
;����
	;����
ErrAndHlt:
	mov bx,0x07					;��ɫ����ͨ��ɫ
	mov ah,0x0E					;���ܣ���ӡ����
	.LoopShowText:
	lodsb
	int 0x10					;��ӡ�ı�
	loop .LoopShowText
	cli							;���ж�
	hlt							;����

g_strLoaderFileName	db LODR_FILENAME
g_wDataStartLBA		dw (FLOPPY_RESV_SECS+FLOPPY_FAT_COUNT*FLOPPY_FAT_SECS+FLOPPY_ROOT_ITEMS*SIZE_DIRENTRY/FLOPPY_SEC_LEN)

%xdefine DBR_FILL_SIZE (DBR_SIZE-($-$$)-2)
times (DBR_FILL_SIZE>>1) db 0xFA,0xF4
%if DBR_FILL_SIZE&1
hlt
%endif
%undef DBR_FILL_SIZE
dw	FLAG_BOOTALBE
DBREnd:
