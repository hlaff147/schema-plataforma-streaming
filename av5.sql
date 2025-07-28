-- Comando: DROP TABLE IF EXISTS tb_videos CASCADE;
DROP TABLE IF EXISTS tb_videos CASCADE;
-- Comando: DROP TABLE IF EXISTS tb_canais CASCADE;
DROP TABLE IF EXISTS tb_canais CASCADE;
-- Comando: DROP TABLE IF EXISTS tb_espectador CASCADE;
DROP TABLE IF EXISTS tb_espectador CASCADE;
-- Comando: DROP TABLE IF EXISTS tb_streamer CASCADE;
DROP TABLE IF EXISTS tb_streamer CASCADE;
-- Comando: DROP TABLE IF EXISTS tb_usuarios CASCADE;
DROP TABLE IF EXISTS tb_usuarios CASCADE;

-- Comando: DROP TYPE IF EXISTS tp_endereco CASCADE;
DROP TYPE IF EXISTS tp_endereco CASCADE;
-- Comando: DROP TYPE IF EXISTS tp_usuario_base CASCADE;
DROP TYPE IF EXISTS tp_usuario_base CASCADE;
-- Comando: DROP TYPE IF EXISTS tp_canal_base CASCADE;
DROP TYPE IF EXISTS tp_canal_base CASCADE;

-- Comando: DROP SEQUENCE IF EXISTS seq_canal_id;
DROP SEQUENCE IF EXISTS seq_canal_id;

---

-- Comando: CREATE TYPE tp_endereco AS (...);
CREATE TYPE tp_endereco AS (
    rua            VARCHAR(255),
    bairro         VARCHAR(255),
    cidade         VARCHAR(255),
    estado         CHAR(2),
    cep            CHAR(8)
);

-- Comando: CREATE TYPE tp_canal_base AS (...);
CREATE TYPE tp_canal_base AS (
    nome_canal         VARCHAR(255),
    data_criacao       DATE,
    descricao          TEXT
);

-- Comando: CREATE TYPE tp_usuario_base AS (...);
CREATE TYPE tp_usuario_base AS (
    cpf            CHAR(11),
    nome           VARCHAR(255),
    email          VARCHAR(255),
    endereco       tp_endereco,
    telefones      TEXT[]
);

---

-- Comando: CREATE TABLE tb_usuarios (...);
CREATE TABLE tb_usuarios (
    dados tp_usuario_base PRIMARY KEY
);

-- Comando: CREATE TABLE tb_espectador (...) INHERITS (...);
CREATE TABLE tb_espectador (
    data_cadastro DATE
) INHERITS (tb_usuarios);

-- Comando: CREATE TABLE tb_streamer (...) INHERITS (...);
CREATE TABLE tb_streamer (
    dados_bancarios VARCHAR(100),
    id_canal_fk     INTEGER
) INHERITS (tb_usuarios);

-- Comando: CREATE SEQUENCE seq_canal_id START 1;
CREATE SEQUENCE seq_canal_id START 1;

-- Comando: CREATE TABLE tb_canais (...);
CREATE TABLE tb_canais (
    id_canal           INTEGER DEFAULT nextval('seq_canal_id') PRIMARY KEY,
    dados_canal        tp_canal_base
);

-- Comando: CREATE TABLE tb_videos (...);
CREATE TABLE tb_videos (
    id_video       SERIAL PRIMARY KEY,
    titulo         VARCHAR(255),
    duracao_min    INTEGER,
    data_upload    DATE,
    id_canal_fk    INTEGER NOT NULL
);

---

-- Comando: ALTER TABLE tb_streamer ADD CONSTRAINT fk_canal FOREIGN KEY (...) REFERENCES (...);
ALTER TABLE tb_streamer
ADD CONSTRAINT fk_canal
FOREIGN KEY (id_canal_fk)
REFERENCES tb_canais (id_canal);

