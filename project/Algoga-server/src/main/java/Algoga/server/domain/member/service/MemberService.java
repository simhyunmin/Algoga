package Algoga.server.domain.member.service;

import Algoga.server.domain.member.Member;
import Algoga.server.domain.member.dto.MemberJoinDto;
import Algoga.server.domain.member.dto.MemberUpdateDto;
import Algoga.server.domain.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MemberService {
    private final MemberRepository memberRepository;

    public Member MemberJoin(MemberJoinDto memberJoinDto) {
        Member member = new Member(memberJoinDto);
        memberRepository.save(member);
        return member;
    }

    public Member getMemberById(Long memberId) {
        return memberRepository.findByMemberId(memberId);

    }

    public Member updateMember(Long memberId, MemberUpdateDto memberUpdateDto) {
        Member member = getMemberById(memberId);
        member.updateInfo(
                memberUpdateDto.getName(),
                memberUpdateDto.getBirth(),
                memberUpdateDto.getCountry(),
                memberUpdateDto.getGender(),
                memberUpdateDto.getMedications(),
                memberUpdateDto.getTravelLocations(),
                memberUpdateDto.getDisease()
        );

        return memberRepository.save(member);
    }
}
