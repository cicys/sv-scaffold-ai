package cc.infoq.system.service;


import cc.infoq.common.exception.ServiceException;
import cc.infoq.common.utils.SpringUtils;
import cc.infoq.system.domain.vo.LoginVo;
import cc.infoq.system.domain.vo.SysClientVo;
import cn.dev33.satoken.stp.parameter.SaLoginParameter;

/**
 * 授权策略
 *
 * @author Pontus
 */
public interface AuthStrategy {

    String BASE_NAME = "AuthStrategy";

    /**
     * 登录
     *
     * @param body      登录对象
     * @param client    授权管理视图对象
     * @param grantType 授权类型
     * @return 登录验证信息
     */
    static LoginVo login(String body, SysClientVo client, String grantType) {
        // 授权类型和客户端id
        String beanName = grantType + BASE_NAME;
        if (!SpringUtils.containsBean(beanName)) {
            throw new ServiceException("授权类型不正确!");
        }
        AuthStrategy instance = SpringUtils.getBean(beanName);
        return instance.login(body, client);
    }

    static void applyClientTimeout(SaLoginParameter model, SysClientVo client) {
        if (client.getTimeout() != null) {
            model.setTimeout(client.getTimeout());
        }
        if (client.getActiveTimeout() != null) {
            model.setActiveTimeout(client.getActiveTimeout());
        }
    }

    /**
     * 登录
     *
     * @param body   登录对象
     * @param client 授权管理视图对象
     * @return 登录验证信息
     */
    LoginVo login(String body, SysClientVo client);

}
