
1） makeSelfExtracting.sh
	此文件为Linux下生成的自解压包的shell脚本
	makeself   为脚本必须的首项参数
	-s dstfile 指定生成的自解压包的名称，无则默认为 SelfExtractingPackage.run
	-p package 指定需要打包的文件(可以是一个文件，也可以是一个目录),使用相对于本脚本的相对路径，下同
	-e exefile 指定自解压包执行时，解压完成后需要调用的可执行程序(可以是脚本也可以是二进制可执行文件)
	

2） SelfExtractingPackage.run
	此文件为使用 makeSelfExtracting.sh 制作生成的自解压包，其中打包的内容为 setup.sh smartbc 两个文件
	直接执行 ./SelfExtractingPackage.run 将输出如下内容：
'''
	myPackage/
	myPackage/setup.sh
	myPackage/smartbc
	myPackage/setup.sh
	*** The package has been unpacked successfully ***
	This is a test script that is called when the package is executed
	If you can see 'All is ok!', that means the self-extracting package is perfect!
	Now you can custom your actions via the script makeSelfExtracting.sh
'''

	执行 tree -a 将看到如下内容：
'''
	.
	├── .extract
	│   └── myPackage
	│       ├── setup.sh
	│       └── smartbc
	├── .makeSelfExtracting.sh
	└── SelfExtractingPackage.run

	2 directories, 4 files
'''
	其中：
	.extract 为解压输出的文件存储目录
	.makeSelfExtracting.sh 为 makeSelfExtracting.sh 的一个副本

3） SelfExtractingPackage.run 的制作直接执行如下命令即可
	./makeSelfExtracting.sh makeself -p myPackage/ -e myPackage/setup.sh
