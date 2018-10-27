package com.bk.webapplicationdeployment;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Created by IntelliJ IDEA.
 * Project: web-application-deployment
 * ===========================================
 * User: ByeongGil Jung
 * Date: 2018-10-26
 * Time: 오후 7:02
 */
@Controller
public class IndexController {

    @GetMapping("/")
    public String version(Model model) {
        model.addAttribute("version", "0.1.0");
        return "index";
    }
}
