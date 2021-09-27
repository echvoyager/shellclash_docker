# shellclash_docker 一键脚本和镜像
在任意Linux主机上, 利用Docker自动创建并配置虚拟OpenWrt路由容器以运行 [juewuy's ShellClash](https://github.com/juewuy/ShellClash) 实现旁路由透明代理

## 使用方法: 
- 下载脚本到Linux主机, root用户运行:
```
./install_shellclash_docker.sh #配置环境并安装, 安装过程中出现问题请运行卸载命令
```

- 成功导入配置并启动ShellClash后, 在需要科学上网的设备上把网关及DNS改为ShellClash旁路网关地址即可


- 卸载命令:
```
./uninstall_shellclash_docker.sh #重置环境并卸载
```

## 注意事项:
- 宿主机重启后会重置防火墙配置, 请根据自己的Linux发行版本在安装完成后自行固化防火墙配置
- 如未保存宿主机防火墙配置, 重启后需运行以下脚本重新配置防火墙; 首先cd到脚本所在文件夹, 再运行:
```
./configure_ip.sh #重新配置防火墙
```
- 如果知道如何操作, 亦可将此防火墙配置脚本设置开机自动运行
