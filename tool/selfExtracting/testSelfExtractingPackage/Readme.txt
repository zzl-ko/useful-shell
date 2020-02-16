
1） makeSelfExtracting.sh
	此文件为Linux下生成可执行自解压包的shell脚本
	makeself   为脚本必须的首项参数
	-s dstfile 指定生成的自解压包的名称，无，则默认为 -p 指定的package名称加 .run 后缀(此处package为myPackage, 则dstfile为myPackage.run)
	-p package 指定需要打包的文件(可以是一个文件，也可以是一个目录),使用相对于本脚本的相对路径，下同
	-e exefile 指定自解压包执行时，解压完成后需要调用的可执行程序(可以是脚本也可以是二进制可执行文件)
	

2） myPackage.run
	此文件为使用 makeSelfExtracting.sh 制作生成的自解压包，其中打包的内容为 setup.sh smartbc 两个文件
	直接执行 ./myPackage.run 将输出如下内容：
'''
	myPackage/
    myPackage/setup.sh
    myPackage/smartbc
    myPackage/setup.sh
    *** The package has been unpacked successfully *** 


    This is a test script that is called when the package is executed
    Father's EXTRACT_DIR is [/tmp/.extract]

    --------------------------------------
    Original EQUATION: 0xa-0o5+0b110*(5+1) 
    Decimal  EQUATION: 10-5+6*(5+1)
    base2 : 101001
    base8 : 51
    base10: 41
    base16: 29
    --------------------------------------

    Now you can custom your actions via the script makeSelfExtracting.sh
'''

	执行 tree -a /tmp/.extract 将看到如下内容：
'''
	/tmp/.extract/
    ├── .makeSelfExtracting.sh
    └── myPackage
        ├── setup.sh
        └── smartbc

    1 directory, 3 files
'''
	其中：
	.extract 为解压输出的文件存储目录
	.makeSelfExtracting.sh 为 makeSelfExtracting.sh 的一个副本

3） myPackage.run 的制作直接执行如下命令即可
	./makeSelfExtracting.sh makeself -p myPackage/ -e myPackage/setup.sh
