package sn.l3gl.banque.api.security;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SecurityUser {

    private String name;
    private String password;
    private String roles;
}
