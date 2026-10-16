[English](./DISTRIBUTION_PACKAGING.md)

# 第三方分发元数据

MorseCQ 的 CI 生成不可变、带版本号的 GitHub Release 资产。`packaging/templates/`
中的文件有意保持为模板：标签构建完成前无法得知校验值，因此模板绝不能直接提交给
Homebrew、Flathub、Snap Store、WinGet 或 Chocolatey。

## 发布清单

包管理器从公开的 Release 下载，因此在 Release 带着最终资产和校验值正式发布之前，
不渲染也不提交任何元数据。

1. 创建并推送与 `apps/morsecq/pubspec.yaml` 三段版本号一致的标签 `vX.Y.Z`
   （构建工作流会拒绝不一致的标签）。
2. 等待草稿 GitHub Release 及全部十个平台资产生成。
3. CI 之外的签名在此时、Release 仍为草稿时完成：所有者用 Developer ID 为 macOS
   归档签名并公证；有证书后为 Windows MSI 做 Authenticode 签名。只在草稿中替换
   发生变化的资产。
4. 下载最终资产，校验并重新生成 `SHA256SUMS`：

   ```sh
   bash tool/ci/verify_release_assets.sh dist vX.Y.Z
   ```

   用这份 `SHA256SUMS` 覆盖 CI 附在草稿上的那一份。CI 的清单描述的是未签名的
   二进制文件，与已签名文件一同发布会公开错误的校验值。
5. 发布 Release。下载地址从此刻起才公开；基于草稿渲染的元数据不得提交。
6. 根据最终清单渲染元数据。默认架构为 universal2 macOS 归档；Release 只含单一
   架构的一组文件时传入 `--macos-arch arm64` 或 `x86_64`（此时 Homebrew cask
   会声明该架构）：

   ```sh
   python3 tool/release/generate_distribution_metadata.py \
     --version X.Y.Z \
     --release-date YYYY-MM-DD \
     --sha256sums dist/SHA256SUMS \
     --macos-arch universal2 \
     --output-dir dist/packaging
   ```

   该命令为 Homebrew、Flathub、Snap、WinGet 和 Chocolatey 生成待审阅的文件，
   并附上各包所需的支持文件和图标。发布日期必须由调用方提供，且须为 GitHub
   Release 的实际发布日期。缺少必需的校验值时命令失败。`--allow-placeholders`
   仅用于本地预览；占位值不得发布。渲染出的各包目录可独立使用；在相应目录中
   运行原生构建（例如 `cd dist/packaging/snap && snapcraft`）。

7. 对照各包管理器当前的格式规范和贡献政策审阅每个生成的文件。Flathub 文件明确
   是二进制演示，不能直接提交：本项目在 Flathub 必须源码构建。请把其中的归档
   模块换成离线源码构建，再核对最终源码校验值和原生运行时依赖。Snap 文件同样
   未经测试；在把 `grade: devel` 改为 `stable` 前先验证 core24/GNOME 扩展运行时。
8. 通过各包管理器的常规审核流程提交生成的文件。包管理器的仓库与本仓库分开维护；
   本项目只负责模板和渲染工具。

## 资产对应

- Homebrew Cask：macOS `.zip`（`MorseCQ.app`）
- Flathub 和 Snap：Linux x86_64 `.tar.gz` 包
- WinGet 和 Chocolatey：Windows x64 `.msi`

所有地址都指向 `https://github.com/agentx-icu/morsecq/releases/download/vX.Y.Z/`。
不要把 Release 地址换成可变分支、“latest”地址或从其他版本复制的校验值。

## 政策参考

- [Snapcraft platforms](https://ubuntu.com/docs/snapcraft/9/reference/platforms/)
  要求 core24 声明 `platforms`；模板采用其 amd64 写法。
- [Snapcraft GNOME extension](https://ubuntu.com/docs/snapcraft/9/reference/extensions/gnome-extension/)
  提供模板所用的 GTK/GLib 桌面运行时。
- [Flathub requirements](https://docs.flathub.org/docs/for-app-authors/requirements)
  禁止常规提交中包含预编译的应用二进制文件，因此仓库中的 Flatpak 文件仅标注为
  二进制演示。
