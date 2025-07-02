-- =====================================================================
-- PARTE 1: SQL PURO
-- Cobertura dos 26 itens da checklist SQL
-- =====================================================================

-- 1. ALTER TABLE: Adicionando uma coluna para armazenar a data de nascimento do usuário.
ALTER TABLE Usuario ADD data_nascimento DATE;

-- 2. CREATE INDEX: Criando um índice no nome do canal para otimizar buscas.
CREATE INDEX idx_canal_nome ON Canal(nome_canal);

-- 3. INSERT INTO: Inserindo dados de CEP, um novo usuário e um novo canal para os testes seguintes.
INSERT INTO CEP_INFO (cep, rua, bairro, cidade, estado) VALUES ('50070000', 'Avenida das Oportunidades', 'Bairro Novo', 'Recife', 'PE');
INSERT INTO Usuario (cpf, email, nome, descricao, cep, numero_endereco, data_nascimento) VALUES ('98989898989', 'outro.usuario@email.com', 'Outro Usuario Teste', 'Um usuário diferente para testes.', '50070000', '101', TO_DATE('1999-11-20', 'YYYY-MM-DD'));
INSERT INTO Canal (nome_canal, data_criacao_canal, descricao_canal) VALUES ('Canal para Apagar', SYSDATE, 'Canal a ser deletado');

-- 4. UPDATE: O novo usuário decidiu mudar sua descrição.
UPDATE Usuario
SET descricao = 'Descrição recém-atualizada.'
WHERE cpf = '98989898989'; -- Ajustado para o novo CPF

-- 5. DELETE: Deletando o canal de teste que foi criado.
DELETE FROM Canal
WHERE nome_canal = 'Canal para Apagar'; 

-- Consulta principal para demonstrar múltiplos itens da checklist
-- Cenário: Gerar um relatório com os streamers mais populares, mostrando o nome do usuário, nome do canal,
-- a quantidade total de transmissões, a média e o pico de espectadores que já tiveram.
-- A consulta considera apenas streamers com mais de uma transmissão e que tiveram um pico de mais de 80 espectadores.
-- O relatório deve ser ordenado do maior pico para o menor.
-- 6. SELECT-FROM-WHERE / 11. INNER JOIN / 12. MAX / 13. MIN / 14. AVG / 15. COUNT / 21. ORDER BY / 22. GROUP BY / 23. HAVING
SELECT
    U.nome AS nome_streamer,
    C.nome_canal,
    COUNT(T.id_transmissao) AS total_transmissoes,
    TRUNC(AVG(T.max_espectadores_simultaneos)) AS media_espectadores,
    MAX(T.max_espectadores_simultaneos) AS pico_espectadores,
    MIN(T.max_espectadores_simultaneos) AS menor_pico
FROM
    Usuario U
INNER JOIN
    Streamer S ON U.cpf = S.cpf_streamer
INNER JOIN
    Canal C ON S.id_canal = C.id_canal
INNER JOIN
    Transmissao T ON C.id_canal = T.canal_id
WHERE
    T.status = 'Finalizada'
GROUP BY
    U.nome, C.nome_canal
HAVING
    COUNT(T.id_transmissao) > 0 AND MAX(T.max_espectadores_simultaneos) > 80
ORDER BY
    pico_espectadores DESC;

-- Consulta para demonstrar filtros específicos
-- Cenário: Encontrar transmissões que aconteceram em Junho de 2025, de canais com "Jogo" no nome,
-- e cujo status não seja nulo, limitado a canais específicos (ID 1 ou 2).
-- 7. BETWEEN / 8. IN / 9. LIKE / 10. IS NULL ou IS NOT NULL
SELECT
    C.nome_canal,
    T.titulo,
    T.data_hora_inicio
FROM
    Transmissao T
INNER JOIN
    Canal C ON T.canal_id = C.id_canal
