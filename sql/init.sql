-- ----------------------------
-- 数据库初始化脚本
-- Dart 全栈管理系统
-- ----------------------------
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 用户表
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码（明文演示，生产需加密）',
  `nickname` varchar(50) DEFAULT '' COMMENT '昵称',
  `avatar` varchar(255) DEFAULT '' COMMENT '头像URL',
  `phone` varchar(20) DEFAULT '' COMMENT '手机号',
  `email` varchar(100) DEFAULT '' COMMENT '邮箱',
  `status` tinyint DEFAULT 1 COMMENT '状态 1-正常 0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 插入默认管理员
INSERT INTO `user` (`username`, `password`, `nickname`) VALUES ('admin', '123456', '系统管理员');

-- ----------------------------
-- 2. 角色表
-- ----------------------------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `name` varchar(50) NOT NULL COMMENT '角色名称',
  `code` varchar(50) DEFAULT '' COMMENT '角色编码',
  `remark` varchar(255) DEFAULT '' COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 插入默认角色
INSERT INTO `role` (`name`, `code`, `remark`) VALUES ('超级管理员', 'admin', '系统最高权限');
INSERT INTO `role` (`name`, `code`, `remark`) VALUES ('普通用户', 'user', '基础操作权限');

-- ----------------------------
-- 3. 用户角色关联表
-- ----------------------------
DROP TABLE IF EXISTS `user_role`;
CREATE TABLE `user_role` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `role_id` int NOT NULL COMMENT '角色ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_role` (`user_id`,`role_id`),
  KEY `idx_role_id` (`role_id`),
  CONSTRAINT `fk_user_role_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_role_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- 给admin分配超级管理员角色
INSERT INTO `user_role` (`user_id`, `role_id`) VALUES (1, 1);

-- ----------------------------
-- 4. 菜单表
-- ----------------------------
DROP TABLE IF EXISTS `menu`;
CREATE TABLE `menu` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `parent_id` int DEFAULT 0 COMMENT '父菜单ID 0-顶级菜单',
  `name` varchar(50) NOT NULL COMMENT '菜单名称',
  `path` varchar(100) DEFAULT '' COMMENT '路由路径',
  `component` varchar(100) DEFAULT '' COMMENT '前端组件路径',
  `icon` varchar(50) DEFAULT '' COMMENT '菜单图标',
  `sort` int DEFAULT 0 COMMENT '排序号',
  `type` tinyint DEFAULT 1 COMMENT '类型 1-菜单 2-按钮',
  `permission` varchar(100) DEFAULT '' COMMENT '权限标识',
  `status` tinyint DEFAULT 1 COMMENT '状态 1-正常 0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单表';

-- 插入默认菜单
INSERT INTO `menu` (`parent_id`, `name`, `path`, `icon`, `sort`, `type`) VALUES (0, '首页', '/home', 'home', 1, 1);
INSERT INTO `menu` (`parent_id`, `name`, `path`, `icon`, `sort`, `type`) VALUES (0, '系统管理', '/system', 'setting', 2, 1);
INSERT INTO `menu` (`parent_id`, `name`, `path`, `icon`, `sort`, `type`) VALUES (2, '用户管理', '/system/user', 'user', 1, 1);
INSERT INTO `menu` (`parent_id`, `name`, `path`, `icon`, `sort`, `type`) VALUES (2, '角色管理', '/system/role', 'group', 2, 1);
INSERT INTO `menu` (`parent_id`, `name`, `path`, `icon`, `sort`, `type`) VALUES (2, '菜单管理', '/system/menu', 'menu', 3, 1);
INSERT INTO `menu` (`parent_id`, `name`, `path`, `icon`, `sort`, `type`) VALUES (0, '日志管理', '/log', 'history', 3, 1);
INSERT INTO `menu` (`parent_id`, `name`, `path`, `icon`, `sort`, `type`) VALUES (0, '聊天功能', '/chat', 'chat', 4, 1);

-- ----------------------------
-- 5. 角色菜单关联表
-- ----------------------------
DROP TABLE IF EXISTS `role_menu`;
CREATE TABLE `role_menu` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `role_id` int NOT NULL COMMENT '角色ID',
  `menu_id` int NOT NULL COMMENT '菜单ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_role_menu` (`role_id`,`menu_id`),
  KEY `idx_menu_id` (`menu_id`),
  CONSTRAINT `fk_role_menu_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_menu_menu` FOREIGN KEY (`menu_id`) REFERENCES `menu` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色菜单关联表';

