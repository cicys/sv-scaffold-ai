package cc.infoq.common.security.config;

/**
 * Shared security route constants.
 *
 * @author Pontus
 */
public final class SecurityConfig {

    public static final String HEALTH_CHECK_PATH = "/monitor/health";

    public static final String HEALTH_CHECK_PATTERN = HEALTH_CHECK_PATH + "/**";

    private SecurityConfig() {
    }
}
