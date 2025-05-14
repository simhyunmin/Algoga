package Algoga.server.global.gemini.prompt;

import Algoga.server.domain.member.Member;
import Algoga.server.domain.member.dto.MemberJoinDto;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.time.Period;

public class PromptBase {

    public static String getImprovedHealthTravelConsultPrompt(String destination, Member member) {
        StringBuilder prompt = new StringBuilder();

        prompt.append("**Role:** 만성 소화계 질환 여행자를 위한 전문 건강 및 여행 컨설턴트\n\n")
                .append("**사용자 정보:**\n")
                .append("- **성별:** ").append(member.getGender()).append("\n")
                .append("- **나이:** ").append(Period.between(member.getBirth(), LocalDate.now()).getYears()).append("\n")
                .append("- **국적:** ").append(member.getCountry()).append("\n")
                .append("- **기저질환:** ").append(member.getDisease()).append("\n")
                .append("- **여행 장소(도시/지역):** ").append(destination).append("\n\n")
                .append("---\n\n")
                .append("## 🔎 심층 분석 요청 항목\n\n")

                // 0. 기본 건강 정보 평가
                .append("### 0. 기본 건강 정보 평가 (`basicHealthAssessment`)\n")
                .append("- **medicalHistorySummary**  \n")
                .append("  - 사용자 기저질환, 최근 flare-up 이력, 수술 내역, 주요 증상 변화를 포함한 종합적인 건강 상태 평가\n")
                .append("- **dietarySensitivityCheck**  \n")
                .append("  - 사용자에게 영향을 줄 수 있는 음식군 (예: 고지방, 고섬유질, 고FODMAP) 민감도 평가\n")
                .append("- **stressImpactAssessment**  \n")
                .append("  - 스트레스, 시차, 수면 부족이 소화계에 미치는 영향 예측\n")
                .append("- **reference**  \n")
                .append("  - PubMed, Mayo Clinic, NHS\n\n")

                // 1. 질환 안정 상태 확인 및 전문의 상담
                .append("### 1. 질환 안정 상태 확인 및 전문의 상담 (`remissionConsultation`)\n")
                .append("- **currentStatusCheck**  \n")
                .append("  - 현재 관해(remission) 상태와 최근 검사 결과에 따른 상태 평가\n")
                .append("  - 여행 중 예상되는 증상 악화 가능성 (예: 스트레스, 시차, 식이 변화) 분석\n")
                .append("- **doseAdjustmentAdvice**  \n")
                .append("  - 필요한 경우 약물 용량 조정 권장 사항\n")
                .append("- **reference**  \n")
                .append("  - PubMed, Thorne\n\n")

                // 2. 약물·의료용품 준비
                .append("### 2. 약물·의료용품 준비 (`medicationPreparation`)\n")
                .append("- **regularMedications**  \n")
                .append("  - 복용 중인 약물 목록, 복용 방법, 예비 용량 제안\n")
                .append("- **emergencyMedications**  \n")
                .append("  - 비상 시 필요할 수 있는 약물 (예: 로페라마이드, 진경제) 및 사용 시 주의사항\n")
                .append("- **storageAndTransport**  \n")
                .append("  - 생물학제제 보관 방법 (예: 냉장 필요 시 기내 휴대 용기 준비)\n")
                .append("- **airportRegulations**  \n")
                .append("  - TSA 등 공항 검색 규정, 의약품 소견서·처방전 지참 필요성\n")
                .append("- **reference**  \n")
                .append("  - Crohn’s and Colitis Foundation, CDC, IFFGD\n\n")

                // 3. 의료 문서 및 여행자 보험
                .append("### 3. 의료 문서 및 여행자 보험 (`medicalDocumentsAndInsurance`)\n")
                .append("- **englishDiagnosis**  \n")
                .append("  - 영문 진단서·의료 요약서 준비 (예: 주요 진단, 최근 검사 결과, 현재 약물 목록)\n")
                .append("- **insuranceCoverage**  \n")
                .append("  - Pre-existing condition 포함 여행자 보험 가입 권장\n")
                .append("- **emergencySupport**  \n")
                .append("  - 24시간 긴급 의료 지원·의료 이송 조항 포함 여부\n")
                .append("- **reference**  \n")
                .append("  - IBD Passport, CDC\n\n")

                // 4. 현지 의료 인프라
                .append("### 4. 현지 의료 인프라 (`localMedicalInfrastructure`)\n")
                .append("- **hospitalList**  \n")
                .append("  - `{ name: 병원명, contact: 연락처, distance: 거리 또는 소요 시간, specialties: 주요 진료과목 }`\n")
                .append("- **emergencyContacts**  \n")
                .append("  - 현지 대사관, 긴급 전화번호 (예: 911, 현지 응급의료 핫라인)\n")
                .append("- **languagePhrases**  \n")
                .append("  - 주요 증상 표현 (예: '급성 설사', '위장 출혈')의 현지어 번역\n")
                .append("- **reference**  \n")
                .append("  - CDC, Crohn’s & Colitis UK\n\n")

                // 5. 식이 계획 및 비상 키트
                .append("### 5. 식이 계획 및 비상 키트 (`dietAndEmergencyKit`)\n")
                .append("- **dietPlan**  \n")
                .append("  - `{ item: 저잔사·저지방·저FODMAP 식품, notes: 섭취 팁, 조리 방법 }`\n")
                .append("- **emergencySnacks**  \n")
                .append("  - 즉석죽, 영양바, 전해질 음료 등 여행 중 긴급 상황에서 유용한 음식 목록\n")
                .append("- **survivalKit**  \n")
                .append("  - 물티슈, 손 소독제, 여분 속옷·위생용품 등 비상 상황 대비 필수품\n")
                .append("- **reference**  \n")
                .append("  - EatingWell, About IBS\n\n")

                // 추가 요청 사항
                .append("## ✅ 추가 요청 사항\n\n")
                .append("- 사용자 개별 건강 상태와 여행지를 고려한 맞춤형 권장 사항 제공\n")
                .append("- 각 항목에서 단순 지침이 아닌 AI 판단에 따른 구체적이고 퀄리티 있는 조언 포함\n")
                .append("- 출력물은 전부 영어로 번역해주십시오.\n")

                // JSON 형식으로 데이터 요청
                .append("---\n\n")
                .append("**Required Output Format:**\n")
                .append("{\n")
                .append("  \"basicHealthAssessment\": {},\n")
                .append("  \"remissionConsultation\": {},\n")
                .append("  \"medicationPreparation\": {},\n")
                .append("  \"medicalDocumentsAndInsurance\": {},\n")
                .append("  \"localMedicalInfrastructure\": {},\n")
                .append("  \"dietAndEmergencyKit\": {}\n")
                .append("}\n");

        return prompt.toString();
    }



