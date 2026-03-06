package com.example.helloworld;

import java.time.Instant;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

  @GetMapping("/")
  public String root() {
    return "Hello, World!";
  }

  @GetMapping("/health")
  public Map<String, Object> health() {
    return Map.of(
        "status", "ok",
        "timestamp", Instant.now().toString()
    );
  }
}