-- Comando: ALTER TABLE tb_videos ADD CONSTRAINT fk_canal_video FOREIGN KEY (...) REFERENCES (...);
ALTER TABLE tb_videos
ADD CONSTRAINT fk_canal_video
FOREIGN KEY (id_canal_fk)
REFERENCES tb_canais (id_canal);

-- Comando: ALTER TABLE tb_usuarios ADD COLUMN data_nascimento DATE;
ALTER TABLE tb_usuarios ADD COLUMN data_nascimento DATE;

---

-- Comando: CREATE OR REPLACE FUNCTION get_idade(u tb_usuarios) RETURNS INTEGER AS $$ ... $$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION get_idade(u tb_usuarios)
RETURNS INTEGER AS $$
BEGIN
    RETURN date_part('year', age(u.data_nascimento));
END;
$$ LANGUAGE plpgsql;

-- Comando: CREATE OR REPLACE FUNCTION detalhes_espectador(e tb_espectador) RETURNS TEXT AS $$ ... $$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION detalhes_espectador(e tb_espectador)
RETURNS TEXT AS $$
BEGIN
    RETURN 'CPF: ' || ((e.dados).cpf) || ', Nome: ' || ((e.dados).nome) || ', Tipo: Espectador, Cadastrado em: ' || TO_CHAR(e.data_cadastro, 'DD/MM/YYYY');
END;
$$ LANGUAGE plpgsql;

-- Comando: CREATE OR REPLACE FUNCTION detalhes_streamer(s tb_streamer) RETURNS TEXT AS $$ ... $$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION detalhes_streamer(s tb_streamer)
RETURNS TEXT AS $$
BEGIN
    RETURN 'CPF: ' || ((s.dados).cpf) || ', Nome: ' || ((s.dados).nome) || ', Tipo: Streamer';
END;
$$ LANGUAGE plpgsql;

-- Comando: CREATE OR REPLACE FUNCTION get_total_videos(c tb_canais) RETURNS INTEGER AS $$ ... $$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION get_total_videos(c tb_canais)
RETURNS INTEGER AS $$
DECLARE
    total INTEGER;
BEGIN
    SELECT COUNT(*) INTO total FROM tb_videos WHERE id_canal_fk = c.id_canal;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Comando: CREATE OR REPLACE FUNCTION adicionar_video(p_id_canal INTEGER, p_titulo VARCHAR, p_duracao INTEGER) RETURNS VOID AS $$ ... $$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION adicionar_video(p_id_canal INTEGER, p_titulo VARCHAR, p_duracao INTEGER)
RETURNS VOID AS $$
BEGIN
    INSERT INTO tb_videos(titulo, duracao_min, data_upload, id_canal_fk)
    VALUES (p_titulo, p_duracao, CURRENT_DATE, p_id_canal);
END;
$$ LANGUAGE plpgsql;

-- Comando: CREATE OR REPLACE FUNCTION exibir_contato(u tp_usuario_base) RETURNS TEXT AS $$ ... $$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION exibir_contato(u tp_usuario_base)
RETURNS TEXT AS $$
BEGIN
    RETURN 'Email: ' || u.email;
END;
$$ LANGUAGE plpgsql;

---

-- Comando: INSERT INTO tb_canais(dados_canal) VALUES (...);
INSERT INTO tb_canais(dados_canal) VALUES
(ROW('Canal do Bruno', CURRENT_DATE, 'Canal sobre tecnologia.')),
(ROW('Ana Joga', CURRENT_DATE, 'Canal de gameplays.'));

-- Comando: INSERT INTO tb_espectador(dados, data_cadastro, data_nascimento) VALUES (...);
INSERT INTO tb_espectador(dados, data_cadastro, data_nascimento) VALUES
(
    ROW(
        '99988877766',
        'Carla Dias',
        'carla.dias@email.com',
        ROW('Rua General Polidoro', 'Várzea', 'Recife', 'PE', '50740530')::tp_endereco,
        ARRAY['81966665555']
    )::tp_usuario_base,
    CURRENT_DATE,
    '1995-05-10'
);

