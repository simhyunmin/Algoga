package Algoga.server.domain.member.dto;

import Algoga.server.domain.member.Country;
import Algoga.server.domain.member.Gender;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Builder
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class MemberUpdateDto {
    private String name;
    private LocalDate birth;
    private Country country;
    private Gender gender;
    private String medications;
    private String travelLocations;
    private String disease;
}

