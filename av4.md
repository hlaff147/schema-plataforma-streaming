## 1\. Consultas SQL

Aqui estão as consultas que cobrem os 26 itens da checklist de SQL.

### 1.1. Manutenção de Tabelas e Dados (DML e DDL)

#### Cenário: Adicionar uma coluna de data de nascimento, criar um índice, inserir dados de CEP/usuário/canal e depois atualizar/deletar dados específicos.

```sql
-- Adicionando uma coluna para armazenar a data de nascimento do usuário.
[cite_start]-- CHECKLIST: ALTER TABLE [cite: 6]
ALTER TABLE Usuario ADD data_nascimento DATE;

-- Criando um índice no nome do canal para otimizar buscas por nome.
[cite_start]-- CHECKLIST: CREATE INDEX [cite: 6]
CREATE INDEX idx_canal_nome ON Canal(nome_canal);

-- Inserindo dados de CEP, um novo usuário e um novo canal para os testes seguintes.
[cite_start]-- CHECKLIST: INSERT INTO [cite: 6]
INSERT INTO CEP_INFO (cep, rua, bairro, cidade, estado) VALUES ('50740530', 'Rua Acadêmico Hélio Ramos', 'Várzea', 'Recife', 'PE');
INSERT INTO Usuario (cpf, email, nome, descricao, cep, numero_endereco, data_nascimento) VALUES ('12121212121', 'novo.usuario@email.com', 'Usuario Teste', 'Um novo usuário para testes.', '50740530', '999', TO_DATE('2000-10-15', 'YYYY-MM-DD'));
INSERT INTO Canal (nome_canal, data_criacao_canal, descricao_canal) VALUES ('Canal Teste Delete', SYSDATE, 'Canal para ser deletado');

-- O novo usuário decidiu mudar sua descrição.
[cite_start]-- CHECKLIST: UPDATE [cite: 6]
UPDATE Usuario
SET descricao = 'Descrição atualizada após o cadastro.'
WHERE cpf = '12121212121';

-- Deletando o canal de teste que foi criado para a demonstração.
[cite_start]-- CHECKLIST: DELETE [cite: 6]
DELETE FROM Canal
WHERE nome_canal = 'Canal Teste Delete';
```

### 1.2. Consulta Complexa de Análise de Streamers

#### Cenário: Gerar um relatório com os streamers mais populares, mostrando o nome do usuário, nome do canal, a quantidade total de transmissões, a média e o pico de espectadores que já tiveram, considerando apenas streamers com mais de uma transmissão e que tiveram um pico de mais de 80 espectadores. O relatório deve ser ordenado do maior pico para o menor.

```sql
[cite_start]-- CHECKLIST: SELECT-FROM-WHERE [cite: 6][cite_start], INNER JOIN [cite: 6][cite_start], MAX [cite: 6][cite_start], MIN [cite: 6][cite_start], AVG [cite: 6][cite_start], COUNT [cite: 6][cite_start], GROUP BY [cite: 6][cite_start], HAVING [cite: 6][cite_start], ORDER BY [cite: 6]
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
[cite_start]-- CHECKLIST: LEFT ou RIGHT ou FULL OUTER JOIN [cite: 6]
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
```

#### Cenário: Encontrar transmissões que aconteceram em Junho de 2025, de canais com "Jogo" no nome, e cujo status não seja nulo, limitado a canais específicos (ID 1 ou 2).

```sql
[cite_start]-- CHECKLIST: BETWEEN [cite: 6][cite_start], IN [cite: 6][cite_start], LIKE [cite: 6][cite_start], IS NULL ou IS NOT NULL [cite: 6]
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
[cite_start]-- CHECKLIST: SUBCONSULTA COM OPERADOR RELACIONAL (=) [cite: 6]
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
[cite_start]-- CHECKLIST: SUBCONSULTA COM IN [cite: 6]
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

#### Cenário: Encontrar canais que possuem pelo menos uma transmissão com mais espectadores que a média de QUALQUER outro canal.

```sql
[cite_start]-- CHECKLIST: SUBCONSULTA COM ANY [cite: 6]
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
```

#### Cenário: Encontrar o(s) streamer(s) cujo pico de espectadores é maior ou igual ao de TODAS as transmissões.

```sql
[cite_start]-- CHECKLIST: SUBCONSULTA COM ALL [cite: 6]
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
[cite_start]-- CHECKLIST: UNION ou INTERSECT ou MINUS [cite: 6]
SELECT cpf_streamer FROM Streamer
MINUS
SELECT cpf_espectador FROM Espectador;
```

#### Cenário: Criar uma visão para simplificar o acesso a informações detalhadas sobre streamers, combinando dados de 3 tabelas.

```sql
[cite_start]-- CHECKLIST: CREATE VIEW [cite: 6]
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
```

### 1.6. Controle de Acesso (Conceitual)

#### Cenário: Conceder permissão de SELECT na view `V_INFO_STREAMERS` para um usuário "analista" e depois revogar.

```sql
[cite_start]-- CHECKLIST: GRANT / REVOKE [cite: 6]
-- (Estes comandos são conceituais e devem ser executados por um DBA)
-- GRANT SELECT ON V_INFO_STREAMERS TO analista;
-- REVOKE SELECT ON V_INFO_STREAMERS FROM analista;
```

-----

## 2\. Código PL/SQL

Aqui estão os blocos PL/SQL, procedures, functions, packages e triggers que cobrem os 20 itens da checklist.

### 2.1. Procedure para Gerenciar Dados de Usuários

#### Cenário: Criar uma procedure que atualiza a descrição de um usuário, tratando exceções caso o usuário não exista.

```sql
[cite_start]-- CHECKLIST: CREATE PROCEDURE [cite: 12][cite_start], USO DE PARÂMETROS (IN) [cite: 12][cite_start], %TYPE [cite: 12][cite_start], SELECT ... INTO [cite: 12][cite_start], IF ELSIF [cite: 12][cite_start], EXCEPTION WHEN [cite: 12]
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
```

### 2.2. Function e Estruturas de Dados

#### Cenário: Criar uma função que retorna a contagem de inscritos de um canal e usar um bloco anônimo com uma estrutura de dados do tipo TABLE para listar todas as categorias.

```sql
[cite_start]-- CHECKLIST: CREATE FUNCTION [cite: 12]
CREATE OR REPLACE FUNCTION fnc_contar_assinantes (
    p_id_canal IN Canal.id_canal%TYPE
) RETURN NUMBER IS
    v_total_assinantes NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_assinantes FROM Assina WHERE canal_id = p_id_canal;
    RETURN v_total_assinantes;
