package Algoga.server.global.gemini.service;

import Algoga.server.domain.member.Member;
import Algoga.server.domain.member.dto.MemberJoinDto;
import Algoga.server.domain.member.service.MemberService;
import Algoga.server.global.gemini.prompt.PromptBase;
import Algoga.server.global.gemini.service.dto.FoodAnalysisDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GeminiService {
    private final ObjectMapper objectMapper;

    private final MemberService memberService;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.model-name}")
    private String modelName;


    public String getHealthTravelConsult(HttpSession session, String destination, Long memberId) throws IOException {

        Member member = memberService.getMemberById(memberId);
        String prompt = PromptBase.getImprovedHealthTravelConsultPrompt(destination, member);

        // API 요청 URL 생성
        String urlString = "https://generativelanguage.googleapis.com/v1beta/models/"
                + modelName
                + ":generateContent?key="
                + apiKey;
        URL url;
        try {
            url = new URL(urlString);
        } catch (MalformedURLException e) {
            throw new RuntimeException(e);
        }

        // HTTP 연결 설정
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        // 요청 본문(JSON) 준비 및 전송
        // 문자열 이스케이핑 처리 개선
        String escapedPrompt = prompt
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");

        String jsonInputString = "{\"contents\":[{\"parts\":[{\"text\":\"" + escapedPrompt + "\"}]}]}";

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonInputString.getBytes("utf-8");
            os.write(input, 0, input.length);
        }

        // 서버 응답 읽기
        int responseCode = conn.getResponseCode();
        InputStream inputStream = (responseCode >= 200 && responseCode < 300)
                ? conn.getInputStream()
                : conn.getErrorStream();

        try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream, "utf-8"))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }

            if (responseCode >= 400) {
                System.err.println("API Error Response: " + response.toString());
                throw new RuntimeException("Error during health-travel consult: HTTP " + responseCode + " - " + response.toString());
            }

            // JSON 응답 파싱
            JSONObject jsonResponse = new JSONObject(response.toString());
            if (jsonResponse.has("candidates")) {
                JSONArray candidates = jsonResponse.getJSONArray("candidates");
                StringBuilder message = new StringBuilder();
                for (int i = 0; i < candidates.length(); i++) {
                    JSONObject content = candidates.getJSONObject(i).getJSONObject("content");
                    JSONArray parts = content.getJSONArray("parts");
                    for (int j = 0; j < parts.length(); j++) {
                        message.append(parts.getJSONObject(j).getString("text")).append("\n");
                    }
                }
                // 마크다운 코드블록 제거
                String raw = message.toString().trim();
                String cleanJson = extractJsonFromMarkdown(raw);
                return cleanJson;
            } else {
                throw new RuntimeException("No travel-health consult results found.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Error during health-travel consult: " + e.getMessage());
        }
    }


    public String getDrugAnalyze(HttpSession session, String destination, Long memberId) throws IOException {
        Member member = memberService.getMemberById(memberId);
        String prompt = PromptBase.getDrugInfoPrompt(destination, member);

        // API 요청 URL 생성
        String urlString = "https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":generateContent?key=" + apiKey;
        URL url = new URL(urlString);

        // HTTP 연결 설정
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        // 요청 본문(JSON) 준비 및 전송
        String escapedPrompt = prompt.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
        String jsonInputString = "{\"contents\":[{\"parts\":[{\"text\":\"" + escapedPrompt + "\"}]}]}";
        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonInputString.getBytes("utf-8");
            os.write(input, 0, input.length);
        }

        // 서버 응답 읽기
        int responseCode = conn.getResponseCode();
        InputStream inputStream = (responseCode >= 200 && responseCode < 300) ? conn.getInputStream() : conn.getErrorStream();

        try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream, "utf-8"))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }

            if (responseCode >= 400) {
                System.err.println("API Error Response: " + response.toString());
                return "Error analyzing drug data: HTTP " + responseCode + " - " + response.toString();
            }

            // JSON 응답 파싱
            JSONObject jsonResponse = new JSONObject(response.toString());
            if (jsonResponse.has("candidates")) {
                JSONArray candidates = jsonResponse.getJSONArray("candidates");
                for (int i = 0; i < candidates.length(); i++) {
                    JSONObject content = candidates.getJSONObject(i).getJSONObject("content");
                    JSONArray parts = content.getJSONArray("parts");
                    for (int j = 0; j < parts.length(); j++) {
                        String rawText = parts.getJSONObject(j).getString("text");
                        // 마크다운 코드블록 제거
                        String cleanedJson = rawText
                                .replaceFirst("(?s)^```json\\s*", "")
                                .replaceFirst("(?s)^```\\s*", "")
                                .replaceFirst("(?s)\\s*```$", "")
                                .trim();
                        return cleanedJson;
                    }
                }
            }
            return "No drug analysis results found.";
        } catch (Exception e) {
            e.printStackTrace();
            return "Error analyzing drug data: " + e.getMessage();
        }
    }


    public FoodAnalysisDto getFoodAnalyze(HttpSession session, MultipartFile imageFile, Long memberId) throws IOException {
        Member member = memberService.getMemberById(memberId);
        String prompt = PromptBase.getImageAnalyzePrompt(member);

        // API request URL generate
        String urlString = "https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":generateContent?key=" + apiKey;
        urlString = urlString.replaceAll("\\s+", ""); // URL에서 공백 제거

        try {
            // 이미지 크기 체크
            long imageSize = imageFile.getSize();
            if (imageSize > 15 * 1024 * 1024) {
                throw new IllegalArgumentException("Error: Image size exceeds API limits (max 15MB)");
            }

            // HTTP 연결 준비
            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setDoOutput(true);

            // 이미지 MIME 타입 가져오기
            String mimeType = imageFile.getContentType();
            if (mimeType == null) {
                mimeType = "image/jpeg"; // 기본값 설정
            }

            // 이미지 Base64 인코딩
            String base64Img = Base64.getEncoder().encodeToString(imageFile.getBytes());

            // JSON 요청 구성
            JSONObject jsonRequest = new JSONObject();
            JSONArray contents = new JSONArray();
            JSONObject userContent = new JSONObject();
            userContent.put("role", "user");

            JSONArray contentParts = new JSONArray();
            JSONObject textPart = new JSONObject();
            textPart.put("text", prompt);
            contentParts.put(textPart);

            JSONObject imagePart = new JSONObject();
            JSONObject inlineData = new JSONObject();
            inlineData.put("mime_type", mimeType);
            inlineData.put("data", base64Img);
            imagePart.put("inline_data", inlineData);
            contentParts.put(imagePart);

            userContent.put("parts", contentParts);
            contents.put(userContent);
            jsonRequest.put("contents", contents);

            // 요청 전송
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonRequest.toString().getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();
            InputStream responseStream = (responseCode >= 200 && responseCode < 300)
                    ? conn.getInputStream()
                    : conn.getErrorStream();

            // 응답 읽기
            StringBuilder response = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(responseStream, StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line.trim());
                }
            }

            // 에러 응답 처리
            if (responseCode >= 400) {
                System.err.println("API Error Response: " + response);
                throw new RuntimeException("Error analyzing food data: HTTP " + responseCode + " - " + response);
            }

            // JSON 응답 파싱
            JSONObject jsonResponse = new JSONObject(response.toString());
            if (jsonResponse.has("candidates")) {
                JSONArray candidates = jsonResponse.getJSONArray("candidates");
                for (int i = 0; i < candidates.length(); i++) {
                    JSONObject content = candidates.getJSONObject(i).getJSONObject("content");
                    JSONArray parts = content.getJSONArray("parts");
                    for (int j = 0; j < parts.length(); j++) {
                        String rawText = parts.getJSONObject(j).getString("text");
                        String cleanedJson = rawText
                                .replaceFirst("(?s)^```json\\s*", "")
                                .replaceFirst("(?s)^```\\s*", "")
                                .replaceFirst("(?s)\\s*```$", "")
                                .trim();
                        return objectMapper.readValue(cleanedJson, FoodAnalysisDto.class);
                    }
                }
            }

            // 결과가 없는 경우
            return new FoodAnalysisDto("Unknown", "unknown", List.of("no_data"), "No analysis results found.");

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Error analyzing data: " + e.getMessage());
        }
    }

    private String extractJsonFromMarkdown(String raw) {
        if (raw == null || raw.isEmpty()) {
            return "";
        }

        String cleaned = raw.trim();

        // ```json ... ``` 패턴 확인
        if (cleaned.startsWith("```json")) {
            cleaned = cleaned.substring("```json".length());
        }
        // ``` ... ``` 패턴 확인
        else if (cleaned.startsWith("```")) {
            cleaned = cleaned.substring("```".length());
        }

        // 끝부분의 ``` 제거
        if (cleaned.endsWith("```")) {
            cleaned = cleaned.substring(0, cleaned.length() - "```".length());
        }

        return cleaned.trim();
    }


}
