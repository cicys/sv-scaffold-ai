package cc.infoq.system.controller.monitor;

import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 健康检查
 * @author Pontus
 * @since 2026/5/12 16:46
 */
@AllArgsConstructor
@RestController
@RequestMapping("/monitor/health")
public class HealthController {

     /**
      * 获取健康检查信息
      */
     @GetMapping
     public String checkHealth() {
         return "ok";
     }
}
