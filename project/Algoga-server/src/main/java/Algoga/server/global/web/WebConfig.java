package Algoga.server.global.web;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")                           // 모든 엔드포인트에 적용
                .allowedOrigins("http://localhost:8000")    // Flutter 웹이 구동되는 주소
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")                        // 모든 헤더 허용
                .allowCredentials(true)                     // 쿠키/자격증명 허용
                .maxAge(3600);                              // preflight 캐시 유지 시간
    }
}
