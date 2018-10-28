package com.bk.webapplicationdeployment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;

@SpringBootApplication
public class WebApplicationDeploymentApplication {

    public static final String APPLICATION_LOCATIONS = "spring.config.location="
            + "classpath:application.yml, "
            + "../config/external-config.yml";

    public static void main(String[] args) {
        // SpringApplication.run(WebApplicationDeploymentApplication.class, args);
        new SpringApplicationBuilder(WebApplicationDeploymentApplication.class)
                .properties(APPLICATION_LOCATIONS)
                .run();
    }
}
