package com.bk.webapplicationdeployment;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Arrays;

/**
 * Created by IntelliJ IDEA.
 * Project: web-application-deployment
 * ===========================================
 * User: ByeongGil Jung
 * Date: 2018-10-26
 * Time: 오후 7:02
 */
@Controller
public class AppController {

    @Autowired Environment env;

    @GetMapping("/")
    public String version(Model model) {
        model.addAttribute("version", "0.1.8");
        return "index";
    }

    @GetMapping("/profile")
    @ResponseBody
    public String getProfile() {
        return Arrays.stream(env.getActiveProfiles())
                .findFirst()
                .orElse("");
    }
}
