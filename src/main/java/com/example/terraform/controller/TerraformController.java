package com.example.terraform.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TerraformController {

    @GetMapping("/terraform")
    public String sayHello(){
        return "Terraform is Working";
    }
}