-- Comando: INSERT INTO tb_streamer(dados, dados_bancarios, id_canal_fk, data_nascimento) VALUES (...);
INSERT INTO tb_streamer(dados, dados_bancarios, id_canal_fk, data_nascimento) VALUES
(
    ROW(
        '55566677788',
        'Bruno Costa',
        'bruno.costa@email.com',
        ROW('Avenida Paulista', 'Bela Vista', 'São Paulo', 'SP', '01311000')::tp_endereco,
        ARRAY['11988887777', '11977776666']
    )::tp_usuario_base,
    'Banco Itaú, Ag: 5678-9, CC: 987654-3',
    1,
    '1990-02-20'
);

-- Comando: INSERT INTO tb_streamer(dados, dados_bancarios, id_canal_fk, data_nascimento) VALUES (...);
INSERT INTO tb_streamer(dados, dados_bancarios, id_canal_fk, data_nascimento) VALUES
(
    ROW(
        '11122233344',
        'Ana Silva',
        'ana.silva@email.com',
        ROW('Rua General Polidoro', 'Várzea', 'Recife', 'PE', '50740530')::tp_endereco,
        ARRAY['81999998888']
    )::tp_usuario_base,
    'Banco do Brasil, Ag: 1234-5, CC: 123456-7',
    2,
    '1998-11-30'
);

-- Comando: SELECT adicionar_video(1, 'Desenvolvendo em SQL no Postgres', 120);
SELECT adicionar_video(1, 'Desenvolvendo em SQL no Postgres', 120);
-- Comando: SELECT adicionar_video(1, 'Gameplay de Aventura', 95);
SELECT adicionar_video(1, 'Gameplay de Aventura', 95);
-- Comando: SELECT adicionar_video(2, 'Noite de Estratégia', 150);
SELECT adicionar_video(2, 'Noite de Estratégia', 150);

---

-- Comando: SELECT (c.dados_canal).nome_canal, get_total_videos(c) AS total_de_videos FROM tb_canais c;
SELECT
    (c.dados_canal).nome_canal AS nome_do_canal,
    get_total_videos(c) AS total_de_videos
FROM tb_canais c;

-- Comando: SELECT (u.dados).nome AS nome_usuario, (u.dados).cpf AS cpf_usuario, CASE WHEN u.tableoid = 'tb_espectador'::regclass THEN detalhes_espectador(u.*::tb_espectador) WHEN u.tableoid = 'tb_streamer'::regclass THEN detalhes_streamer(u.*::tb_streamer) ELSE 'Tipo de usuário não especificado' END AS detalhes_especificos FROM tb_usuarios u;
SELECT
    (u.dados).nome AS nome_usuario,
    (u.dados).cpf AS cpf_usuario,
    CASE
        WHEN u.tableoid = 'tb_espectador'::regclass THEN detalhes_espectador(u.*::tb_espectador)
        WHEN u.tableoid = 'tb_streamer'::regclass THEN detalhes_streamer(u.*::tb_streamer)
        ELSE 'Tipo de usuário não especificado'
    END AS detalhes_especificos
FROM tb_usuarios u;

-- Comando: SELECT (u.dados).nome AS nome_usuario, exibir_contato(u.dados) AS contato_email FROM tb_usuarios u;
SELECT
    (u.dados).nome AS nome_usuario,
    exibir_contato(u.dados) AS contato_email
FROM tb_usuarios u;

-- Comando: SELECT (s.dados).nome AS nome_do_streamer, (c.dados_canal).nome_canal AS nome_do_canal_associado, (s.dados).endereco.bairro AS bairro_do_streamer FROM tb_streamer s JOIN tb_canais c ON s.id_canal_fk = c.id_canal;
SELECT
    (s.dados).nome AS nome_do_streamer,
    (c.dados_canal).nome_canal AS nome_do_canal_associado,
    (s.dados).endereco.bairro AS bairro_do_streamer
FROM tb_streamer s
JOIN tb_canais c ON s.id_canal_fk = c.id_canal;