WHERE
    T.data_hora_inicio BETWEEN TO_TIMESTAMP('2025-06-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND TO_TIMESTAMP('2025-06-30 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
    AND T.status IS NOT NULL
    AND C.nome_canal LIKE '%Jogo%'
    AND C.id_canal IN (1, 2);

-- 16. LEFT ou RIGHT ou FULL OUTER JOIN
-- Cenário: Listar todos os usuários, e para aqueles que são streamers, mostrar o nome do canal.
-- Usuários que não são streamers também devem aparecer na lista.
SELECT
    U.nome,
    U.email,
    C.nome_canal
FROM
    Usuario U
LEFT JOIN
    Streamer S ON U.cpf = S.cpf_streamer
LEFT JOIN
    Canal C ON S.id_canal = C.id_canal
ORDER BY
    C.nome_canal DESC;

-- 17. SUBCONSULTA COM OPERADOR RELACIONAL
-- Cenário: Encontrar os vídeos do canal mais antigo da plataforma.
SELECT
    titulo,
    duracao_data_upload
FROM
    Video
WHERE
    canal_id = (SELECT id_canal FROM Canal ORDER BY data_criacao_canal ASC FETCH FIRST 1 ROWS ONLY);

-- 18. SUBCONSULTA COM IN
-- Cenário: Encontrar os nomes de todos os usuários que já assistiram a algum vídeo de um canal da categoria 'Música'.
SELECT nome FROM Usuario
WHERE cpf IN (
    SELECT DISTINCT A.usuario_cpf
    FROM Assiste A
    INNER JOIN Video V ON A.video_id = V.id_video
    WHERE V.canal_id IN (
        SELECT TC.canal_id
        FROM Tem_Categoria TC
        INNER JOIN Categoria CAT ON TC.categoria_id = CAT.id_categoria
        WHERE CAT.nome_categoria = 'Música'
    )
);

-- 19. SUBCONSULTA COM ANY
-- Cenário: Encontrar canais que possuem pelo menos uma transmissão com mais espectadores que a média de QUALQUER outro canal.
SELECT nome_canal FROM Canal C
WHERE C.id_canal IN (
    SELECT T.canal_id FROM Transmissao T
    WHERE T.max_espectadores_simultaneos > ANY (
        SELECT AVG(T2.max_espectadores_simultaneos)
        FROM Transmissao T2
        WHERE T2.canal_id != T.canal_id -- Garante que estamos comparando com a média de OUTROS canais
        GROUP BY T2.canal_id
    )
);

-- 20. SUBCONSULTA COM ALL
-- Cenário: Encontrar o(s) streamer(s) cujo pico de espectadores é maior ou igual ao de TODAS as transmissões.
SELECT U.nome
FROM Usuario U
JOIN Streamer S ON U.cpf = S.cpf_streamer
WHERE S.id_canal IN (
    SELECT T.canal_id
    FROM Transmissao T
    WHERE T.max_espectadores_simultaneos >= ALL (
        SELECT T2.max_espectadores_simultaneos
        FROM Transmissao T2
        WHERE T2.max_espectadores_simultaneos IS NOT NULL
    )
);

-- 24. UNION ou INTERSECT ou MINUS
-- Cenário: Encontrar usuários que são streamers, mas não são espectadores.
SELECT cpf_streamer FROM Streamer
MINUS
SELECT cpf_espectador FROM Espectador;

-- 25. CREATE VIEW
-- Cenário: Criar uma visão para simplificar o acesso a informações detalhadas sobre streamers.
CREATE OR REPLACE VIEW V_INFO_STREAMERS AS
SELECT
    U.cpf,
    U.nome,
    U.email,
    C.id_canal,
    C.nome_canal,
    C.data_criacao_canal
FROM
    Usuario U
JOIN
    Streamer S ON U.cpf = S.cpf_streamer
JOIN
    Canal C ON S.id_canal = C.id_canal;

-- 26. GRANT / REVOKE
-- Cenário: Conceder permissão de SELECT na view V_INFO_STREAMERS para um usuário "analista" e depois revogar.
-- (Estes comandos são conceituais e devem ser executados por um DBA)
-- GRANT SELECT ON V_INFO_STREAMERS TO analista;
-- REVOKE SELECT ON V_INFO_STREAMERS FROM analista;


-- =====================================================================
-- PARTE 2: PL/SQL
-- Cobertura dos 20 itens da checklist PL/SQL
-- =====================================================================

-- 3. BLOCO ANÔNIMO / 12. FOR IN LOOP / 2. USO DE ESTRUTURA DE DADOS DO TIPO TABLE
-- Cenário: Usar um bloco anônimo com uma estrutura de dados do tipo TABLE para listar todas as categorias.
DECLARE
    TYPE t_lista_categorias IS TABLE OF Categoria.nome_categoria%TYPE INDEX BY PLS_INTEGER;
    v_categorias t_lista_categorias;
BEGIN
    SELECT nome_categoria BULK COLLECT INTO v_categorias FROM Categoria;
    DBMS_OUTPUT.PUT_LINE('--- Lista de Categorias ---');
    FOR i IN 1..v_categorias.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('- ' || v_categorias(i));
    END LOOP;
END;
/

-- 4. CREATE PROCEDURE / 6. %TYPE / 13. SELECT ... INTO / 8. IF ELSIF / 15. EXCEPTION WHEN / 16. USO DE PARÂMETROS (IN)
-- Cenário: Criar uma procedure que atualiza a descrição de um usuário, tratando exceções.
CREATE OR REPLACE PROCEDURE prc_atualizar_descricao_usuario (
    p_cpf       IN Usuario.cpf%TYPE,
    p_nova_desc IN Usuario.descricao%TYPE
) IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Usuario WHERE cpf = p_cpf;
    IF v_count > 0 THEN
        UPDATE Usuario SET descricao = p_nova_desc WHERE cpf = p_cpf;
        DBMS_OUTPUT.PUT_LINE('Descrição do usuário ' || p_cpf || ' atualizada.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Usuário com CPF ' || p_cpf || ' não encontrado.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocorreu um erro: ' || SQLERRM);
END;
/

-- 5. CREATE FUNCTION
-- Cenário: Criar uma função que retorna a contagem de assinantes de um canal.
CREATE OR REPLACE FUNCTION fnc_contar_assinantes (
    p_id_canal IN Canal.id_canal%TYPE
) RETURN NUMBER IS
    v_total_assinantes NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_assinantes FROM Assina WHERE canal_id = p_id_canal;
    RETURN v_total_assinantes;
END;
/

-- Bloco para demonstrar itens restantes de loop e cursor
-- 1. USO DE RECORD / 7. %ROWTYPE / 10. LOOP EXIT WHEN / 14. CURSOR (OPEN, FETCH e CLOSE)
-- Cenário: Usar um cursor para buscar todos os vídeos de um canal, armazenando cada linha em um record, e imprimindo o título.
DECLARE
    -- 1. Uso de Record customizado
    TYPE rec_video_info IS RECORD (
        titulo_video Video.titulo%TYPE,
        data_upload  Video.duracao_data_upload%TYPE
    );
    v_video_rec rec_video_info;
    -- 7. Uso de %ROWTYPE como alternativa
    v_video_rowtype Video%ROWTYPE;
    -- 14. Declarando o cursor
    CURSOR c_videos_canal (p_canal_id Canal.id_canal%TYPE) IS
        SELECT * FROM Video WHERE canal_id = p_canal_id;
BEGIN
    OPEN c_videos_canal(1);
    LOOP
        FETCH c_videos_canal INTO v_video_rowtype;
        EXIT WHEN c_videos_canal%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Vídeo: ' || v_video_rowtype.titulo);
    END LOOP;
    CLOSE c_videos_canal;
END;
/

-- 17. CREATE OR REPLACE PACKAGE / 18. CREATE OR REPLACE PACKAGE BODY
-- Cenário: Criar um package que encapsula a lógica de gerenciamento de canais.
-- 1. Especificação do Package
CREATE OR REPLACE PACKAGE pkg_gerenciamento_canal AS
    FUNCTION fnc_contar_assinantes (p_id_canal IN Canal.id_canal%TYPE) RETURN NUMBER;
    PROCEDURE prc_obter_info_canal (
        p_id_canal     IN  Canal.id_canal%TYPE,
        p_nome_canal   OUT Canal.nome_canal%TYPE,
        p_data_criacao OUT Canal.data_criacao_canal%TYPE -- 16. Uso de Parâmetro OUT
    );
END pkg_gerenciamento_canal;
/
-- 2. Corpo do Package
CREATE OR REPLACE PACKAGE BODY pkg_gerenciamento_canal AS
    FUNCTION fnc_contar_assinantes (p_id_canal IN Canal.id_canal%TYPE) RETURN NUMBER IS
        v_total_assinantes NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total_assinantes FROM Assina WHERE canal_id = p_id_canal;
        RETURN v_total_assinantes;
    END;

    PROCEDURE prc_obter_info_canal (
        p_id_canal     IN  Canal.id_canal%TYPE,
        p_nome_canal   OUT Canal.nome_canal%TYPE,
        p_data_criacao OUT Canal.data_criacao_canal%TYPE
    ) IS
    BEGIN
        SELECT nome_canal, data_criacao_canal INTO p_nome_canal, p_data_criacao
        FROM Canal WHERE id_canal = p_id_canal;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_nome_canal := 'CANAL INEXISTENTE';
            p_data_criacao := NULL;
    END;
END pkg_gerenciamento_canal;
/

-- 20. CREATE OR REPLACE TRIGGER (LINHA) / 9. CASE WHEN / 11. WHILE LOOP
-- Cenário: Criar uma tabela de log e um trigger de linha que audita mudanças no nome do canal.
CREATE TABLE log_mudancas_canal (
    id_log        NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    id_canal      NUMBER,
    nome_antigo   VARCHAR2(255),
    nome_novo     VARCHAR2(255),
    data_mudanca  TIMESTAMP,
    usuario_db    VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER trg_audita_nome_canal
BEFORE UPDATE OF nome_canal ON Canal
FOR EACH ROW
DECLARE
    v_iterador NUMBER := 0; -- Apenas para exemplo de loop
BEGIN
    -- 11. Exemplo didático de WHILE LOOP
    WHILE v_iterador < 1 LOOP
        -- 9. Uso de CASE WHEN
        CASE
            WHEN :OLD.nome_canal != :NEW.nome_canal THEN
                INSERT INTO log_mudancas_canal (id_canal, nome_antigo, nome_novo, data_mudanca, usuario_db)
                VALUES (:OLD.id_canal, :OLD.nome_canal, :NEW.nome_canal, SYSTIMESTAMP, USER);
            ELSE
                NULL;
        END CASE;
        v_iterador := v_iterador + 1;
    END LOOP;
END;
/

-- 19. CREATE OR REPLACE TRIGGER (COMANDO)
-- Cenário: Criar um trigger de comando que impede a criação de novos canais aos finais de semana.
CREATE OR REPLACE TRIGGER trg_impede_canal_fim_semana
BEFORE INSERT ON Canal
BEGIN
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Criação de novos canais não é permitida aos finais de semana.');
    END IF;
END;
/