    public static String getImageAnalyzePrompt(Member member) {
        int age = Period.between(member.getBirth(), LocalDate.now()).getYears();
        StringBuilder prompt = new StringBuilder();

        // 역할과 사용자 정보
        prompt.append("역할: 만성 소화기 질환 여행자 음식 위험 분석기\n");
        prompt.append("사용자: {")
                .append("\"age\": ").append(age).append(", ")
                .append("\"gender\": \"").append(member.getGender()).append("\", ")
                .append("\"condition\": \"").append(member.getDisease()).append("\", ")
                .append("\"medications\": \"").append(member.getMedications()).append("\"")
                .append("}\n\n");

        // 요청사항: 이미지 데이터 없이 분석 결과만 JSON으로 출력
        prompt.append("요청: 첨부된 음식 사진을 분석하여 아래 항목들을 JSON 형식으로 출력하세요. \n");
        prompt.append("1) foodName\n");
        prompt.append("2) riskLevel (low, medium, high)\n");
        prompt.append("3) keywords (예: high_irritant, high_sodium)\n");
        prompt.append("4) conclusion (부적합한 이유 간단히)\n\n");
        prompt.append("추가 요청 사항 : 출력물은 전부 영어로 번역해주십시오.");

        return prompt.toString();
    }


    public static String getDrugInfoPrompt(String destination, Member member) {
        StringBuilder prompt = new StringBuilder();

        prompt.append("**Role:** Global Drug Information Expert\n\n")
                .append("**Member Information:**\n")
                .append("- Medications: ").append(member.getMedications()).append("\n")
                .append("- Destination: ").append(destination).append("\n\n")
                .append("**Analysis Request:**\n")
                .append("Please generate a structured JSON response for medication details, local alternatives, and precautions.\n")
                .append("You MUST fill in every field with the most accurate and complete information possible. ")
                .append("If any information (such as dosage, usage, price) is not available, use a reliable estimate, common averages, or general guidelines based on typical use cases. ")
                .append("If no specific data is available, clearly state '정보 없음' or 'N/A' only as a last resort.\n")

                // 🔄 추가 요구사항 시작
                .append("You have access to official Korean drug databases (e.g., KMLE, MFDS) and global sources (e.g., DrugBank). ")
                .append("Search those databases for each medication in member.getMedications() and for local alternatives in the specified destination. ")
                .append("If information like dosage, active ingredients, price, or usage is missing, fill in with common or average values typically found for similar medications. ")
                .append("For example:\n")
                .append("- Typical dosage for acetaminophen: 325~500mg per tablet\n")
                .append("- Common price range for generic cold medicine: 500~1500 KRW per tablet\n")
                .append("- Use general ingredient lists if exact formulation is unavailable\n")
                .append("Price 정보는 반드시 KRW 단위로 표기하고, 1정(1 tablet) 또는 1갑(1 pack) 기준을 함께 제시하세요. ")
                .append("절대 임의로 ‘정보 없음’이라고 하지 말고, 출처에 기록이 전혀 없을 때에만 사용하세요.\n")
                .append("출력물은 전부 영어로 번역해주십시오.\n")
                // 🔄 추가 요구사항 끝

                .append("NEVER use empty strings, and NEVER use generic phrases like 'This information varies ...'.\n")
                .append("Search for and provide real medication names, ingredients, dosages, usages, and prices using trusted sources or common knowledge whenever possible.\n")
                .append("Omit the image_url field for simplicity.\n\n")
                .append("**Required Output Format:**\n")
                .append("{\n")
                .append("  \"current_medication\": {\n")
                .append("    \"name\": \"Medication Name\",\n")
                .append("    \"active_ingredient\": \"Active Ingredient\",\n")
                .append("    \"dosage\": \"Dosage Information\",\n")
                .append("    \"usage\": \"Usage Information\"\n")
                .append("  },\n")
                .append("  \"alternative_medications\": [\n")
                .append("    {\n")
                .append("      \"name\": \"Alternative Name\",\n")
                .append("      \"brand_name\": \"Brand Name\",\n")
                .append("      \"active_ingredient\": \"Active Ingredient\",\n")
                .append("      \"dosage\": \"Dosage Information\",\n")
                .append("      \"price\": \"Price / Quantity (in KRW)\",\n")
                .append("      \"match_percentage\": \"Similarity Percentage\"\n")
                .append("    }\n")
                .append("  ],\n")
                .append("  \"precautions\": [\n")
                .append("    { \"message\": \"약품 성분이 완전히 동일하지 않을 수 있습니다.\" },\n")
                .append("    { \"message\": \"용량과 복용법을 확인 후 사용하세요.\" },\n")
                .append("    { \"message\": \"알레르기 반응이 있는 경우 의사와 상담하세요.\" }\n")
                .append("  ]\n")
                .append("}");

        return prompt.toString();
    }




}
