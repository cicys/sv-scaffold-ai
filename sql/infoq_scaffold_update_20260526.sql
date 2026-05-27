SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `sys_config`
    ADD COLUMN `value_type` varchar(20) NOT NULL DEFAULT 'text' COMMENT '参数值类型' AFTER `config_value`;

ALTER TABLE `sys_config`
    ADD COLUMN `default_value` text DEFAULT NULL COMMENT '默认值，NULL表示无默认值' AFTER `value_type`;

ALTER TABLE `sys_config`
    ADD COLUMN `group_key` varchar(50) DEFAULT NULL COMMENT '配置分组' AFTER `default_value`;

ALTER TABLE `sys_config`
    ADD COLUMN `display_order` int NOT NULL DEFAULT 0 COMMENT '显示顺序' AFTER `group_key`;

ALTER TABLE `sys_config`
    ADD COLUMN `options_json` text DEFAULT NULL COMMENT '下拉选项JSON' AFTER `display_order`;

ALTER TABLE `sys_config`
    ADD COLUMN `ui_props_json` text DEFAULT NULL COMMENT 'UI属性JSON' AFTER `options_json`;

UPDATE `sys_config`
SET `value_type` = 'switch',
    `default_value` = 'false',
    `group_key` = 'account',
    `display_order` = 10,
    `options_json` = NULL,
    `ui_props_json` = NULL
WHERE `config_key` = 'sys.account.registerUser';

UPDATE `sys_config`
SET `value_type` = 'switch',
    `default_value` = 'false',
    `group_key` = 'account',
    `display_order` = 20,
    `options_json` = NULL,
    `ui_props_json` = NULL
WHERE `config_key` = 'sys.account.inviteRegister';

UPDATE `sys_config`
SET `value_type` = 'switch',
    `default_value` = 'false',
    `group_key` = 'account',
    `display_order` = 30,
    `options_json` = NULL,
    `ui_props_json` = NULL
WHERE `config_key` = 'sys.account.forgotPassword';

UPDATE `sys_config`
SET `value_type` = 'password',
    `default_value` = '123456',
    `group_key` = 'account',
    `display_order` = 40,
    `options_json` = NULL,
    `ui_props_json` = NULL
WHERE `config_key` = 'sys.user.initPassword';

UPDATE `sys_config`
SET `value_type` = 'select',
    `default_value` = 'theme-light',
    `group_key` = 'theme',
    `display_order` = 10,
    `options_json` = '[{"label":"深色主题","value":"theme-dark"},{"label":"浅色主题","value":"theme-light"}]',
    `ui_props_json` = NULL
WHERE `config_key` = 'sys.index.sideTheme';

UPDATE `sys_config`
SET `value_type` = 'select',
    `default_value` = 'skin-purple',
    `group_key` = 'theme',
    `display_order` = 20,
    `options_json` = '[{"label":"蓝色","value":"skin-blue"},{"label":"绿色","value":"skin-green"},{"label":"紫色","value":"skin-purple"},{"label":"红色","value":"skin-red"},{"label":"黄色","value":"skin-yellow"}]',
    `ui_props_json` = NULL
WHERE `config_key` = 'sys.index.skinName';

UPDATE `sys_config`
SET `value_type` = 'switch',
    `default_value` = 'true',
    `group_key` = 'resource',
    `display_order` = 10,
    `options_json` = NULL,
    `ui_props_json` = NULL
WHERE `config_key` = 'sys.oss.previewListResource';

SET FOREIGN_KEY_CHECKS = 1;
