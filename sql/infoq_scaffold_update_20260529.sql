SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- OAuth 登录：运行本脚本后需重启服务，或清理 Redis 缓存 global:sys_client#30d。
UPDATE `sys_client`
SET `grant_type` = CASE
    WHEN `grant_type` IS NULL OR `grant_type` = '' THEN 'oauth'
    WHEN FIND_IN_SET('oauth', REPLACE(`grant_type`, ' ', '')) = 0 THEN CONCAT(`grant_type`, ',oauth')
    ELSE `grant_type`
END
WHERE `client_id` = 'e5cd7e4891bf95d1d19206ce24a7b32e';

CREATE TABLE IF NOT EXISTS `sys_oauth_provider` (
    `provider_id` bigint NOT NULL COMMENT 'OAuth平台ID',
    `provider_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '平台编码',
    `provider_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '平台名称',
    `enabled` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1' COMMENT '是否启用（0是 1否）',
    `allow_login` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1' COMMENT '是否允许登录（0是 1否）',
    `allow_bind` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1' COMMENT '是否允许绑定（0是 1否）',
    `allow_auto_register` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1' COMMENT '是否允许自动注册（0是 1否）',
    `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
    `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
    `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
    `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
    `create_by` bigint DEFAULT NULL COMMENT '创建者',
    `create_time` datetime DEFAULT NULL COMMENT '创建时间',
    `update_by` bigint DEFAULT NULL COMMENT '更新者',
    `update_time` datetime DEFAULT NULL COMMENT '更新时间',
    PRIMARY KEY (`provider_id`) USING BTREE,
    UNIQUE KEY `uk_sys_oauth_provider_code` (`provider_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='OAuth平台配置表';

INSERT IGNORE INTO `sys_oauth_provider` (`provider_id`, `provider_code`, `provider_name`, `enabled`, `allow_login`, `allow_bind`, `allow_auto_register`, `sort`, `remark`, `del_flag`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
(1, 'github', 'GitHub', '0', '0', '0', '1', 1, 'GitHub OAuth 登录', '0', 103, 1, now(), 1, now()),
(2, 'linuxdo', 'linux.do', '0', '0', '0', '1', 2, 'linux.do OAuth 登录', '0', 103, 1, now(), 1, now());

CREATE TABLE IF NOT EXISTS `sys_oauth_identity` (
    `identity_id` bigint NOT NULL COMMENT 'OAuth身份ID',
    `user_id` bigint NOT NULL COMMENT '本地用户ID',
    `provider_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '平台编码',
    `provider_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '平台应用键',
    `provider_subject` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '第三方稳定用户标识',
    `union_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第三方UnionId',
    `open_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第三方OpenId',
    `provider_username` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第三方用户名',
    `provider_nickname` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第三方昵称',
    `provider_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第三方邮箱',
    `provider_avatar` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第三方头像',
    `email_verified` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'N' COMMENT '邮箱是否验证（Y是 N否）',
    `metadata_json` json DEFAULT NULL COMMENT '第三方原始信息',
    `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
    `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
    `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
    `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
    `create_by` bigint DEFAULT NULL COMMENT '创建者',
    `create_time` datetime DEFAULT NULL COMMENT '创建时间',
    `update_by` bigint DEFAULT NULL COMMENT '更新者',
    `update_time` datetime DEFAULT NULL COMMENT '更新时间',
    PRIMARY KEY (`identity_id`) USING BTREE,
    UNIQUE KEY `uk_sys_oauth_identity_subject` (`provider_code`, `provider_key`, `provider_subject`) USING BTREE,
    UNIQUE KEY `uk_sys_oauth_identity_user_provider` (`user_id`, `provider_code`, `provider_key`) USING BTREE,
    KEY `idx_sys_oauth_identity_user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='OAuth身份绑定表';

SET @oauth_dict_code = IF(
    EXISTS (SELECT 1 FROM `sys_dict_data` WHERE `dict_code` = 34),
    (SELECT COALESCE(MAX(`dict_code`), 0) + 1 FROM `sys_dict_data`),
    34
);

INSERT INTO `sys_dict_data` (`dict_code`, `dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT @oauth_dict_code, 0, 'OAuth认证', 'oauth', 'sys_grant_type', 'el-check-tag', 'default', 'N', 103, 1, now(), NULL, now(), 'OAuth认证'
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_dict_data` WHERE `dict_type` = 'sys_grant_type' AND `dict_value` = 'oauth'
);

SET FOREIGN_KEY_CHECKS = 1;
