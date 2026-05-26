package cc.infoq.system.controller.monitor;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import static org.junit.jupiter.api.Assertions.*;

@Tag("dev")
class HealthControllerTest {

    @Test
    @DisplayName("checkHealth: should expose /monitor/health and return ok")
    void checkHealthShouldExposeMonitorHealthAndReturnOk() throws NoSuchMethodException {
        RequestMapping requestMapping = HealthController.class.getAnnotation(RequestMapping.class);
        assertNotNull(requestMapping);
        assertArrayEquals(new String[]{"/monitor/health"}, requestMapping.value());

        GetMapping getMapping = HealthController.class.getMethod("checkHealth").getAnnotation(GetMapping.class);
        assertNotNull(getMapping);
        assertEquals("ok", new HealthController().checkHealth());
    }
}
