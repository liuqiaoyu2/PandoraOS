%include "SYSINF.INC"

org DBR_NEWPOS
bits 16

CPU 586

%include "BPBFAT.INC"
Start:

;��ʱ�����飬λ����������ͷ��
struc Temp
	.Reserved			resb	DBR_NEWPOS
	.qwFATStart			resq	1	;FAT����ʼLBA
	.qwRootEntryStart	resq	1	;��Ŀ¼����ʼLBA
	.qwDataStart		resq	1	;��������ʼLBA
	.wLoaderOffset		resw	1	;��������ƫ��λ��
	.wLoaderSegment		resw	1	;���������
	.wBytesPerCluster	resw	1	;ÿ���ֽ���
	.ReadPacket:
	.cbSizeOfPacket		resb	1	;���Ĵ�С
	.bReserved			resb	1	;����1�ֽ�
	.wBlocks			resw	1	;��ȡ�������
	.wBufferOffset		resw	1	;������ƫ��
	.wBufferSegment		resw	1	;��������
	.qwLBA				resq	1	;64λ����LBA
	.EndOfPacket:
endstruc

%define	MOVER_SIZE		(DBR_Continue-$$)

;�Ȱѱ����0:BOOT_ORGת����0:DBR_NEWPOS
xor ax,ax							;���������
mov es,ax
mov ss,ax
mov ds,ax
mov sp,BOOT_ORG						;���úö�ջ
mov si,BOOT_ORG+MOVER_SIZE			;Դ��������ʼ
mov di,DBR_NEWPOS+MOVER_SIZE		;Ŀ�꣺DBR���¼�
mov cx,DBR_SIZE-MOVER_SIZE			;�ֽ�����DBR�ĳߴ�
rep movsb							;ת�Ƶ�Ŀ��
jmp 0x0000:DBR_Continue

DBR_Continue:						;�˴���DBR_Continue��ʼ
.Init:								;��Ҫ�ĳ�ʼ��
	mov ah,0x41						;�ж��Ƿ�֧����չ��Ӳ�̹���
	mov dl,[BPB.bDrivers]
	mov bx,0x55AA
	int 0x13
	jc INT13ExNotOK
	cmp bx,0xAA55
	jnz INT13ExNotOK

	xor edx,edx						;edxΪLBA��32λ
	mov ebp,edx						;ebp���㣬�������������0
	mov eax,[BPB.dwHiddenSecs]		;eaxΪLBA��32λ
	movzx ecx,word[BPB.wReservedSecs];ecx��λ���㣬��λ�Ǳ�����������DBR�ڶ������ڱ���������
	mov [Temp.qwLBA],eax			;׼����ȡ�ڶ�����
	mov [Temp.qwLBA+4],edx
	push ax							;������Ѿ����õļĴ���
	push cx
	push dx
	mov word[Temp.wBlocks],1
	mov dword[Temp.wBufferOffset],SecondPart
	
.LookForNextPart:					;��ʼ�ҵڶ�����
	inc dword[Temp.qwLBA]			;��DBR��λ��+1��ʼ��DBR�ڶ�������
	jnz .ReadNextPartSec
	inc dword[Temp.qwLBA+4]			;���ﴦ��LBA�ĸ�λ
.ReadNextPartSec:
	call ReadSector					;��ȡ����
	cmp word[SecondPart.BootFlag],FLAG_BOOTALBE;�ж��Ƿ�Ϊ���õĵڶ�����
	jz .SecPartLoaded				;�ǵĻ�������������
	loop .LookForNextPart			;����ѭ��������һ������
	
	mov si,.NoNextPartText			;���е�������ζ��û�ҵ��Ϸ��ĵڶ�������
	mov cx,.NoNextPartTextLen
	jmp ErrAndReboot
.NoNextPartText		db	"Part of the boot sectors is missing."
.NoNextPartTextLen		equ	$-.NoNextPartText
	
.SecPartLoaded:						;�ҵ��ڶ������������˴���������
	pop dx
	pop cx
	pop ax							;�ָ�֮ǰ���õļĴ���
	add eax,ecx						;����ǰ�������ӱ���������
	adc edx,ebp
	mov [Temp.qwFATStart],eax		;eax:edxΪ64λ��FAT��LBA
	mov [Temp.qwFATStart+4],edx
	movzx cx,byte[BPB.bNbFATs]		;FAT��������
	movzx ebx,word[BPB.wSecsPerFAT]	;׼����������FAT��
