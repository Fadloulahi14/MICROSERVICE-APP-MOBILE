package sn.l3gl.banque.api.swagger;

import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme.In;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@SecurityScheme(
        name = "bearerAuth",
        type = SecuritySchemeType.HTTP,
        bearerFormat = "JWT",
        scheme = "bearer"
)
@Configuration
public class OpenApiConfiguration {

    @Bean
    public OpenAPI defineOpenApi(){
        Server server = new Server();
        server.url("http://localhost:8081");
        server.description("Developpement d'un API de gestion de comptes bancaire");

        Contact contact = new Contact();
        contact.setName("Ecole 221");
        contact.setEmail("ecole221@gmail.com");

        Info info = new Info()
                .title("Application bancaire")
                .version("1.0")
                .description("Cet api permet la gestion de comptes bancaire")
                .contact(contact) ;
        return new OpenAPI()
                .info(info)
                .servers(List.of(server))
                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
                .components(new Components().addSecuritySchemes(
                        "bearerAuth",
                        new io.swagger.v3.oas.models.security.SecurityScheme()
                                .name("Authorization")
                                .type(io.swagger.v3.oas.models.security.SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .in(In.HEADER)
                ));
    }
}
