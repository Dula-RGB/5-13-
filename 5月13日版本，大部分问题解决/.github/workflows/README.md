# GitHub Actions CI/CD 配置

本项目包含两个GitHub Actions工作流用于打包iOS应用：

## 1. build-ipa.yml - 基础打包（无需签名证书）

这个工作流用于快速构建和测试，不需要Apple开发者证书。

### 触发方式：
- 推送到 `main`, `master`, 或 `develop` 分支
- 提交 Pull Request
- 手动触发（workflow_dispatch）

### 使用方法：
1. 进入 GitHub 仓库的 Actions 标签页
2. 选择 "Build IPA" 工作流
3. 点击 "Run workflow"
4. 选择构建类型（debug/release）

### 输出：
- 未签名的 IPA 文件（用于测试）
- Xcode Archive 文件

---

## 2. build-ipa-signed.yml - 签名打包（需要证书）

这个工作流用于生成可用于设备测试或App Store分发的签名IPA。

### 前置要求：

需要在 GitHub 仓库的 Settings > Secrets and variables > Actions 中添加以下 Secrets：

| Secret 名称 | 说明 | 获取方式 |
|------------|------|---------|
| `P12_CERTIFICATE` | Base64编码的.p12证书 | 导出开发者证书并Base64编码 |
| `P12_PASSWORD` | 证书密码 | 导出证书时设置的密码 |
| `MOBILEPROVISION` | Base64编码的描述文件 | 下载描述文件并Base64编码 |
| `TEAM_ID` | Apple Developer Team ID | Apple Developer Portal |

### 准备证书的步骤：

1. **导出证书为 .p12 文件：**
   ```bash
   # 在 macOS 钥匙串访问中
   # 1. 找到你的开发者证书
   # 2. 右键点击 -> 导出
   # 3. 选择 .p12 格式，设置密码
   ```

2. **Base64 编码证书：**
   ```bash
   base64 -i Certificates.p12 -o certificate.base64
   ```

3. **Base64 编码描述文件：**
   ```bash
   base64 -i ACROSSDataCollection.mobileprovision -o provision.base64
   ```

4. **将编码后的内容添加到 GitHub Secrets**

### 触发方式：
- 仅支持手动触发（workflow_dispatch）

### 使用方法：
1. 进入 GitHub 仓库的 Actions 标签页
2. 选择 "Build Signed IPA" 工作流
3. 点击 "Run workflow"
4. 选择：
   - Build Type: debug/release
   - Signing Type: development/adhoc/appstore

### 输出：
- 签名的 IPA 文件
- 自动创建 Release（仅当 signing_type 为 appstore 时）

---

## 注意事项

1. **Bundle Identifier**: 确保项目中的 Bundle ID 与描述文件中的匹配
2. **版本号**: 每次构建前建议更新版本号
3. **CocoaPods**: 工作流会自动安装和缓存 Pods
4. **Xcode 版本**: 当前配置使用 Xcode 15.0

## 故障排除

### 签名失败
- 检查证书和描述文件是否过期
- 确认 Bundle ID 匹配
- 验证 Team ID 正确

### 构建失败
- 检查 Podfile 是否有更新
- 确认 scheme 名称正确（ACROSSDataCollection）
- 查看详细日志定位问题

## 相关链接

- [Apple Developer Portal](https://developer.apple.com/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Xcode Build 命令参考](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
