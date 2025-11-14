package com.example.dockertest.controller;
import org.springframework.web.bind.annotation.*;

@RestController
    @RequestMapping("/health")
public class HealthCheck {

    @GetMapping
    public String healchk(){
        return "Hello";
    }
}
    