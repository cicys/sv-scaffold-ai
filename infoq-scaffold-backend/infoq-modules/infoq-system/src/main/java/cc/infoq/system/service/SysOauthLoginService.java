package cc.infoq.system.service;

import cc.infoq.common.oauth.domain.OAuthAuthorizationResult;
import cc.infoq.common.oauth.domain.OAuthCallbackRequest;

public interface SysOauthLoginService {

    OAuthAuthorizationResult createAuthorization(String providerCode, String clientId, String redirect, String browserBinding);

    String handleCallback(String providerCode, OAuthCallbackRequest callbackRequest, String browserBinding);

    String buildErrorRedirect(String message);
}
