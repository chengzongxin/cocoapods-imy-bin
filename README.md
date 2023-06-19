
#### 1.安装指定github仓库
```
sudo gem install specific_install
sudo gem specific_install -l https://github.com/chengzongxin/cocoapods-imy-bin.git
或者
sudo gem specific_install -l https://gitee.com/chengzongxin/cocoapods-imy-bin.git
```

#### 2.编译安装
```shell
git clone https://github.com/chengzongxin/cocoapods-imy-bin.git
gem build *.gemspec
gem install *.gem
```

### 3.配置模板
```shell
pod bin init --bin-url=https://raw.githubusercontent.com/chengzongxin/cocoapods-imy-bin/main/Docs/bin_dev.yml
```



# 原版教程
https://github.com/MeetYouDevs/cocoapods-imy-bin

# Usage:

#### pod bin repo trigger & pod bin repo modify
```shell
如果只是修改commit号，提交时，按照【podname1-version1,podname2-version2,...】这种格式提交，会自动更新仓库并打包二进制
【THKMacroKit-0.1.0,THKSafeKit-0.1.0,THKRouterKit-0.1.0】
```
#### pod bin auto --all-make
```shell
如果是增加版本号，直接使用在打包机打包，会自动生成最新
```