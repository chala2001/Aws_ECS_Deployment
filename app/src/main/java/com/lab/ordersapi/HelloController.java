package com.lab.ordersapi;

import java.net.InetAddress;
import java.time.Instant;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    // Comes from an environment variable; the ECS task definition will set this.
    @Value("${APP_VERSION:v1}")
    private String version;

    @GetMapping("/")
    public Map<String, Object> home() throws Exception {
        return Map.of(
            "app", "orders-api",
            "version", version,
            "servedBy", InetAddress.getLocalHost().getHostName(), // which task/container answered
            "time", Instant.now().toString()
        );
    }

    // The ALB will call this every few seconds. 200 = healthy, anything else = unhealthy.
    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP");
    }
}
