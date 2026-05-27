package cc.infoq.common.security.auth;

/**
 * Explicit authentication failure used before the HTTP exception adapter maps it to 401.
 */
public class SecurityAuthenticationException extends RuntimeException {

    public SecurityAuthenticationException(String message) {
        super(message);
    }

    public SecurityAuthenticationException(String message, Throwable cause) {
        super(message, cause);
    }

}
