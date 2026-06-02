package cc.infoq.system.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * OAuth provider option for login pages.
 */
@Data
public class OAuthProviderOptionVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private String providerCode;

    private String providerName;
}
