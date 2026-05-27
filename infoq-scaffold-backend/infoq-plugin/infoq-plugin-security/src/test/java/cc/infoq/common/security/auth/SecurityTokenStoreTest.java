package cc.infoq.common.security.auth;

import cc.infoq.common.constant.CacheConstants;
import cc.infoq.common.domain.dto.UserOnlineDTO;
import cc.infoq.common.domain.model.LoginUser;
import cc.infoq.common.redis.utils.RedisUtils;
import cc.infoq.common.utils.SpringUtils;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;
import org.redisson.api.RSet;
import org.redisson.api.RedissonClient;
import org.springframework.context.support.GenericApplicationContext;

import java.time.Duration;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@Tag("dev")
class SecurityTokenStoreTest {

    @Test
    @DisplayName("digest/key: should use sha256 digest as internal redis key")
    void digestKeyShouldUseSha256DigestAsInternalRedisKey() {
        SecurityTokenStore store = new SecurityTokenStore();
        SecurityTokenService tokenService = new SecurityTokenService(properties(), mock(SecurityTokenStore.class));

        String digest = tokenService.digest("clear-access-token");

        assertEquals(64, digest.length());
        assertFalse(digest.contains("clear-access-token"));
        assertEquals(digest, tokenService.digest("clear-access-token"));
        assertEquals(SecurityAuthNames.TOKEN_SESSION_KEY_PREFIX + digest, store.sessionKey(digest));
        assertEquals(SecurityAuthNames.TOKEN_REVOKED_KEY_PREFIX + digest, store.revokedKey(digest));
        assertEquals(SecurityAuthNames.TOKEN_LOGIN_INDEX_KEY_PREFIX + "sys_user:1", store.loginIndexKey("sys_user:1"));
        assertEquals(SecurityAuthNames.TOKEN_USER_INDEX_KEY_PREFIX + "1", store.userIndexKey(1L));
        assertEquals(SecurityAuthNames.TOKEN_ROLE_INDEX_KEY_PREFIX + "2", store.roleIndexKey(2L));
    }

    @Test
    @DisplayName("save: should write session by digest and legacy online key by clear token")
    @SuppressWarnings("unchecked")
    void saveShouldWriteSessionByDigestAndLegacyOnlineKeyByClearToken() {
        GenericApplicationContext context = new GenericApplicationContext();
        RedissonClient redissonClient = mock(RedissonClient.class);
        RSet<String> set = mock(RSet.class);
        when(redissonClient.<String>getSet(anyString())).thenReturn(set);
        when(set.expire(any(Duration.class))).thenReturn(true);
        context.registerBean(RedissonClient.class, () -> redissonClient);
        context.refresh();
        new SpringUtils().setApplicationContext(context);

        SecurityTokenStore store = new SecurityTokenStore();
        SecurityTokenSession session = session("digest-1");

        try (MockedStatic<RedisUtils> redisUtils = mockStatic(RedisUtils.class)) {
            redisUtils.when(RedisUtils::getClient).thenReturn(redissonClient);

            store.save("clear-access-token", session);

            redisUtils.verify(() -> RedisUtils.setCacheObject(eq(store.sessionKey("digest-1")), eq(session), any(Duration.class)));
            redisUtils.verify(() -> RedisUtils.setCacheObject(
                eq(CacheConstants.ONLINE_TOKEN_KEY + "clear-access-token"),
                argThat((UserOnlineDTO dto) -> "clear-access-token".equals(dto.getTokenId())),
                any(Duration.class)
            ));
            redisUtils.verify(() -> RedisUtils.addCacheSet(store.loginIndexKey("sys_user:1"), "digest-1"));
            redisUtils.verify(() -> RedisUtils.addCacheSet(store.userIndexKey(1L), "digest-1"));
        } finally {
            context.close();
        }
    }

    private SecurityTokenProperties properties() {
        SecurityTokenProperties properties = new SecurityTokenProperties();
        properties.setSecret("local-test-token-secret");
        return properties;
    }

    private SecurityTokenSession session(String digest) {
        LoginUser loginUser = new LoginUser();
        loginUser.setUserId(1L);
        loginUser.setUserType("sys_user");
        loginUser.setUsername("admin");
        loginUser.setClientKey("client-1");
        loginUser.setDeviceType("pc");
        SecurityTokenSession session = new SecurityTokenSession();
        session.setJwtId("jwt-1");
        session.setAccessToken("clear-access-token");
        session.setTokenDigest(digest);
        session.setLoginId("sys_user:1");
        session.setUserId(1L);
        session.setUserType("sys_user");
        session.setClientId("client-1");
        session.setDeviceType("pc");
        session.setLoginTime(System.currentTimeMillis());
        session.setExpireTime(System.currentTimeMillis() + 60_000L);
        session.setLoginUser(loginUser);
        return session;
    }

}
