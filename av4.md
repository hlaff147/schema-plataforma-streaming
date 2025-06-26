## 1\. Consultas SQL

Aqui estão as consultas que cobrem os 26 itens da checklist de SQL.

### 1.1. Manutenção de Tabelas e Dados (DML e DDL)

#### Cenário: Adicionar uma coluna para data de nascimento do usuário, um índice para busca de canais, inserir/atualizar/deletar dados específicos.

```sql
-- Adicionando uma coluna para armazenar a data de nascimento do usuário.
-- CHECKLIST: ALTER TABLE
ALTER TABLE Usuario ADD data_nascimento DATE;

-- Criando um índice no nome do canal para otimizar buscas por nome.
-- CHECKLIST: CREATE INDEX
CREATE INDEX idx_canal_nome ON Canal(nome_canal);

-- Inserindo um novo usuário para os testes seguintes.
-- CHECKLIST: INSERT INTO
INSERT INTO Usuario (cpf, email, nome, descricao, cep, numero_endereco, data_nascimento)
VALUES ('12121212121', 'novo.usuario@email.com', 'Usuario Teste', 'Um novo usuário para testes.', '50740530', '999', TO_DATE('2000-10-15', 'YYYY-MM-DD'));

-- O novo usuário decidiu mudar sua descrição.
-- CHECKLIST: UPDATE
UPDATE Usuario
SET descricao = 'Descrição atualizada após o cadastro.'
WHERE cpf = '12121212121';

-- O usuário '12121212121' deixou de seguir o canal 2, que ele havia seguido anteriormente (necessário inserir o dado antes).
-- CHECKLIST: DELETE
-- Primeiro, inserimos o dado para poder deletá-lo
INSERT INTO Segue (usuario_cpf, canal_id) VALUES ('12121212121', 2);
-- Agora, deletamos
DELETE FROM Segue
WHERE usuario_cpf = '12121212121' AND canal_id = 2;

```

### 1.2. Consulta Complexa de Análise de Streamers

#### Cenário: Gerar um relatório com os streamers mais populares, mostrando o nome do usuário, nome do canal, a quantidade total de transmissões, a média e o pico de espectadores que já tiveram, considerando apenas streamers com mais de uma transmissão e que tiveram um pico de mais de 80 espectadores. O relatório deve ser ordenado do maior pico para o menor.

```sql
-- CHECKLIST: SELECT-FROM-WHERE, INNER JOIN, MAX, MIN, AVG, COUNT, GROUP BY, HAVING, ORDER BY
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
```

### 1.3. Consultas com Filtros Específicos e Joins

#### Cenário: Listar todos os usuários, e para aqueles que são streamers, mostrar o nome do canal. Usuários que não são streamers também devem aparecer na lista.

```sql
-- CHECKLIST: LEFT ou RIGHT ou FULL OUTER JOIN
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
    C.nome_canal DESC; -- Deixa os não-streamers (NULL) no final
```

#### Cenário: Encontrar transmissões que aconteceram em Junho de 2025, de canais com "Jogo" no nome, e cujo status não seja nulo, limitado a canais específicos (ID 1 ou 2).

```sql
-- CHECKLIST: BETWEEN, IN, LIKE, IS NULL ou IS NOT NULL
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
```

### 1.4. Consultas com Subconsultas

#### Cenário: Encontrar os vídeos do canal mais antigo da plataforma.

```sql
-- CHECKLIST: SUBCONSULTA COM OPERADOR RELACIONAL (=)
SELECT
    titulo,
    duracao_data_upload
FROM
    Video
WHERE
    canal_id = (SELECT id_canal FROM Canal ORDER BY data_criacao_canal ASC FETCH FIRST 1 ROWS ONLY);
```

#### Cenário: Encontrar os nomes de todos os usuários que já assistiram a algum vídeo de um canal da categoria 'Música'.

```sql
-- CHECKLIST: SUBCONSULTA COM IN
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
```

#### Cenário: Encontrar canais que possuem pelo menos uma transmissão com mais espectadores que a média de QUALQUER canal. (Consulta mais complexa para demonstrar o ANY)

```sql
-- CHECKLIST: SUBCONSULTA COM ANY
SELECT nome_canal FROM Canal C
WHERE C.id_canal IN (
    SELECT T.canal_id FROM Transmissao T
    WHERE T.max_espectadores_simultaneos > ANY (
        SELECT AVG(T2.max_espectadores_simultaneos)
        FROM Transmissao T2
        GROUP BY T2.canal_id
    )
);
```

#### Cenário: Encontrar o(s) streamer(s) cujo pico de espectadores é maior ou igual ao de TODOS os outros streamers.

```sql
-- CHECKLIST: SUBCONSULTA COM ALL
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
```

### 1.5. Operadores de Conjunto e Views

#### Cenário: Encontrar usuários que são streamers, mas não são espectadores.

