package com.drinbol.writerllm.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class RootController {

    @GetMapping("/")
    fun hello(): Map<String, String> {
        return mapOf("message" to "Hello, World!")
    }
}