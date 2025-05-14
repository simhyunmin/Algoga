package Algoga.server.global.gemini.controller;
import Algoga.server.global.gemini.service.GeminiService;
import Algoga.server.global.gemini.service.dto.FoodAnalysisDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class GeminiController {

    private final GeminiService geminiService;

    @PostMapping(
            value = "/analyze/food/{memberId}",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public FoodAnalysisDto analyzeImage(HttpSession session, @PathVariable Long memberId, @RequestPart("image") MultipartFile image) throws IOException {
        return geminiService.getFoodAnalyze(session, image, memberId);
    }

    @GetMapping("/analyze/drug/{memberId}")
    public String analyzeDrug(HttpSession session, @PathVariable Long memberId, @RequestParam("destination") String destination) throws IOException {
        return geminiService.getDrugAnalyze(session, destination, memberId);
    }

    @GetMapping("/analyze/health-travel/{memberId}")
    public ResponseEntity<?> analyzeHealthTravel(HttpSession session, @PathVariable Long memberId,
                                                 @RequestParam("destination") String destination) throws IOException {
        String json = geminiService.getHealthTravelConsult(session, destination, memberId);

        try {
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> result = mapper.readValue(json, Map.class);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage(), "raw", json));
        }
    }

}
