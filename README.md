# shellclash_docker 一键脚本和镜像
在任意Linux主机上, 利用Docker自动创建并配置虚拟OpenWrt路由容器以运行 [juewuy's ShellClash](https://github.com/juewuy/ShellClash)

## 使用方法: 
- 下载脚本到Linux主机，root用户运行:
```
./install_shellclash_docker.sh #配置环境并安装, 安装过程中出现问题请运行卸载命令
```

- 成功导入配置并启动ShellClash后，在需要科学上网的设备上把网关及DNS改为ShellClash旁路网关地址即可

- 卸载命令:
```
./uninstall_shellclash_docker.sh #重置环境并卸载
```
