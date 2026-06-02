package cc.infoq.common.oauth.config.properties;

import cc.infoq.common.utils.StringUtils;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * OAuth login properties.
 */
@Data
@ConfigurationProperties(prefix = "oauth")
public class OAuthProperties {

    /**
     * Global OAuth login switch.
     */
    private Boolean enabled = false;

    /**
     * Pending authorization state TTL.
     */
    private Duration stateTtl = Duration.ofMinutes(10);

    /**
     * Login ticket TTL.
     */
    private Duration ticketTtl = Duration.ofMinutes(2);

    /**
     * Global auto-register switch for OAuth identities.
     */
    private Boolean autoRegisterEnabled = true;

    /**
     * Reject OAuth auto-register while invite registration is enabled.
     */
    private Boolean requireInviteWhenInviteRegisterEnabled = true;

    /**
     * Frontend callback route. Keep it same-origin relative.
     */
    private String frontendCallbackPath = "/oauth/callback";

    /**
     * Provider client settings, keyed by provider code.
     */
    private Map<String, Provider> providers = new LinkedHashMap<>();

    public boolean isEnabled() {
        return Boolean.TRUE.equals(enabled);
    }

    public boolean isAutoRegisterEnabled() {
        return Boolean.TRUE.equals(autoRegisterEnabled);
    }

    public boolean isRequireInviteWhenInviteRegisterEnabled() {
        return Boolean.TRUE.equals(requireInviteWhenInviteRegisterEnabled);
    }

    @Data
    public static class Provider {

        private String clientId;

        private String clientSecret;

        private String redirectUri;

        private String authorizeUri;

        private String tokenUri;

        private String userInfoUri;

        private List<String> scopes = new ArrayList<>();

        private Boolean pkceEnabled = true;

        public boolean hasClientSettings() {
            return StringUtils.isNotBlank(clientId)
                && StringUtils.isNotBlank(clientSecret)
                && StringUtils.isNotBlank(redirectUri);
        }

        public boolean isPkceEnabled() {
            return Boolean.TRUE.equals(pkceEnabled);
        }
    }
}
