package cc.infoq.common.security.auth;

import cc.infoq.common.utils.StringUtils;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.nio.charset.StandardCharsets;
import java.time.Duration;

/**
 * Token settings for the Spring Security authentication base.
 */
@Data
@ConfigurationProperties(prefix = "security.token")
public class SecurityTokenProperties {

    private static final String LEGACY_DEMO_SECRET = "abcdefghijklmnopqrstuvwxyz";

    /**
     * Header name used by current frontend clients.
     */
    private String tokenName = SecurityAuthNames.AUTHORIZATION;

    /**
     * Authorization token prefix.
     */
    private String tokenPrefix = SecurityAuthNames.BEARER;

    /**
     * HMAC signing secret. It must come from external config.
     */
    private String secret;

    /**
     * Fixed token lifetime. The legacy default was 30 days.
     */
    private Duration ttl = Duration.ofDays(30);

    /**
     * Inactivity timeout. Negative means disabled.
     */
    private Duration activeTimeout = Duration.ofSeconds(-1);

    /**
     * Allows SSE/WebSocket style query token.
     */
    private boolean queryTokenEnabled = true;

    private String queryTokenName = SecurityAuthNames.AUTHORIZATION;

    private String clientIdHeaderName = SecurityAuthNames.CLIENT_ID;

    private String clientIdQueryName = SecurityAuthNames.CLIENT_ID;

    private String issuer = "infoq-scaffold";

    private Duration allowedClockSkew = Duration.ZERO;

    public byte[] requireSigningSecret() {
        if (StringUtils.isBlank(secret)) {
            throw new SecurityAuthenticationException("security.token.secret is required");
        }
        String normalized = secret.trim();
        if (LEGACY_DEMO_SECRET.equals(normalized)) {
            throw new SecurityAuthenticationException("security.token.secret must not reuse the legacy demo token secret");
        }
        return normalized.getBytes(StandardCharsets.UTF_8);
    }

    public long ttlSeconds() {
        return ttl.getSeconds();
    }

    public long activeTimeoutSeconds() {
        return activeTimeout.getSeconds();
    }

}