END;
/

[cite_start]-- CHECKLIST: BLOCO ANÔNIMO [cite: 12][cite_start], USO DE ESTRUTURA DE DADOS DO TIPO TABLE [cite: 12][cite_start], FOR IN LOOP [cite: 12]
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
```

### 2.3. Cursor, Record e Loops

#### Cenário: Criar um bloco anônimo que usa um cursor para buscar todos os vídeos de um determinado canal, armazenando cada linha em uma variável do tipo %ROWTYPE, e imprimindo o título de cada um.

```sql
[cite_start]-- CHECKLIST: CURSOR (OPEN, FETCH e CLOSE) [cite: 12][cite_start], USO DE RECORD [cite: 12][cite_start], %ROWTYPE [cite: 12][cite_start], LOOP EXIT WHEN [cite: 12]
DECLARE
    [cite_start]-- 7. Uso de %ROWTYPE para representar uma linha da tabela Video [cite: 12]
    v_video_rowtype Video%ROWTYPE;
    [cite_start]-- 14. Declarando o cursor [cite: 12]
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
```

### 2.4. Package para Agrupar Rotinas

#### Cenário: Criar um package que encapsula a lógica de gerenciamento de canais.

```sql
[cite_start]-- CHECKLIST: CREATE OR REPLACE PACKAGE [cite: 12][cite_start], CREATE OR REPLACE PACKAGE BODY [cite: 12][cite_start], USO DE PARÂMETROS (OUT ou IN OUT) [cite: 12]

[cite_start]-- 1. Especificação do Package [cite: 12]
CREATE OR REPLACE PACKAGE pkg_gerenciamento_canal AS
    FUNCTION fnc_contar_assinantes (p_id_canal IN Canal.id_canal%TYPE) RETURN NUMBER;
    PROCEDURE prc_obter_info_canal (
        p_id_canal     IN  Canal.id_canal%TYPE,
        p_nome_canal   OUT Canal.nome_canal%TYPE,
        p_data_criacao OUT Canal.data_criacao_canal%TYPE
    );
END pkg_gerenciamento_canal;
/
[cite_start]-- 2. Corpo do Package [cite: 12]
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
```

### 2.5. Triggers de Auditoria e Controle

#### Cenário: Criar uma tabela de log e um trigger de linha que audita mudanças no nome do canal, além de um trigger de comando que impede a criação de canais aos finais de semana.

```sql
-- Primeiro, criamos a tabela de log
CREATE TABLE log_mudancas_canal (
    id_log        NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    id_canal      NUMBER,
    nome_antigo   VARCHAR2(255),
    nome_novo     VARCHAR2(255),
    data_mudanca  TIMESTAMP,
    usuario_db    VARCHAR2(100)
);

[cite_start]-- CHECKLIST: CREATE OR REPLACE TRIGGER (LINHA) [cite: 12][cite_start], WHILE LOOP [cite: 12] [cite_start](exemplo didático), CASE WHEN [cite: 12]
CREATE OR REPLACE TRIGGER trg_audita_nome_canal
BEFORE UPDATE OF nome_canal ON Canal
FOR EACH ROW
DECLARE
    v_iterador NUMBER := 0; -- Apenas para exemplo de loop
BEGIN
    [cite_start]-- Exemplo didático de WHILE LOOP [cite: 12]
    WHILE v_iterador < 1 LOOP
        [cite_start]-- Uso de CASE WHEN [cite: 12]
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

[cite_start]-- CHECKLIST: CREATE OR REPLACE TRIGGER (COMANDO) [cite: 12]
CREATE OR REPLACE TRIGGER trg_impede_canal_fim_semana
BEFORE INSERT ON Canal
BEGIN
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Criação de novos canais não é permitida aos finais de semana.');
    END IF;
END;
/
```