```sql
-- CHECKLIST: UNION ou INTERSECT ou MINUS
SELECT cpf_streamer FROM Streamer
MINUS
SELECT cpf_espectador FROM Espectador;
```

#### Cenário: Criar uma visão para simplificar o acesso a informações detalhadas sobre streamers, combinando dados de 3 tabelas.

```sql
-- CHECKLIST: CREATE VIEW
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

-- Exemplo de uso da VIEW
SELECT * FROM V_INFO_STREAMERS WHERE nome_canal LIKE '%Bruno%';
```

### 1.6. Controle de Acesso (Conceitual)

#### Cenário: Conceder permissão de SELECT na view `V_INFO_STREAMERS` para um usuário "analista" e depois revogar.

```sql
-- CHECKLIST: GRANT / REVOKE
-- OBS: Estes comandos não funcionarão no Oracle Live SQL, são apenas para demonstração do conceito.

-- 1. O Administrador do Banco de Dados (DBA) concede a permissão:
GRANT SELECT ON V_INFO_STREAMERS TO analista;

-- 2. O DBA decide remover a permissão:
REVOKE SELECT ON V_INFO_STREAMERS FROM analista;
```

-----

## 2\. Código PL/SQL

Aqui estão os blocos PL/SQL, procedures, functions, packages e triggers que cobrem os 20 itens da checklist.

### 2.1. Procedure para Gerenciar Dados de Usuários

#### Cenário: Criar uma procedure que atualiza a descrição de um usuário, tratando exceções caso o usuário não exista.

```sql
-- CHECKLIST: CREATE PROCEDURE, USO DE PARÂMETROS (IN), %TYPE, SELECT ... INTO, IF ELSIF, EXCEPTION WHEN
CREATE OR REPLACE PROCEDURE prc_atualizar_descricao_usuario (
    p_cpf       IN Usuario.cpf%TYPE,
    p_nova_desc IN Usuario.descricao%TYPE
) IS
    v_count NUMBER;
BEGIN
    -- Verifica se o usuário existe
    SELECT COUNT(*) INTO v_count FROM Usuario WHERE cpf = p_cpf;

    IF v_count > 0 THEN
        UPDATE Usuario SET descricao = p_nova_desc WHERE cpf = p_cpf;
        DBMS_OUTPUT.PUT_LINE('Descrição do usuário ' || p_cpf || ' atualizada com sucesso.');
    ELSE
        -- Logicamente, este IF já previne o erro, mas o EXCEPTION é para garantir.
        DBMS_OUTPUT.PUT_LINE('Usuário com CPF ' || p_cpf || ' não encontrado.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Nenhum usuário encontrado com o CPF fornecido.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocorreu um erro inesperado: ' || SQLERRM);
END;
/
-- Exemplo de chamada do Procedure
BEGIN
    prc_atualizar_descricao_usuario('11122233344', 'Nova descrição definida via Procedure.');
END;
/
```

### 2.2. Function e Estruturas de Dados

#### Cenário: Criar uma função que retorna a contagem de inscritos de um canal e usar um bloco anônimo com uma estrutura de dados do tipo TABLE para listar todas as categorias.

```sql
-- CHECKLIST: CREATE FUNCTION
CREATE OR REPLACE FUNCTION fnc_contar_assinantes (
    p_id_canal IN Canal.id_canal%TYPE
) RETURN NUMBER IS
    v_total_assinantes NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_assinantes FROM Assina WHERE canal_id = p_id_canal;
    RETURN v_total_assinantes;
END;
/

-- CHECKLIST: BLOCO ANÔNIMO, USO DE ESTRUTURA DE DADOS DO TIPO TABLE, FOR IN LOOP
DECLARE
    -- Definindo um tipo de coleção (tabela de strings)
    TYPE t_lista_categorias IS TABLE OF Categoria.nome_categoria%TYPE INDEX BY PLS_INTEGER;
    v_categorias t_lista_categorias;
BEGIN
    -- Populando a coleção com os nomes das categorias
    SELECT nome_categoria BULK COLLECT INTO v_categorias FROM Categoria;

    DBMS_OUTPUT.PUT_LINE('--- Lista de Categorias na Plataforma ---');
    -- Usando FOR IN LOOP para iterar sobre a coleção
    FOR i IN 1..v_categorias.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('- ' || v_categorias(i));
    END LOOP;
END;
/
```

### 2.3. Cursor, Record e Loops

#### Cenário: Criar um bloco anônimo que usa um cursor para buscar todos os vídeos de um determinado canal, armazenando cada linha em um record, e imprimindo o título de cada um.

