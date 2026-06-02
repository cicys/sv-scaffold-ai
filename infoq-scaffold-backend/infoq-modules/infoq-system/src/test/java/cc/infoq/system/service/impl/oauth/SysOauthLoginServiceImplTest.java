package cc.infoq.system.service.impl.oauth;

import cc.infoq.common.oauth.config.properties.OAuthProperties;
import cc.infoq.common.oauth.domain.OAuthCallbackRequest;
import cc.infoq.common.oauth.domain.OAuthCallbackResult;
import cc.infoq.common.oauth.domain.OAuthIdentityProfile;
import cc.infoq.common.oauth.service.OAuthFlowService;
import cc.infoq.common.oauth.service.OAuthLoginTicketService;
import cc.infoq.system.domain.entity.SysOauthIdentity;
import cc.infoq.system.domain.vo.SysOauthIdentityVo;
import cc.infoq.system.domain.vo.SysOauthProviderVo;
import cc.infoq.system.mapper.SysOauthIdentityMapper;
import cc.infoq.system.service.SysConfigService;
import cc.infoq.system.service.SysLoginService;
import cc.infoq.system.service.SysOauthAutoRegistrationService;
import cc.infoq.system.service.SysOauthProviderService;
import com.baomidou.mybatisplus.core.metadata.TableInfoHelper;
import org.apache.ibatis.builder.MapperBuilderAssistant;
import org.apache.ibatis.session.Configuration;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.transaction.annotation.Transactional;

import java.lang.reflect.Method;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@Tag("dev")
class SysOauthLoginServiceImplTest {

    @Mock
    private OAuthFlowService oAuthFlowService;
    @Mock
    private OAuthLoginTicketService ticketService;
    @Mock
    private SysOauthProviderService providerService;
    @Mock
    private SysOauthIdentityMapper identityMapper;
    @Mock
    private SysConfigService configService;
    @Mock
    private SysLoginService loginService;
    @Mock
    private SysOauthAutoRegistrationService autoRegistrationService;

    @BeforeEach
    void setUp() {
        if (TableInfoHelper.getTableInfo(SysOauthIdentity.class) == null) {
            TableInfoHelper.initTableInfo(new MapperBuilderAssistant(new Configuration(), ""), SysOauthIdentity.class);
        }
    }

    @Test
    @DisplayName("transaction boundary: callback should not wrap external profile fetch")
    void callbackShouldNotDeclareTransaction() throws NoSuchMethodException {
        Method callback = SysOauthLoginServiceImpl.class.getMethod(
            "handleCallback", String.class, OAuthCallbackRequest.class, String.class);
        Method autoRegister = SysOauthAutoRegistrationServiceImpl.class.getMethod(
            "autoRegisterAndBind", OAuthIdentityProfile.class);

        assertFalse(callback.isAnnotationPresent(Transactional.class));
        assertTrue(autoRegister.isAnnotationPresent(Transactional.class));
    }

    @Test
    @DisplayName("handleCallback: should use existing identity without auto register")
    void handleCallbackShouldUseExistingIdentityWithoutAutoRegister() {
        SysOauthLoginServiceImpl service = buildService();
        OAuthIdentityProfile profile = profile();
        OAuthCallbackRequest request = callbackRequest();
        SysOauthIdentityVo identity = new SysOauthIdentityVo();
        identity.setIdentityId(10L);
        identity.setUserId(100L);
        identity.setStatus("0");
        when(providerService.requireLoginProvider("github")).thenReturn(provider());
        when(oAuthFlowService.handleCallback(eq("github"), any(OAuthCallbackRequest.class), eq(""))).thenReturn(callbackResult(profile));
        when(identityMapper.selectVoOne(any())).thenReturn(identity);
        when(ticketService.createTicket(any())).thenReturn("ticket-1");
        when(oAuthFlowService.getProperties()).thenReturn(oauthProperties());

        service.handleCallback("github", request, "");

        verify(autoRegistrationService, never()).autoRegisterAndBind(any());
    }

    @Test
    @DisplayName("handleCallback: should delegate missing identity auto registration to separate bean")
    void handleCallbackShouldDelegateMissingIdentityAutoRegistration() {
        SysOauthLoginServiceImpl service = buildService();
        OAuthIdentityProfile profile = profile();
        OAuthCallbackRequest request = callbackRequest();
        when(providerService.requireLoginProvider("github")).thenReturn(provider());
        when(oAuthFlowService.handleCallback(eq("github"), any(OAuthCallbackRequest.class), eq(""))).thenReturn(callbackResult(profile));
        when(identityMapper.selectVoOne(any())).thenReturn(null);
        when(configService.selectRegisterEnabled()).thenReturn(true);
        when(configService.selectInviteRegisterEnabled()).thenReturn(false);
        when(autoRegistrationService.autoRegisterAndBind(profile)).thenReturn(101L);
        when(ticketService.createTicket(any())).thenReturn("ticket-1");
        when(oAuthFlowService.getProperties()).thenReturn(oauthProperties());

        service.handleCallback("github", request, "");

        verify(autoRegistrationService).autoRegisterAndBind(profile);
    }

    private SysOauthLoginServiceImpl buildService() {
        return new SysOauthLoginServiceImpl(
            oAuthFlowService,
            ticketService,
            providerService,
            identityMapper,
            configService,
            loginService,
            autoRegistrationService);
    }

    private SysOauthProviderVo provider() {
        SysOauthProviderVo provider = new SysOauthProviderVo();
        provider.setProviderCode("github");
        provider.setAllowAutoRegister("0");
        return provider;
    }

    private OAuthCallbackRequest callbackRequest() {
        OAuthCallbackRequest request = new OAuthCallbackRequest();
        request.setCode("code-1");
        request.setState("state-1");
        return request;
    }

    private OAuthCallbackResult callbackResult(OAuthIdentityProfile profile) {
        OAuthCallbackResult result = new OAuthCallbackResult();
        result.setClientId("pc");
        result.setRedirect("/");
        result.setBrowserBinding("");
        result.setProfile(profile);
        return result;
    }

    private OAuthIdentityProfile profile() {
        OAuthIdentityProfile profile = new OAuthIdentityProfile();
        profile.setProviderCode("github");
        profile.setProviderKey("github");
        profile.setSubject("123");
        return profile;
    }

    private OAuthProperties oauthProperties() {
        OAuthProperties properties = new OAuthProperties();
        properties.setFrontendCallbackPath("/oauth/callback");
        return properties;
    }
}