.AddFatSecs:
	add eax,ebx
	adc edx,ebp
	loop .AddFatSecs				;����FAT��
	mov [Temp.qwRootEntryStart],eax	;eax:edxΪ64λ�ĸ�Ŀ¼��LBA
	mov [Temp.qwRootEntryStart+4],edx
	mov [Temp.qwLBA],eax			;������Ҫ�Ӹ�Ŀ¼����ȡ��Ŀ¼�����Ԥ���趨��ȡLBA
	mov [Temp.qwLBA+4],edx
	mov bx,[BPB.wMaxRootItems]		;��Ŀ¼��ռ�õ����������Ŀ¼����������йء�
	shr bx,4						;ÿ����Ŀ¼����ռ��0x20�ֽڣ�ÿ������0x200�ֽڣ���ÿ��������0x10����Ŀ¼��
	test byte[BPB.wMaxRootItems],0x0F;������������û�ж���ĸ�Ŀ¼��
	jz .GotDataLBA
	inc bx							;�еĻ���Ŀ¼������+1
.GotDataLBA:						;bx=��Ŀ¼��ռ��������
	add eax,ebx						;������Ŀ¼��
	adc edx,ebp
	mov [Temp.qwDataStart],eax		;eax:edxΪ64λ��������LBA
	mov [Temp.qwDataStart+4],edx

.FindFile:							;�ղ��Ѿ����ú��˶�ȡLBA����ʼ���ļ�
	mov dword[Temp.wBufferOffset],HDD_DIR_BUFFER
	mov word[Temp.wBlocks],1		;ֻ��ȡһ������
	call ReadSector					;��ȡ��Ŀ¼����

	mov si,HDD_DIR_BUFFER			;��ȡ������Ӷ�ȡ�ĵط��������ļ���
	mov cx,0x10
	call FindFile					;���ļ�
	jc SecondPart.FoundBootFile		;�ҵ��ͼ�������
	inc dword[Temp.qwLBA]			;û�ҵ���LBA��������ȡ��һ����Ŀ¼����
	jnz .IncreasedLBA
	inc dword[Temp.qwLBA+4]			;���ǵ���λ�Ľ�λ
.IncreasedLBA:
	dec bx							;������һ������ļ�����ʣ��ĸ�Ŀ¼����������
	jnz .FindFile					;������Ϊ���������ȡ��Ŀ¼�����ļ�
	call ReadErr					;����Ϊ�㻹û�ҵ��ļ�����ʾ����



	
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
	;��дReadPacket
;���أ�
	;ax=���н��
	;dl=������
	;si=ReadPacket��ַ
ReadSector:
	mov word[Temp.cbSizeOfPacket],Temp.EndOfPacket-Temp.ReadPacket
	mov dl,[BPB.bDrivers]
	mov si,Temp.ReadPacket
	mov ah,0x42
	int 0x13
	jc ReadErr
	ret

ReadErr:
	mov si,.ReadErr
	mov cx,.ReadErrLen
	jmp ErrAndReboot
.ReadErr		db	"Replace the disk and then press any key"
.ReadErrLen		equ	$-.ReadErr

INT13ExNotOK:
	mov si,.ReadErr
	mov cx,.ReadErrLen
	jmp ErrAndReboot
.ReadErr		db	"Unable To Read"
.ReadErrLen		equ	$-.ReadErr

;��ʾ����Ȼ�󵱻��ĺ���
	;si=������ʾ�ı�
	;cx=�ı�����
;����
	;����
ErrAndReboot:
	mov bx,0x07						;��ɫ����ͨ��ɫ
	mov ah,0x0E						;���ܣ���ӡ����
	.LoopShowText:
	lodsb
	int 0x10						;��ӡ�ı�
	loop .LoopShowText
	sti
	xor ax,ax
	int 0x16
	int 0x18

g_strLoaderFileName	db	LODR_FILENAME

times HDD_SEC_LEN-($-$$)-2			hlt
.BootFlag	dw	FLAG_BOOTALBE

