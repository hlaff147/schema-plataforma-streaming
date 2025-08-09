DROP TABLE tb_usuarios;
------
DROP TABLE tb_canais;
------
DROP TYPE tp_espectador;
------
DROP TYPE tp_streamer;
------
DROP TYPE tp_usuario_base;
------
DROP TYPE tp_canal_base;
------
DROP TYPE tp_nested_videos;
------
DROP TYPE tp_video;
------
DROP TYPE tp_endereco;
------
DROP TYPE tp_telefones;
------
CREATE OR REPLACE TYPE tp_endereco AS OBJECT (
    rua            VARCHAR2(255),
    bairro         VARCHAR2(255),
    cidade         VARCHAR2(255),
    estado         CHAR(2),
    cep            CHAR(8)
);
/
------
CREATE OR REPLACE TYPE tp_telefones AS VARRAY(5) OF VARCHAR2(15);
/
------
CREATE OR REPLACE TYPE tp_video AS OBJECT (
    titulo         VARCHAR2(255),
    duracao_min    INTEGER,
    data_upload    DATE,

    ORDER MEMBER FUNCTION comparar(v tp_video) RETURN INTEGER
);
/
------
CREATE OR REPLACE TYPE tp_nested_videos AS TABLE OF tp_video;
/
------
CREATE OR REPLACE TYPE tp_usuario_base AS OBJECT (
    cpf             CHAR(11),
    nome            VARCHAR2(255),
    email           VARCHAR2(255),
    endereco        tp_endereco,
    telefones       tp_telefones,
    data_nascimento DATE,

    FINAL MEMBER FUNCTION get_idade RETURN INTEGER,
    MEMBER FUNCTION detalhes RETURN VARCHAR2

) NOT INSTANTIABLE NOT FINAL;
/
------
CREATE OR REPLACE TYPE tp_canal_base AS OBJECT (
    nome_canal         VARCHAR2(255),
    data_criacao       DATE,
    descricao          CLOB,
    videos             tp_nested_videos,

    CONSTRUCTOR FUNCTION tp_canal_base(nome_canal VARCHAR2, descricao CLOB) RETURN SELF AS RESULT,
    MEMBER PROCEDURE adicionar_video (p_titulo VARCHAR2, p_duracao INTEGER),
    MAP MEMBER FUNCTION ordenar_por_data RETURN INTEGER
);
/
------
CREATE OR REPLACE TYPE tp_espectador UNDER tp_usuario_base (
    data_cadastro DATE,

    OVERRIDING MEMBER FUNCTION detalhes RETURN VARCHAR2
);
/
------
CREATE OR REPLACE TYPE tp_streamer UNDER tp_usuario_base (
    dados_bancarios VARCHAR2(100),
    canal           REF tp_canal_base,

    OVERRIDING MEMBER FUNCTION detalhes RETURN VARCHAR2
);
/
------
CREATE OR REPLACE TYPE BODY tp_video AS
    ORDER MEMBER FUNCTION comparar(v tp_video) RETURN INTEGER IS
    BEGIN
        IF self.duracao_min < v.duracao_min THEN
            RETURN -1;
        ELSIF self.duracao_min > v.duracao_min THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END;
END;
/
------
CREATE OR REPLACE TYPE BODY tp_usuario_base AS
    FINAL MEMBER FUNCTION get_idade RETURN INTEGER IS
    BEGIN
        RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, self.data_nascimento) / 12);
    END;

    MEMBER FUNCTION detalhes RETURN VARCHAR2 IS
    BEGIN
        RETURN 'CPF: ' || self.cpf || ', Nome: ' || self.nome;
    END;
END;
/
------
CREATE OR REPLACE TYPE BODY tp_canal_base AS
    CONSTRUCTOR FUNCTION tp_canal_base(nome_canal VARCHAR2, descricao CLOB) RETURN SELF AS RESULT IS
    BEGIN
        self.nome_canal   := nome_canal;
        self.descricao    := descricao;
        self.data_criacao := SYSDATE;
        self.videos       := tp_nested_videos();
        RETURN;
    END;

    MEMBER PROCEDURE adicionar_video(p_titulo VARCHAR2, p_duracao INTEGER) IS
    BEGIN
        self.videos.EXTEND;
        self.videos(self.videos.LAST) := tp_video(p_titulo, p_duracao, SYSDATE);
    END;

    MAP MEMBER FUNCTION ordenar_por_data RETURN INTEGER IS
    BEGIN
        RETURN TO_NUMBER(TO_CHAR(self.data_criacao, 'J'));
    END;
END;
/
------
CREATE OR REPLACE TYPE BODY tp_espectador AS
    OVERRIDING MEMBER FUNCTION detalhes RETURN VARCHAR2 IS
    BEGIN
        RETURN 'CPF: ' || self.cpf || ', Nome: ' || self.nome || ', Tipo: Espectador, Cadastrado em: ' || TO_CHAR(self.data_cadastro, 'DD/MM/YYYY');
    END;