-- 给超级管理员分配所有菜单
INSERT INTO `role_menu` (`role_id`, `menu_id`) VALUES (1, 1);
INSERT INTO `role_menu` (`role_id`, `menu_id`) VALUES (1, 2);
INSERT INTO `role_menu` (`role_id`, `menu_id`) VALUES (1, 3);
INSERT INTO `role_menu` (`role_id`, `menu_id`) VALUES (1, 4);
INSERT INTO `role_menu` (`role_id`, `menu_id`) VALUES (1, 5);
INSERT INTO `role_menu` (`role_id`, `menu_id`) VALUES (1, 6);
INSERT INTO `role_menu` (`role_id`, `menu_id`) VALUES (1, 7);

-- ----------------------------
-- 6. 登录日志表
-- ----------------------------
DROP TABLE IF EXISTS `login_log`;
CREATE TABLE `login_log` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `ip` varchar(50) DEFAULT '' COMMENT '登录IP',
  `address` varchar(100) DEFAULT '' COMMENT '登录地址',
  `browser` varchar(50) DEFAULT '' COMMENT '浏览器',
  `os` varchar(50) DEFAULT '' COMMENT '操作系统',
  `status` varchar(20) DEFAULT 'success' COMMENT '登录状态 success-成功 fail-失败',
  `msg` varchar(255) DEFAULT '' COMMENT '提示信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录日志表';

-- ----------------------------
-- 7. 操作日志表
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `module` varchar(50) DEFAULT '' COMMENT '操作模块',
  `operation` varchar(50) DEFAULT '' COMMENT '操作类型',
  `method` varchar(10) DEFAULT '' COMMENT '请求方法 GET/POST/PUT/DELETE',
  `url` varchar(255) DEFAULT '' COMMENT '请求URL',
  `params` text COMMENT '请求参数',
  `ip` varchar(50) DEFAULT '' COMMENT '操作IP',
  `time` int DEFAULT 0 COMMENT '耗时(ms)',
  `status` tinyint DEFAULT 1 COMMENT '状态 1-成功 0-失败',
  `error_msg` text COMMENT '错误信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_module` (`module`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- ----------------------------
-- 8. 字典类型表
-- ----------------------------
DROP TABLE IF EXISTS `dict_type`;
CREATE TABLE `dict_type` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '字典类型ID',
  `name` varchar(50) NOT NULL COMMENT '字典类型名称',
  `code` varchar(50) NOT NULL COMMENT '字典类型编码',
  `remark` varchar(255) DEFAULT '' COMMENT '备注',
  `status` tinyint DEFAULT 1 COMMENT '状态 1-正常 0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典类型表';

-- ----------------------------
-- 9. 字典数据表
-- ----------------------------
DROP TABLE IF EXISTS `dict_data`;
CREATE TABLE `dict_data` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '字典数据ID',
  `type_id` int NOT NULL COMMENT '字典类型ID',
  `label` varchar(50) NOT NULL COMMENT '字典标签',
  `value` varchar(50) NOT NULL COMMENT '字典值',
  `sort` int DEFAULT 0 COMMENT '排序号',
  `status` tinyint DEFAULT 1 COMMENT '状态 1-正常 0-禁用',
  `remark` varchar(255) DEFAULT '' COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_type_id` (`type_id`),
  CONSTRAINT `fk_dict_data_type` FOREIGN KEY (`type_id`) REFERENCES `dict_type` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典数据表';

-- 插入默认字典数据
INSERT INTO `dict_type` (`name`, `code`, `remark`) VALUES ('用户状态', 'user_status', '用户状态字典');
INSERT INTO `dict_data` (`type_id`, `label`, `value`, `sort`) VALUES (1, '正常', '1', 1);
INSERT INTO `dict_data` (`type_id`, `label`, `value`, `sort`) VALUES (1, '禁用', '0', 2);

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- 初始化完成提示
-- ----------------------------
SELECT '✅ 数据库初始化完成！' AS '提示';
SELECT '默认账号：admin / 123456' AS '默认信息';