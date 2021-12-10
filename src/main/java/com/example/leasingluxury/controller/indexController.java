package com.example.leasingluxury.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class indexController {

    @RequestMapping({"/", "/index.html"})
    public String index() {
        return "index";
    }

}
