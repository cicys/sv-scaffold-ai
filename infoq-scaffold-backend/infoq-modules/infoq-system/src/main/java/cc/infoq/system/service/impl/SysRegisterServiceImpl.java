package cc.infoq.system.service.impl;

import cc.infoq.common.constant.Constants;
import cc.infoq.common.domain.model.RegisterBody;
import cc.infoq.common.enums.EmailCodeScene;
import cc.infoq.common.enums.UserType;
import cc.infoq.common.exception.user.UserException;
import cc.infoq.common.log.event.LoginInfoEvent;
import cc.infoq.common.utils.MessageUtils;
import cc.infoq.common.utils.ServletUtils;
import cc.infoq.common.utils.SpringUtils;
import cc.infoq.system.domain.bo.SysUserBo;
import cc.infoq.system.service.AuthEmailCodeService;
import cc.infoq.system.service.SysRegisterService;
import cc.infoq.system.service.SysUserService;
import cn.hutool.crypto.digest.BCrypt;
import jakarta.servlet.http.HttpServletRequest;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * 注册校验方法
 * @author Pontus
 */
@AllArgsConstructor
@Service
public class SysRegisterServiceImpl implements SysRegisterService {

    private final SysUserService userService;
    private final AuthEmailCodeService authEmailCodeService;

    /**
     * 注册
     */
    public void register(RegisterBody registerBody) {
        String username = registerBody.getUsername();
        String password = registerBody.getPassword();
        String email = registerBody.getEmail();
        String userType = UserType.SYS_USER.getUserType();
        SysUserBo sysUser = new SysUserBo();
        sysUser.setUserName(username);
        sysUser.setNickName(username);
        sysUser.setPassword(BCrypt.hashpw(password));
        sysUser.setEmail(email);
        sysUser.setUserType(userType);

        if (!authEmailCodeService.validateCode(EmailCodeScene.REGISTER, email, registerBody.getEmailCode())) {
            throw new UserException("user.jcaptcha.error");
        }
        if (!userService.checkUserNameUnique(sysUser)) {
            throw new UserException("user.register.save.error", username);
        }
        if (!userService.checkEmailUnique(sysUser)) {
            throw new UserException("user.email.already.exists", email);
        }
        boolean regFlag = userService.registerUser(sysUser);
        if (!regFlag) {
            throw new UserException("user.register.error");
        }
        recordLoginInfo(username, Constants.REGISTER, MessageUtils.message("user.register.success"));
    }

    /**
     * 记录登录信息
     *
     * @param username 用户名
     * @param status   状态
     * @param message  消息内容
     * @return
     */
    private void recordLoginInfo(String username, String status, String message) {
        LoginInfoEvent loginInfoEvent = new LoginInfoEvent();
        loginInfoEvent.setUsername(username);
        loginInfoEvent.setStatus(status);
        loginInfoEvent.setMessage(message);
        loginInfoEvent.setRequest(resolveCurrentRequest());
        SpringUtils.context().publishEvent(loginInfoEvent);
    }

    private HttpServletRequest resolveCurrentRequest() {
        try {
            return ServletUtils.getRequest();
        } catch (IllegalStateException ignored) {
            return null;
        }
    }
}
