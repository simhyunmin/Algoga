package Algoga.server.global.gemini.service.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
public class FoodAnalysisDto {
    private String foodName;
    private String riskLevel;
    private List<String> keywords;
    private String conclusion;
}