-- Comando: SELECT v.titulo AS titulo_video, v.duracao_min AS duracao, (c.dados_canal).nome_canal AS canal_do_video FROM tb_videos v JOIN tb_canais c ON v.id_canal_fk = c.id_canal WHERE date_part('year', (c.dados_canal).data_criacao) = date_part('year', CURRENT_DATE);
SELECT
    v.titulo AS titulo_video,
    v.duracao_min AS duracao,
    (c.dados_canal).nome_canal AS canal_do_video
FROM tb_videos v
JOIN tb_canais c ON v.id_canal_fk = c.id_canal
WHERE date_part('year', (c.dados_canal).data_criacao) = date_part('year', CURRENT_DATE);

-- Comando: SELECT (u.dados).nome AS nome_usuario, get_idade(u) AS idade_usuario FROM tb_usuarios u WHERE u.data_nascimento < '1995-01-01';
SELECT
    (u.dados).nome AS nome_usuario,
    get_idade(u) AS idade_usuario
FROM tb_usuarios u
WHERE u.data_nascimento < '1995-01-01';

-- Comando: SELECT (u.dados).nome AS nome_usuario, (u.dados).email AS email_usuario, (u.dados).telefones AS lista_de_telefones, t AS telefone_individual FROM tb_usuarios u, unnest((u.dados).telefones) AS t WHERE (u.dados).telefones IS NOT NULL AND array_length((u.dados).telefones, 1) > 0;
SELECT
    (u.dados).nome AS nome_usuario,
    (u.dados).email AS email_usuario,
    (u.dados).telefones AS lista_de_telefones,
    t AS telefone_individual
FROM tb_usuarios u,
     unnest((u.dados).telefones) AS t
WHERE (u.dados).telefones IS NOT NULL AND array_length((u.dados).telefones, 1) > 0;

-- Comando: SELECT c.id_canal, (c.dados_canal).nome_canal AS nome_do_canal, (c.dados_canal).data_criacao AS data_criacao_do_canal, (c.dados_canal).descricao AS descricao_do_canal FROM tb_canais c;
SELECT
    c.id_canal,
    (c.dados_canal).nome_canal AS nome_do_canal,
    (c.dados_canal).data_criacao AS data_criacao_do_canal,
    (c.dados_canal).descricao AS descricao_do_canal
FROM tb_canais c;

-- Comando: SELECT (dados).nome AS nome_usuario, 'Usuário Genérico (Base)' AS tipo_exato FROM ONLY tb_usuarios UNION ALL SELECT (dados).nome, 'Espectador (Herdeiro)' AS tipo_exato FROM tb_espectador UNION ALL SELECT (dados).nome, 'Streamer (Herdeiro)' AS tipo_exato FROM tb_streamer;
SELECT (dados).nome AS nome_usuario, 'Usuário Genérico (Base)' AS tipo_exato FROM ONLY tb_usuarios
UNION ALL
SELECT (dados).nome, 'Espectador (Herdeiro)' AS tipo_exato FROM tb_espectador
UNION ALL
SELECT (dados).nome, 'Streamer (Herdeiro)' AS tipo_exato FROM tb_streamer;

-- Comando: SELECT adicionar_video(1, 'Nova Live de Codificação ORDBMS', 180);
SELECT adicionar_video(1, 'Nova Live de Codificação ORDBMS', 180);
-- Comando: SELECT v.titulo, v.duracao_min, (c.dados_canal).nome_canal FROM tb_videos v JOIN tb_canais c ON v.id_canal_fk = c.id_canal WHERE (c.dados_canal).nome_canal = 'Canal do Bruno' ORDER BY v.data_upload DESC, v.id_video DESC LIMIT 1;
SELECT
    v.titulo,
    v.duracao_min,
    (c.dados_canal).nome_canal
FROM tb_videos v
JOIN tb_canais c ON v.id_canal_fk = c.id_canal
WHERE (c.dados_canal).nome_canal = 'Canal do Bruno'
ORDER BY v.data_upload DESC, v.id_video DESC LIMIT 1;


