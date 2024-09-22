import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) async throws {
    // 现有配置...

    // 配置 Leaf
    app.views.use(.leaf)

    // 配置静态文件服务
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // 注册路由
    try routes(app)
    
    // 增加最大上传大小限制（例如设置为 50MB）
    app.routes.defaultMaxBodySize = "50mb"
}
