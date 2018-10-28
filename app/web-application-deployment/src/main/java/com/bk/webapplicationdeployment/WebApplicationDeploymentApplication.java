package com.bk.webapplicationdeployment;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;

@SpringBootApplication
public class WebApplicationDeploymentApplication {

    public static final String APPLICATION_LOCATIONS = "spring.config.location="
            + "classpath:application.yml, "
            + "/Web-Application-Deployment/app/config/external-config.yml";

    public static void main(String[] args) {
        // SpringApplication.run(WebApplicationDeploymentApplication.class, args);

        new SpringApplicationBuilder(WebApplicationDeploymentApplication.class)
                .properties(APPLICATION_LOCATIONS)
                .run();
    }
}
