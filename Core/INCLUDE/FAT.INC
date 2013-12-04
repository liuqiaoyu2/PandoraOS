%ifndef __FAT_INFORMATION_INCLUDED__
%define	__FAT_INFORMATION_INCLUDED__

%define	OEM_NAME			"�ſ��ը"		;OEM���ֱ���Ϊ8�ֽ�

%define	MEDIA_FDD			0xF0			;�������ͣ�����
%define	MEDIA_HDD			0xF8			;�������ͣ�Ӳ��

%define	CHS_MAX				0x00FBFFFF		;CHSѰַ��ʽ��Ѱַ�������������

%define	FS_FAT12			"FAT12   "		;�ļ�ϵ�y������Ϊ8�ֽ�
%define	FS_FAT16			"FAT16   "
%define	FS_FAT32			"FAT32   "

%define	FLAG_EXT			0x29			;DBR��չ����������ʶ
%define	FLAG_BOOTALBE		0xAA55			;��������ʶ

%define	LABEL_DEF			"NO NAME    "	;Ĭ�Ͼ�����������Ϊ11�ֽ�

%define	SIZE_FILENAME		(8+3)
%define	SIZE_DIRENTRY		0x20

%define	FLOPPY_RESV_SECS	1
%define	FLOPPY_SEC_PER_CLS	1
%define	FLOPPY_SEC_PER_CYL	18
%define	FLOPPY_SEC_LEN		0x200
%define	FLOPPY_FAT_SECS		9
%define	FLOPPY_HEAD_COUNT	2
%define	FLOPPY_FAT_COUNT	2
%define	FLOPPY_CYL_PER_HEAD	80
%define	FLOPPY_SEC_COUNT	(FLOPPY_SEC_PER_CYL*FLOPPY_HEAD_COUNT*FLOPPY_CYL_PER_HEAD)
%define FLOPPY_ROOT_ITEMS	224
%define	FLOPPY_ROOT_LBA		(FLOPPY_RESV_SECS+FLOPPY_FAT_COUNT*FLOPPY_FAT_SECS)
%define	FLOPPY_FAT_ITEMS	0x600			;���̵�FAT������

%define	FLOPPY_FAT_BUFFER	0xA00			;���̶�ȡFAT�Ļ�����
%define	FLOPPY_DIR_BUFFER	(FLOPPY_FAT_BUFFER+FLOPPY_FAT_SECS*FLOPPY_SEC_LEN)

%define	HDD_SEC_LEN			0x200
%define	HDD_DIR_BUFFER		0xA00
%define	HDD_FAT_BUFFER		0xA00

;FAT���ĵ�һ��������Զ��������ʾ���̽������͵ġ�
;�������ĵ�8λ��Զ����DBR��ָ���Ľ������ͣ�MEDIA_FDD��MEDIA_HDD��
;��λȫ����1
;�ڶ���������Զ��EOC��β�ر�ʶ����ע��FAT16��FAT32�����β�ر�ʶ���µ��ô���
;����ڶ����������λ������Ϊ1������������ǡ��ɾ��ġ���
;���û�б�����Ϊ1������������ǡ���ġ���Ҳ����û�к������д���ļ��Ĺ�������ʱ���������һ��CHKDSK���һ�·�����
;��������ڶ�λ������Ϊ1��˵��������ʳ��������}���κζ���д�Ĳ������ǲ������ġ�����Է��������޸���飬������ܻᵼ�����݁Gʧ��
%define	FAT16_CLEAN			0x8000
%define	FAT16_ERROR			0x4000

%define	FAT32_CLEAN			0x08000000
%define	FAT32_ERROR			0x04000000

;FAT�غŵ�����ֵ
%define	FAT12_IDLECLUSTER	0x000
%define	FAT12_RESERVED		0x001
%define	FAT12_MINVALIDCLUS	0x002
%define	FAT12_MAXVALIDCLUS	0xFEF
%define	FAT12_BADCLUS		0xFF7
%define	FAT12_EOC			0xFFF

%define	FAT16_IDLECLUSTER	0x0000
%define	FAT16_RESERVED		0x0001
%define	FAT16_MINVALIDCLUS	0x0002
%define	FAT16_MAXVALIDCLUS	0xFFEF
%define	FAT16_BADCLUS		0xFFF7
%define	FAT16_EOC			0xFFFF

%define	FAT32_IDLECLUSTER	0x00000000
%define	FAT32_RESERVED		0x00000001
%define	FAT32_MINVALIDCLUS	0x00000002
%define	FAT32_MAXVALIDCLUS	0x0FFFFFEF
%define	FAT32_BADCLUS		0x0FFFFFF7
%define	FAT32_EOC			0x0FFFFFFF

;�ļ�Ŀ¼���ֵ
%define	ATTR_READONLY		0x01
%define	ATTR_HIDE			0x02
%define	ATTR_SYSTEM			0x04
%define	ATTR_VOLUMELABEL	0x08
%define	ATTR_SUBDIR			0x10
%define	ATTR_ARCHIVE		0x20
%define	ATTR_LONGNAME		0x0F

%define	DIRITEM_DELETED		0xE5
%define	DIRITEM_FREE		0x00
%define	DIRITEM_DELETED_JPN	0x05;���ձ������ֵ��ͬ��DIRITEM_DELETED

%define	DIRITEM_SELF		".          "
%define	DIRITEM_PARENT		"..         "

