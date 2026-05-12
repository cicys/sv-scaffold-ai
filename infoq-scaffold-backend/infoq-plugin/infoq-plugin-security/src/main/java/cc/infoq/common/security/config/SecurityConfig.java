package cc.infoq.common.security.config;

import cc.infoq.common.satoken.utils.LoginHelper;
import cc.infoq.common.security.config.properties.SecurityProperties;
import cc.infoq.common.security.config.properties.SseProperties;
import cc.infoq.common.security.handler.AllUrlHandler;
import cc.infoq.common.utils.ServletUtils;
import cc.infoq.common.utils.SpringUtils;
import cc.infoq.common.utils.StringUtils;
import cn.dev33.satoken.exception.NotLoginException;
import cn.dev33.satoken.interceptor.SaInterceptor;
import cn.dev33.satoken.router.SaRouter;
import cn.dev33.satoken.stp.StpUtil;
import cn.dev33.satoken.util.SaTokenConsts;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Security configuration.
 *
 * @author Pontus
 */
@Slf4j
@AutoConfiguration
@EnableConfigurationProperties({SecurityProperties.class, SseProperties.class})
@AllArgsConstructor
public class SecurityConfig implements WebMvcConfigurer {

    static final String HEALTH_CHECK_PATH = "/monitor/health";

    private final SecurityProperties securityProperties;
    private final SseProperties sseProperties;

    /**
     * Register the sa-token interceptor.
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new SaInterceptor(handler -> {
                AllUrlHandler allUrlHandler = SpringUtils.getBean(AllUrlHandler.class);
                SaRouter
                    .match(allUrlHandler.getUrls())
                    .check(() -> {
                        HttpServletRequest request = ServletUtils.getRequest();
                        HttpServletResponse response = ServletUtils.getResponse();
                        response.setContentType(SaTokenConsts.CONTENT_TYPE_APPLICATION_JSON);
                        StpUtil.checkLogin();

                        String headerCid = request.getHeader(LoginHelper.CLIENT_KEY);
                        String paramCid = ServletUtils.getParameter(LoginHelper.CLIENT_KEY);
                        Object clientIdExtra = StpUtil.getExtra(LoginHelper.CLIENT_KEY);
                        if (clientIdExtra == null) {
                            throw NotLoginException.newInstance(StpUtil.getLoginType(),
                                "-100", "Token is missing clientId",
                                StpUtil.getTokenValue());
                        }
                        String clientId = clientIdExtra.toString();
                        if (!StringUtils.equalsAny(clientId, headerCid, paramCid)) {
                            throw NotLoginException.newInstance(StpUtil.getLoginType(),
                                "-100", "Client ID does not match token",
                                StpUtil.getTokenValue());
                        }
                    });
            })).addPathPatterns("/**")
            .excludePathPatterns(securityProperties.getExcludes())
            .excludePathPatterns(HEALTH_CHECK_PATH)
            .excludePathPatterns(sseProperties.getPath());
    }
}
