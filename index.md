### bmp2txt
transfer the 24-bit .bmp image to the ascii image

本汇编程序是将24Bit位图图像转换成文本图画

- 运行环境为： 32位 windows + masm 6.0
- windows 7 的 cmd.exe 如果不能运行本程序，可以用 DOSBOX 来运行本程序；
- 运行本程序时，需要将要转换的 24bit .bmp格式位图图片放置在 masm 6.0 的文件夹里；
- 图片名字不能含有中文和空格；
- 输出字符图画文件在本目录下；
- 例如，将名为 24-lena.bmp 的24bit .bmp格式图片转换为字符图画：
 ```
 1、 运行命令行；
 2、 T5.EXE；
 3、 bmp2txt 24-lena.bmp d.txt
```
这个程序虽然写地很粗糙，重要的地方都标了注释，有一定汇编基础的应该没什么太多问题吧……就这么多，欢迎拍砖 ^_^

- 说明：

  - 程序代码文件为 T5.ASM；
  - 24-lena.bmp，subway.bmp图片均为测试图片；
  - 其它文件为.ASM文件编译、调试时使用；
  - 本程序仅供转换 .BMP 格式的图片，其它格式图片不支持；
  - 须将要转换的图片移至本目录下才可成功转换，转换成功后的文本文件生成于本目录内；
```
XXXXXX        XXXXXX          PPPPPPPPPPPPPPPPPPPP
 XXXXXX      XXXXXX          PPPPPPPPPPPPPPPPPPPP
  XXXXXX    XXXXXX          PPPPPP        PPPPPP
   XXXXXX  XXXXXX          PPPPPP        PPPPPP
    XXXXXXXXXXXX          PPPPPPPPPPPPPPPPPPPP
   XXXXXX  XXXXXX        PPPPPP
  XXXXXX    XXXXXX      PPPPPP
 XXXXXX      XXXXXX    PPPPPP
XXXXXX        XXXXXX  PPPPPP               CS1004
```
