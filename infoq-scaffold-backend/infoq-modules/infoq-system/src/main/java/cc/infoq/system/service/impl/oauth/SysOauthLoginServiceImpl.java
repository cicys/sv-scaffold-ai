package cc.infoq.system.service.impl.oauth;

import cc.infoq.common.constant.Constants;
import cc.infoq.common.constant.SystemConstants;
import cc.infoq.common.exception.ServiceException;
import cc.infoq.common.oauth.domain.*;
import cc.infoq.common.oauth.service.OAuthFlowService;
import cc.infoq.common.oauth.service.OAuthLoginTicketService;
import cc.infoq.common.oauth.support.OAuthRedirectValidator;
import cc.infoq.common.utils.MessageUtils;
import cc.infoq.common.utils.StringUtils;
import cc.infoq.system.domain.entity.SysOauthIdentity;
import cc.infoq.system.domain.vo.SysOauthIdentityVo;
import cc.infoq.system.domain.vo.SysOauthProviderVo;
import cc.infoq.system.mapper.SysOauthIdentityMapper;
import cc.infoq.system.service.*;
import cn.hutool.crypto.SecureUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Date;

@Slf4j
@Service
@RequiredArgsConstructor
public class SysOauthLoginServiceImpl implements SysOauthLoginService {

    private final OAuthFlowService oAuthFlowService;
    private final OAuthLoginTicketService ticketService;
    private final SysOauthProviderService providerService;
    private final SysOauthIdentityMapper identityMapper;
    private final SysConfigService configService;
    private final SysLoginService loginService;
    private final SysOauthAutoRegistrationService autoRegistrationService;

    @Override
    public OAuthAuthorizationResult createAuthorization(String providerCode, String clientId, String redirect, String browserBinding) {
        providerService.requireLoginProvider(providerCode);
        return oAuthFlowService.createAuthorization(providerCode, clientId, redirect, browserBinding);
    }

    @Override
    public String handleCallback(String providerCode, OAuthCallbackRequest callbackRequest, String browserBinding) {
        SysOauthProviderVo provider = providerService.requireLoginProvider(providerCode);
        OAuthCallbackResult callbackResult = oAuthFlowService.handleCallback(providerCode, callbackRequest, browserBinding);
        Long userId = resolveUserId(provider, callbackResult.getProfile());
        OAuthLoginTicketPayload payload = new OAuthLoginTicketPayload();
        payload.setUserId(userId);
        payload.setClientId(callbackResult.getClientId());
        payload.setProviderCode(callbackResult.getProfile().getProviderCode());
        payload.setProviderKey(callbackResult.getProfile().getProviderKey());
        payload.setProviderSubject(callbackResult.getProfile().getSubject());
        payload.setRedirect(callbackResult.getRedirect());
        payload.setBrowserBinding(callbackResult.getBrowserBinding());
        String ticket = ticketService.createTicket(payload);
        return buildSuccessRedirect(ticket, callbackResult.getRedirect());
    }

    @Override
    public String buildErrorRedirect(String message) {
        String callbackPath = OAuthRedirectValidator.requireSafeRelativeRedirect(oAuthFlowService.getProperties().getFrontendCallbackPath());
        return UriComponentsBuilder.fromPath(callbackPath)
            .queryParam("error", "oauth_failed")
            .queryParam("message", StringUtils.blankToDefault(message, MessageUtils.message("auth.oauth.callback.failed")))
            .build()
            .encode()
            .toUriString();
    }

    private String buildSuccessRedirect(String ticket, String redirect) {
        String callbackPath = OAuthRedirectValidator.requireSafeRelativeRedirect(oAuthFlowService.getProperties().getFrontendCallbackPath());
        return UriComponentsBuilder.fromPath(callbackPath)
            .queryParam("loginTicket", ticket)
            .queryParam("redirect", OAuthRedirectValidator.requireSafeRelativeRedirect(redirect))
            .build()
            .encode()
            .toUriString();
    }

    private Long resolveUserId(SysOauthProviderVo provider, OAuthIdentityProfile profile) {
        SysOauthIdentityVo existing = findIdentity(profile);
        if (existing != null) {
            if (!SystemConstants.NORMAL.equals(existing.getStatus())) {
                recordOAuthFailure(profile, "auth.oauth.identity.disabled");
                throw new ServiceException(MessageUtils.message("auth.oauth.identity.disabled"));
            }
            updateLastLogin(existing.getIdentityId());
            return existing.getUserId();
        }
        if (!SystemConstants.NORMAL.equals(provider.getAllowAutoRegister())
            || !oAuthFlowService.getProperties().isAutoRegisterEnabled()) {
            recordOAuthFailure(profile, "auth.oauth.auto.register.disabled");
            throw new ServiceException(MessageUtils.message("auth.oauth.auto.register.disabled"));
        }
        if (!configService.selectRegisterEnabled()) {
            recordOAuthFailure(profile, "auth.oauth.register.disabled");
            throw new ServiceException(MessageUtils.message("auth.oauth.register.disabled"));
        }
        if (configService.selectInviteRegisterEnabled()
            && oAuthFlowService.getProperties().isRequireInviteWhenInviteRegisterEnabled()) {
            recordOAuthFailure(profile, "auth.oauth.invite.required");
            throw new ServiceException(MessageUtils.message("auth.oauth.invite.required"));
        }
        return autoRegisterAndBind(profile);
    }

    private Long autoRegisterAndBind(OAuthIdentityProfile profile) {
        return autoRegistrationService.autoRegisterAndBind(profile);
    }

    private SysOauthIdentityVo findIdentity(OAuthIdentityProfile profile) {
        return identityMapper.selectVoOne(new LambdaQueryWrapper<SysOauthIdentity>()
            .eq(SysOauthIdentity::getProviderCode, profile.getProviderCode())
            .eq(SysOauthIdentity::getProviderKey, profile.getProviderKey())
            .eq(SysOauthIdentity::getProviderSubject, profile.getSubject()));
    }

    private void updateLastLogin(Long identityId) {
        identityMapper.update(null, new LambdaUpdateWrapper<SysOauthIdentity>()
            .set(SysOauthIdentity::getLastLoginTime, new Date())
            .eq(SysOauthIdentity::getIdentityId, identityId));
    }

    private String shortHash(String value) {
        return SecureUtil.sha256(StringUtils.blankToDefault(value, StringUtils.EMPTY)).substring(0, 16);
    }

    private void recordOAuthFailure(OAuthIdentityProfile profile, String messageKey) {
        loginService.recordLoginInfo("oauth:" + profile.getProviderCode(), Constants.LOGIN_FAIL, MessageUtils.message(messageKey));
        log.info("OAuth login rejected, provider:{}, subjectHash:{}, reason:{}",
            profile.getProviderCode(), shortHash(profile.getSubject()), messageKey);
    }
}