struc FAT_DIRITEM				;FATĿ¼��ṹ��
	.szFileName		resb	8	;8�ֽڶ��ļ�������һ���ֽڿ�����DIRITEM_DELETED���фh������DIRITEM_FREE�����п��ã�
	.szExt			resb	3	;3�ֽ���չ��
	.bAttribute		resb	1	;1�ֽ�����
	.bReserved		resb	1	;����
	.bCreateTimeMS	resb	1	;�ļ�����ʱ��ĺ�������10����ֵΪ0-199��ʵΪ0-1990���룬��Ϊ�ļ�ʱ�����������������Ϊ��λ��
	.wCreateTime	resw	1	;�ļ�����ʱ��
	.wCreateDate	resw	1	;�ļ���������
	.wLastAccDate	resw	1	;����������
	.wFirstClusHI	resw	1	;�״غŵĸ�16λ
	.wWriteTime		resw	1	;���д������ʱ��
	.wWriteDate		resw	1	;���д����������
	.wFirstClusLO	resw	1	;�״غŵĵ�16λ
	.dwFileSize		resd	1	;�ļ���С
endstruc
;���ڸ�ʽ��
;λ0-4��	���ڣ�ֵΪ1-31
;λ5-8��	�·ݣ�ֵΪ1-12
;λ9-15��	�꣬��1980��ʼ����2107�꣬��127��
;ʱ���ʽ��
;λ0-4��	����/2��ֵΪ0-29��ʵ�ʱ�ʾ0-58�룩
;λ5-10��	���ӣ�ֵΪ0-59
;λ11-15��	Сʱ��ֵΪ0-23
;���ļ�����ʹ�õķ��ţ�$ % ' - _ @ ~ ` ! ( ) { } ^ # &

;FAT��Ŀ¼����֧�ֳ��ļ��������ļ����������Ŀ¼����ȡ����ÿ�����ļ���Ŀ¼��֧��13�ַ���
;У�����ͬ�ĳ��ļ���Ŀ¼�����ͬһ���ļ��ĳ��ļ��������ļ���ʹ��UNICODE���롣
;���ļ���Ŀ¼���˳��洢��ָ����DIRITEM_LASTLONGNAME�ĳ��ļ���Ŀ¼��������һ�����ļ���Ŀ¼�
%define	DIRITEM_LASTLONGNAME	0x40;���һ�����ļ������λ�����������ļ�����ġ�bOrder���߼������ֵ���㣬���ʾ�������һ�����ļ����
struc FAT_LONGNAME					;FAT�ĳ��ļ���Ŀ¼��ṹ��
	.bOrder				resb	1	;���ļ���˳��
	.wNamePart1			resw	5	;5���ַ��ĳ��ļ�����һ����
	.bAttribute			resb	1	;���ԣ�����ΪATTR_LONGNAME
	.bType				resb	1	;���ͣ�Ϊ0���ʾ���ǳ��ļ�����һ���ݣ�����ֵ����Ϊ������չʱ�á�
	.bChksum			resb	1	;У���
	.wNamePart2			resw	6	;6���ַ��ĳ��ļ�����һ����
	.wFirstClusLO		resw	1	;����Ϊ0
	.wNamePart3			resw	2	;2���ַ��ĳ��ļ�����һ����
endstruc
;���ļ�����ֹʹ�õ��ַ���+ , ; = [ ]
;���ļ���ʹ��UNICODE���롣
;У��ͼ��㷽ʽ��
;//-----------------------------------------------------------------------------
;// ChkSum()
;// Returns an unsigned byte checksum computed on an unsigned byte
;// array. The array must be 11 bytes long and is assumed to contain
;// a name stored in the format of a MS-DOS directory entry.
;// Passed: pFcbName Pointer to an unsigned byte array assumed to be
;// 11 bytes long.
;// Returns:Sum An 8-bit unsigned checksum of the array pointed
;// to by pFcbName.
;//------------------------------------------------------------------------------
;unsigned char ChkSum (unsigned char *pFcbName)
;{
;	short FcbNameLen;
;	unsigned char Sum;
;	Sum=0;
;	for (FcbNameLen=11; FcbNameLen!=0; FcbNameLen--) {
;		// NOTE: The operation is an unsigned char rotate right
;		Sum = ((Sum & 1) ? 0x80 : 0) + (Sum >> 1) + *pFcbName++;
;	}
;	return (Sum);
;}
;ÿ�����ļ�������Ӧһ�����ļ�����
;�����Ҫ����һ���ļ��K����õ��˳��ļ�������ô����봴����Ӧ�Ķ��ļ�����
;���ļ����ϳɷ�����
;	�ѳ��ļ���ת����ȫ��д
;	��ȫ��д�ĳ��ļ���ת����OEM����퓱��룬�Ƿ��ַ������»���'_'
;	ȥ�����г��ļ���ǰ��Ŀո�
;	ȥ�����г��ļ���ǰ�ľ��'.'
;	�ѳ��ļ���ǰ��Ĳ��Ǿ���8���ַ���Ϊ�����Ķ��ļ���
;	�ӳ��ļ������ҵ����ľ�㣬����ҵ������Ѿ��������ַ���Ϊ���ļ�����׺

;	������ļ�����û�зǷ��ַ������ļ���������8.3�ԃȣ����ɵĶ��ļ��������������ļ����ظ�
;	��ô������ļ������Ѿ�����ʹ����
;	������ļ���β�ĳ�~n��ע��~n���Դ�~1��~999999��ѡһ������ʹ�䲻���������ļ����ظ�




%endif