END;
/
------
CREATE OR REPLACE TYPE BODY tp_streamer AS
    OVERRIDING MEMBER FUNCTION detalhes RETURN VARCHAR2 IS
    BEGIN
        RETURN 'CPF: ' || self.cpf || ', Nome: ' || self.nome || ', Tipo: Streamer';
    END;
END;
/
------
CREATE TABLE tb_canais OF tp_canal_base (
    PRIMARY KEY (nome_canal)
) NESTED TABLE videos STORE AS nt_videos_canal;
/
------
CREATE TABLE tb_usuarios OF tp_usuario_base (
    cpf PRIMARY KEY
);
/
------
ALTER TABLE tb_usuarios ADD (SCOPE FOR (canal) IS tb_canais);
/
------
INSERT INTO tb_canais VALUES (
    tp_canal_base('Canal do Bruno', 'Canal sobre tecnologia.')
);
------
INSERT INTO tb_canais VALUES (
    tp_canal_base('Ana Joga', 'Canal de gameplays.')
);
------
INSERT INTO tb_usuarios VALUES (
    tp_espectador(
        '99988877766',
        'Carla Dias',
        'carla.dias@email.com',
        tp_endereco('Rua General Polidoro', 'Várzea', 'Recife', 'PE', '50740530'),
        tp_telefones('81966665555'),
        TO_DATE('1995-05-10', 'YYYY-MM-DD'),
        SYSDATE
    )
);
------
INSERT INTO tb_usuarios VALUES (
    tp_streamer(
        '55566677788',
        'Bruno Costa',
        'bruno.costa@email.com',
        tp_endereco('Avenida Paulista', 'Bela Vista', 'São Paulo', 'SP', '01311000'),
        tp_telefones('11988887777', '11977776666'),
        TO_DATE('1990-02-20', 'YYYY-MM-DD'),
        'Banco Itaú, Ag: 5678-9, CC: 987654-3',
        (SELECT REF(c) FROM tb_canais c WHERE c.nome_canal = 'Canal do Bruno')
    )
);
------
INSERT INTO tb_usuarios VALUES (
    tp_streamer(
        '11122233344',
        'Ana Silva',
        'ana.silva@email.com',
        tp_endereco('Rua General Polidoro', 'Várzea', 'Recife', 'PE', '50740530'),
        tp_telefones('81999998888'),
        TO_DATE('1998-11-30', 'YYYY-MM-DD'),
        'Banco do Brasil, Ag: 1234-5, CC: 123456-7',
        (SELECT REF(c) FROM tb_canais c WHERE c.nome_canal = 'Ana Joga')
    )
);
------
DECLARE
    v_canal_ref REF tp_canal_base;
    v_canal_obj tp_canal_base;
BEGIN
    SELECT REF(c) INTO v_canal_ref FROM tb_canais c WHERE c.nome_canal = 'Canal do Bruno';
    SELECT DEREF(v_canal_ref) INTO v_canal_obj FROM DUAL;
    v_canal_obj.adicionar_video('Desenvolvendo em SQL no Postgres', 120);
    v_canal_obj.adicionar_video('Gameplay de Aventura', 95);
    UPDATE tb_canais SET videos = v_canal_obj.videos WHERE REF(tb_canais) = v_canal_ref;

    SELECT REF(c) INTO v_canal_ref FROM tb_canais c WHERE c.nome_canal = 'Ana Joga';
    SELECT DEREF(v_canal_ref) INTO v_canal_obj FROM DUAL;
    v_canal_obj.adicionar_video('Noite de Estratégia', 150);
    UPDATE tb_canais SET videos = v_canal_obj.videos WHERE REF(tb_canais) = v_canal_ref;
END;
/
------
SELECT c.nome_canal, (SELECT COUNT(*) FROM TABLE(c.videos)) AS total_de_videos
FROM tb_canais c;
------
SELECT u.nome, u.detalhes() AS detalhes_especificos
FROM tb_usuarios u;
------
SELECT TREAT(VALUE(u) AS tp_streamer).nome AS nome_do_streamer,
       DEREF(TREAT(VALUE(u) AS tp_streamer).canal).nome_canal AS nome_do_canal_associado
FROM tb_usuarios u
WHERE VALUE(u) IS OF (tp_streamer);
------
SELECT c.nome_canal, v.titulo, v.duracao_min
FROM tb_canais c, TABLE(c.videos) v;
------
SELECT u.nome, u.get_idade() AS idade
FROM tb_usuarios u;
------
SELECT u.nome, t.COLUMN_VALUE AS telefone
FROM tb_usuarios u, TABLE(u.telefones) t;
------
SELECT u.nome,
       CASE
           WHEN VALUE(u) IS OF (ONLY tp_espectador) THEN 'Espectador (Herdeiro)'
           WHEN VALUE(u) IS OF (ONLY tp_streamer) THEN 'Streamer (Herdeiro)'
           ELSE 'Tipo não específico'
       END AS tipo_exato
FROM tb_usuarios u;
------
SELECT c.nome_canal, c.data_criacao
FROM tb_canais c
ORDER BY c;
------
SELECT v.titulo, v.duracao_min
FROM TABLE( (SELECT videos FROM tb_canais WHERE nome_canal = 'Canal do Bruno') ) v
ORDER BY v;
------
COMMIT;