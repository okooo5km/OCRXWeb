# 图片 OCR 工具

这是一个基于 Vapor 框架开发的 Web 应用,用于对上传的图片进行 OCR (光学字符识别) 处理,并输出 JSON 或 CSV 格式的结果。

## 功能特点

- 支持图片上传
- 使用 Vision 框架进行 OCR 处理
- 支持输出 JSON 和 CSV 格式
- 自动复制处理结果到剪贴板
- 支持导出处理结果文件

## 系统要求

- macOS 12.0 或更高版本
- Swift 5.10
- Vapor 4.x

## 安装和运行

1. 克隆仓库:

   ```shell
   git clone https://github.com/yourusername/OcrXWeb.git
   cd OcrXWeb
   ```

2. 安装依赖:

   ```shell
   swift package resolve
   ```

3. 运行应用:

   ```shell
   swift run
   ```

4. 在浏览器中访问 `http://localhost:8080` 即可使用该工具

## 使用说明

1. 在网页界面上传一张图片
2. 选择输出格式（JSON 或 CSV）
3. 点击"确认"按钮进行处理
4. 处理完成后,结果会显示在文本框中,并自动复制到剪贴板
5. 如需保存结果,点击"导出"按钮即可下载文件

## 贡献

欢迎提交 Pull Requests 来改进这个项目。对于重大变更,请先开 issue 讨论您想要改变的内容。

## 许可证

本项目采用 MIT 许可证 - 详情请见 [LICENSE](LICENSE) 文件。
