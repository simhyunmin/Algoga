package Algoga.server.domain.member.controller;

import Algoga.server.domain.member.Member;
import Algoga.server.domain.member.dto.MemberInfoDto;
import Algoga.server.domain.member.dto.MemberJoinDto;
import Algoga.server.domain.member.dto.MemberUpdateDto;
import Algoga.server.domain.member.service.MemberService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class MemberController {
    private final MemberService memberService;

    @PostMapping("/member/join")
    public ResponseEntity<Map<String, Long>> memberJoin(@ModelAttribute MemberJoinDto memberJoinDto, HttpSession session) {
        Member member = memberService.MemberJoin(memberJoinDto);
        Map<String, Long> result = new HashMap<>();
        result.put("memberId", member.getMemberId());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/member/{memberId}/travel-locations")
    public ResponseEntity<String> getTravelLocation(@PathVariable Long memberId) {
        Member member = memberService.getMemberById(memberId);
        String travelLocation = member.getTravelLocations();
        return ResponseEntity.ok(travelLocation);
    }


    // 멤버 정보 조회
    @GetMapping("/member/{memberId}/info")
    public ResponseEntity<MemberInfoDto> getMemberInfo(@PathVariable Long memberId) {
        Member member = memberService.getMemberById(memberId);
        MemberInfoDto memberInfoDto = MemberInfoDto.builder()
                .birth(member.getBirth())
                .name(member.getName())
                .country(member.getCountry())
                .gender(member.getGender())
                .travelLocations(member.getTravelLocations())
                .medications(member.getMedications())
                .disease(member.getDisease())
                .build();
        return ResponseEntity.ok(memberInfoDto);


    }

    // 멤버 정보 수정
    @PutMapping("/member/{memberId}/info/update")
    public ResponseEntity<Void> updateMemberInfo(@PathVariable Long memberId,
                                                 @RequestBody MemberUpdateDto memberUpdateDto) {
        // 멤버 정보 업데이트
        memberService.updateMember(memberId, memberUpdateDto);

        // 리다이렉션을 위한 URI 생성
        URI redirectUri = URI.create("/member/" + memberId + "/info");

        // 303 See Other 상태 코드와 함께 리다이렉션
        return ResponseEntity.status(HttpStatus.SEE_OTHER)
                .location(redirectUri)
                .build();
    }

}