```sql
-- CHECKLIST: CURSOR (OPEN, FETCH e CLOSE), USO DE RECORD, %ROWTYPE, LOOP EXIT WHEN
DECLARE
    -- Definindo um record customizado para o vídeo.
    TYPE rec_video_info IS RECORD (
        titulo_video Video.titulo%TYPE,
        data_upload  Video.duracao_data_upload%TYPE
    );
    v_video_rec rec_video_info;

    -- Alternativa mais comum com %ROWTYPE
    -- v_video_rowtype Video%ROWTYPE;

    -- Declarando o cursor
    CURSOR c_videos_canal (p_canal_id Canal.id_canal%TYPE) IS
        SELECT titulo, duracao_data_upload FROM Video WHERE canal_id = p_canal_id;

BEGIN
    -- Abrindo o cursor para o canal de ID 1
    OPEN c_videos_canal(1);

    LOOP
        -- Buscando a próxima linha do cursor para o record
        FETCH c_videos_canal INTO v_video_rec;
        -- Saindo do loop quando não houver mais linhas
        EXIT WHEN c_videos_canal%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Vídeo encontrado: ' || v_video_rec.titulo_video || ' (Enviado em: ' || TO_CHAR(v_video_rec.data_upload, 'DD/MM/YYYY') || ')');
    END LOOP;

    -- Fechando o cursor
    CLOSE c_videos_canal;
END;
/
```

### 2.4. Package para Agrupar Rotinas

#### Cenário: Criar um package que encapsula a função `fnc_contar_assinantes` e adiciona uma procedure para alterar o nome de um canal, demonstrando parâmetros IN e OUT.

```sql
-- CHECKLIST: CREATE OR REPLACE PACKAGE, CREATE OR REPLACE PACKAGE BODY, USO DE PARÂMETROS (OUT ou IN OUT)

-- 1. Especificação do Package
CREATE OR REPLACE PACKAGE pkg_gerenciamento_canal AS

    FUNCTION fnc_contar_assinantes (
        p_id_canal IN Canal.id_canal%TYPE
    ) RETURN NUMBER;

    PROCEDURE prc_obter_info_canal (
        p_id_canal   IN  Canal.id_canal%TYPE,
        p_nome_canal OUT Canal.nome_canal%TYPE,
        p_data_criacao OUT Canal.data_criacao_canal%TYPE
    );

END pkg_gerenciamento_canal;
/

-- 2. Corpo do Package
CREATE OR REPLACE PACKAGE BODY pkg_gerenciamento_canal AS

    -- Implementação da função já criada
    FUNCTION fnc_contar_assinantes (
        p_id_canal IN Canal.id_canal%TYPE
    ) RETURN NUMBER IS
        v_total_assinantes NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total_assinantes FROM Assina WHERE canal_id = p_id_canal;
        RETURN v_total_assinantes;
    END;

    -- Implementação da procedure com parâmetros OUT
    PROCEDURE prc_obter_info_canal (
        p_id_canal   IN  Canal.id_canal%TYPE,
        p_nome_canal OUT Canal.nome_canal%TYPE,
        p_data_criacao OUT Canal.data_criacao_canal%TYPE
    ) IS
    BEGIN
        SELECT nome_canal, data_criacao_canal
        INTO p_nome_canal, p_data_criacao
        FROM Canal
        WHERE id_canal = p_id_canal;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_nome_canal := 'CANAL INEXISTENTE';
            p_data_criacao := NULL;
    END;

END pkg_gerenciamento_canal;
/
```

### 2.5. Triggers de Auditoria e Controle

#### Cenário: Criar uma tabela de log. Depois, um trigger de linha que audita mudanças no nome do canal e um trigger de comando que impede a criação de novos canais aos finais de semana.

```sql
-- Primeiro, criamos a tabela de log
CREATE TABLE log_mudancas_canal (
    id_log         NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    id_canal       NUMBER,
    nome_antigo    VARCHAR2(255),
    nome_novo      VARCHAR2(255),
    data_mudanca   TIMESTAMP,
    usuario_db     VARCHAR2(100)
);

-- CHECKLIST: CREATE OR REPLACE TRIGGER (LINHA), WHILE LOOP (exemplo didático), CASE WHEN
CREATE OR REPLACE TRIGGER trg_audita_nome_canal
BEFORE UPDATE OF nome_canal ON Canal
FOR EACH ROW
DECLARE
    v_iterador NUMBER := 0;
BEGIN
    -- Exemplo didático de WHILE LOOP e CASE para alguma lógica
    WHILE v_iterador < 1 LOOP
        CASE
            WHEN :OLD.nome_canal != :NEW.nome_canal THEN
                INSERT INTO log_mudancas_canal (id_canal, nome_antigo, nome_novo, data_mudanca, usuario_db)
                VALUES (:OLD.id_canal, :OLD.nome_canal, :NEW.nome_canal, SYSTIMESTAMP, USER);
            ELSE
                NULL; -- Nenhuma ação se o nome não mudou
        END CASE;
        v_iterador := v_iterador + 1;
    END LOOP;
END;
/

-- CHECKLIST: CREATE OR REPLACE TRIGGER (COMANDO)
CREATE OR REPLACE TRIGGER trg_impede_canal_fim_semana
BEFORE INSERT ON Canal
BEGIN
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Criação de novos canais não é permitida aos finais de semana.');
    END IF;
END;
/
```