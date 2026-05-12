package cc.infoq.common.security.config;

import cc.infoq.common.security.config.properties.SecurityProperties;
import cc.infoq.common.security.config.properties.SseProperties;
import cc.infoq.common.security.handler.AllUrlHandler;
import cc.infoq.common.utils.SpringUtils;
import cn.dev33.satoken.exception.NotLoginException;
import cn.dev33.satoken.router.SaRouter;
import cn.dev33.satoken.stp.StpUtil;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;
import org.springframework.context.support.GenericApplicationContext;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mockStatic;

@Tag("dev")
class SecurityConfigTest {

    @Test
    @DisplayName("addInterceptors: should register one sa-token interceptor and exclude health check path")
    void addInterceptorsShouldRegisterInterceptorAndExcludeHealthCheck() {
        SecurityProperties securityProperties = new SecurityProperties();
        securityProperties.setExcludes(new String[]{"/public/**"});
        SseProperties sseProperties = new SseProperties();
        sseProperties.setPath("/sse/connect");

        SecurityConfig config = new SecurityConfig(securityProperties, sseProperties);
        InterceptorRegistry registry = new InterceptorRegistry();

        config.addInterceptors(registry);

        List<?> registrations = (List<?>) ReflectionTestUtils.getField(registry, "registrations");
        assertNotNull(registrations);
        assertEquals(1, registrations.size());

        Object registration = registrations.get(0);
        @SuppressWarnings("unchecked")
        List<String> excludes = (List<String>) ReflectionTestUtils.getField(registration, "excludePatterns");
        assertNotNull(excludes);
        assertEquals(List.of("/public/**", SecurityConfig.HEALTH_CHECK_PATH, "/sse/connect"), excludes);
    }

    @Test
    @DisplayName("interceptor callbacks: should execute auth-chain lambdas")
    void interceptorCallbacksShouldExecuteAuthChainLambdas() {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/demo");
        request.addHeader("clientid", "cid");
        request.addParameter("clientid", "cid");
        MockHttpServletResponse response = new MockHttpServletResponse();
        RequestContextHolder.setRequestAttributes(new ServletRequestAttributes(request, response));

        GenericApplicationContext context = new GenericApplicationContext();
        AllUrlHandler allUrlHandler = org.mockito.Mockito.mock(AllUrlHandler.class);
        org.mockito.Mockito.when(allUrlHandler.getUrls()).thenReturn(List.of("/**"));
        context.registerBean(AllUrlHandler.class, () -> allUrlHandler);
        context.refresh();
        new SpringUtils().setApplicationContext(context);

        try (MockedStatic<StpUtil> stpUtil = mockStatic(StpUtil.class);
             MockedStatic<SaRouter> saRouter = mockStatic(SaRouter.class)) {
            cn.dev33.satoken.router.SaRouterStaff routerStaff = org.mockito.Mockito.mock(cn.dev33.satoken.router.SaRouterStaff.class);
            org.mockito.Mockito.when(routerStaff.check(org.mockito.ArgumentMatchers.<cn.dev33.satoken.fun.SaFunction>any())).thenReturn(routerStaff);
            saRouter.when(() -> SaRouter.match(List.of("/**"))).thenReturn(routerStaff);

            stpUtil.when(StpUtil::checkLogin).thenAnswer(invocation -> null);
            stpUtil.when(() -> StpUtil.getExtra("clientid")).thenReturn("cid");
            stpUtil.when(StpUtil::getLoginType).thenReturn("loginType");
            stpUtil.when(StpUtil::getTokenValue).thenReturn("token");

            ReflectionTestUtils.invokeMethod(SecurityConfig.class, "lambda$addInterceptors$0");
            ReflectionTestUtils.invokeMethod(SecurityConfig.class, "lambda$addInterceptors$1", new Object());

            assertEquals("application/json;charset=UTF-8", response.getContentType());
        } finally {
            RequestContextHolder.resetRequestAttributes();
            context.close();
        }
    }

    @Test
    @DisplayName("interceptor callbacks: should throw not-login when token clientid extra is absent")
    void interceptorCallbacksShouldThrowWhenClientIdExtraAbsent() {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/demo");
        request.addHeader("clientid", "cid");
        MockHttpServletResponse response = new MockHttpServletResponse();
        RequestContextHolder.setRequestAttributes(new ServletRequestAttributes(request, response));

        GenericApplicationContext context = new GenericApplicationContext();
        AllUrlHandler allUrlHandler = org.mockito.Mockito.mock(AllUrlHandler.class);
        org.mockito.Mockito.when(allUrlHandler.getUrls()).thenReturn(List.of("/**"));
        context.registerBean(AllUrlHandler.class, () -> allUrlHandler);
        context.refresh();
        new SpringUtils().setApplicationContext(context);

        try (MockedStatic<StpUtil> stpUtil = mockStatic(StpUtil.class);
             MockedStatic<SaRouter> saRouter = mockStatic(SaRouter.class)) {
            cn.dev33.satoken.router.SaRouterStaff routerStaff = org.mockito.Mockito.mock(cn.dev33.satoken.router.SaRouterStaff.class);
            org.mockito.Mockito.when(routerStaff.check(org.mockito.ArgumentMatchers.<cn.dev33.satoken.fun.SaFunction>any())).thenReturn(routerStaff);
            saRouter.when(() -> SaRouter.match(List.of("/**"))).thenReturn(routerStaff);

            stpUtil.when(StpUtil::checkLogin).thenAnswer(invocation -> null);
            stpUtil.when(() -> StpUtil.getExtra("clientid")).thenReturn(null);
            stpUtil.when(StpUtil::getLoginType).thenReturn("loginType");
            stpUtil.when(StpUtil::getTokenValue).thenReturn("token");

            assertThrows(NotLoginException.class,
                () -> ReflectionTestUtils.invokeMethod(SecurityConfig.class, "lambda$addInterceptors$0"));
        } finally {
            RequestContextHolder.resetRequestAttributes();
            context.close();
        }
    }
}