SecondPart:
.FoundBootFile:						;�Ѿ��ҵ��������ļ�
	mov eax,[Temp.qwFATStart]		;�ȶ�ȡFAT��һ������
	mov [Temp.qwLBA],eax			;��FAT��һ������LBA���˵���ȡ���ݰ���
	mov eax,[Temp.qwFATStart+4]
	mov [Temp.qwLBA+4],eax
	movzx edi,word[si+FAT_DIRITEM.wFirstClusLO];di=�״غŵ�16λ��ͬʱ���edi��λ
	xor cx,cx						;cxָʾ��ǰ�����FAT�����ţ�֮���Զ�ȡFAT
	mov dword[Temp.wBufferOffset],HDD_FAT_BUFFER
	call ReadSector					;��ȡFAT��һ������
	mov dword[Temp.wLoaderOffset],BOOT_ORG;�������������ȡλ��
	movzx bp,byte[BPB.bSecsPerCluster];bp=ÿ��������

.ReadFromClus:
	mov [Temp.wBlocks],bp			;��ȡһ�����õ���������
	mov eax,edi						;ȡ�ôغ�
	dec ax
	dec ax							;�غż�ȥ2
	mul bp							;����ÿ��������
	shl edx,16						;dx��ֵΪ�ص��������λ�ø�16λ
	or eax,edx						;�ϲ���eax����ʱeaxΪ�ص��������λ��
	xor edx,edx						;edxΪ�ص��������λ�õĸ�λ
	add eax,[Temp.qwDataStart]		;���λ�ü���������������λ�ã�Ϊ�صľ�������λ�á�
	adc edx,[Temp.qwDataStart+4]	;��λ
	mov [Temp.qwLBA],eax			;���ö�ȡLBA
	mov [Temp.qwLBA+4],edx			;��λ
	mov eax,[Temp.wLoaderOffset]	;ȡ�ö�ȡĿ��λ��
	mov [Temp.wBufferOffset],eax	;���˵���ȡĿ�괦
	call ReadSector					;��ȡ�����ļ��ĵ�һ����
	push bp							;bp=ÿ��������
	shl bp,9						;bp*0x200=ÿ���ֽ���
	add [Temp.wLoaderOffset],bp		;��ȡλ��������
	jnc .CheckNextFATItem
	add word[Temp.wLoaderSegment],0x1000;��δ�������Ҳ����ƫ��
.CheckNextFATItem:					;Ѱ����һ��FAT�غ�
	pop bp							;ȡ��ÿ��������
	;ÿ��FAT�����ܴ洢0x100���غ�
	;cx=��ǰ��ȡ���ڴ��е�FAT�������������ţ��ж��Ƿ�Ӧ�����¶�ȡFAT����������
	mov eax,edi						;�Ȼ�ȡ��ǰ�Ѿ���ȡ�ĴصĴغš�
	mov ah,0						;ֻ�����غŵ�8λ������������ȷ��ȡFAT�������ж�Ӧ�Ĵغ�
	mov ax,[eax+eax+HDD_FAT_BUFFER]	;Ȼ���FAT���õ���һ���غ�
	cmp ax,FAT16_MINVALIDCLUS		;�жϴغ��Ƿ�Ϸ�
	jb ReadErr						;���Ϸ��򱨴�
	cmp ax,FAT16_MAXVALIDCLUS		;�ж��Ƿ�ĩ��
	ja .FinishedReading				;�ǵĻ���ɶ�ȡ����
	push ax							;��������
	cmp ah,cl						;�жϵ�ǰ�غ��Ƿ��ڵ�ǰFAT����
	jz .ContinueCheckFATItem		;�ǵĻ�������ȡ�غ�
	shr ax,8						;����ȡ���µ�FAT��������
	mov cl,al						;cx=��ǰ��ȡ���ڴ��е�FAT��������������
	xor edx,edx						;��λ
	add eax,[Temp.qwFATStart]		;����FAT������ʼλ��
	adc edx,[Temp.qwFATStart+4]		;��λ
	mov [Temp.qwLBA],eax			;����Ҫ��ȡ��FAT��LBA
	mov [Temp.qwLBA+4],edx			;��λ
	mov word[Temp.wBlocks],1		;��ȡһ����
	mov dword[Temp.wBufferOffset],HDD_FAT_BUFFER
	call ReadSector					;��ȡFAT��
	
.ContinueCheckFATItem:				;��ջ��ѹ���˴غ�
	pop di							;ȡ���غ�
	jmp .ReadFromClus				;��ȥ������ȡ��
	
.FinishedReading:					;��ȡ���ʼ����
	jmp 0x0000:BOOT_ORG

times HDD_SEC_LEN*2-($-$$)-2		hlt
.BootFlag	dw	FLAG_BOOTALBE
