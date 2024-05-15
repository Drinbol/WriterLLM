package com.drinbol.writerllm.controller
import com.drinbol.writerllm.domain.User
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/users")
class UserController {

    @GetMapping
    fun getUsers(): List<User> {
        return listOf(
            User(1, "John Doe"),
            User(2, "Jane Smith")
        )
    }

    @GetMapping("/{id}")
    fun getUser(@PathVariable id: Int): User {
        return User(id, "User $id")
    }
}