
#### 1.安装指定github仓库
```
sudo gem install specific_install
sudo gem specific_install -l https://github.com/chengzongxin/cocoapods-imy-bin.git
```

#### 2.编译安装
```shell
git clone https://github.com/chengzongxin/cocoapods-imy-bin.git
gem build *.gemspec
gem install *.gem
```

### 3.配置模板
```shell
pod bin init --bin-url=https://github.com/chengzongxin/cocoapods-imy-bin-configs/raw/master/Docs/bin_dev.yml
```



# 原版教程
https://github.com/MeetYouDevs/cocoapods-imy-bin
