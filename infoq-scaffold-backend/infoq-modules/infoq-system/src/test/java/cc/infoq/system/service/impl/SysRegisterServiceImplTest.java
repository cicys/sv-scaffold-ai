package cc.infoq.system.service.impl;

import cc.infoq.common.domain.model.RegisterBody;
import cc.infoq.common.enums.EmailCodeScene;
import cc.infoq.common.exception.user.UserException;
import cc.infoq.common.log.event.LoginInfoEvent;
import cc.infoq.common.utils.SpringUtils;
import cc.infoq.system.domain.bo.SysUserBo;
import cc.infoq.system.service.AuthEmailCodeService;
import cc.infoq.system.service.SysUserService;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;
import org.redisson.api.RedissonClient;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.GenericApplicationContext;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@Tag("dev")
class SysRegisterServiceImplTest {

    @Mock
    private SysUserService userService;
    @Mock
    private AuthEmailCodeService authEmailCodeService;

    @BeforeAll
    static void initSpringContext() {
        GenericApplicationContext context = new GenericApplicationContext();
        context.registerBean(RedissonClient.class, () -> mock(RedissonClient.class));
        context.refresh();
        new SpringUtils().setApplicationContext(context);
    }

    @Test
    @DisplayName("register: should throw when email code mismatches")
    void registerShouldThrowWhenEmailCodeMismatches() {
        SysRegisterServiceImpl service = new SysRegisterServiceImpl(userService, authEmailCodeService);
        RegisterBody body = buildBody();
        when(authEmailCodeService.validateCode(EmailCodeScene.REGISTER, "admin@infoq.cc", "1234")).thenReturn(false);

        assertThrows(UserException.class, () -> service.register(body));
    }

    @Test
    @DisplayName("register: should throw when username already exists")
    void registerShouldThrowWhenUserExists() {
        SysRegisterServiceImpl service = new SysRegisterServiceImpl(userService, authEmailCodeService);
        RegisterBody body = buildBody();
        when(authEmailCodeService.validateCode(EmailCodeScene.REGISTER, "admin@infoq.cc", "1234")).thenReturn(true);
        when(userService.checkUserNameUnique(any(SysUserBo.class))).thenReturn(false);

        assertThrows(UserException.class, () -> service.register(body));
    }

    @Test
    @DisplayName("register: should throw when email already exists")
    void registerShouldThrowWhenEmailExists() {
        SysRegisterServiceImpl service = new SysRegisterServiceImpl(userService, authEmailCodeService);
        RegisterBody body = buildBody();
        when(authEmailCodeService.validateCode(EmailCodeScene.REGISTER, "admin@infoq.cc", "1234")).thenReturn(true);
        when(userService.checkUserNameUnique(any(SysUserBo.class))).thenReturn(true);
        when(userService.checkEmailUnique(any(SysUserBo.class))).thenReturn(false);

        assertThrows(UserException.class, () -> service.register(body));
    }

    @Test
    @DisplayName("register: should create user and record success event")
    void registerShouldCreateUserAndPublishEvent() {
        SysRegisterServiceImpl service = new SysRegisterServiceImpl(userService, authEmailCodeService);
        RegisterBody body = buildBody();
        ApplicationContext context = mock(ApplicationContext.class);
        HttpServletRequest request = mock(HttpServletRequest.class);
        when(authEmailCodeService.validateCode(EmailCodeScene.REGISTER, "admin@infoq.cc", "1234")).thenReturn(true);
        when(userService.checkUserNameUnique(any(SysUserBo.class))).thenReturn(true);
        when(userService.checkEmailUnique(any(SysUserBo.class))).thenReturn(true);
        when(userService.registerUser(any(SysUserBo.class))).thenReturn(true);

        try (MockedStatic<SpringUtils> springUtils = mockStatic(SpringUtils.class);
             MockedStatic<cc.infoq.common.utils.ServletUtils> servletUtils = mockStatic(cc.infoq.common.utils.ServletUtils.class)) {
            springUtils.when(SpringUtils::context).thenReturn(context);
            servletUtils.when(cc.infoq.common.utils.ServletUtils::getRequest).thenReturn(request);

            service.register(body);

            verify(userService).registerUser(any(SysUserBo.class));
            verify(context).publishEvent(any(LoginInfoEvent.class));
        }
    }

    private RegisterBody buildBody() {
        RegisterBody body = new RegisterBody();
        body.setUsername("admin");
        body.setPassword("Admin@123");
        body.setEmail("admin@infoq.cc");
        body.setEmailCode("1234");
        return body;
    }
}
