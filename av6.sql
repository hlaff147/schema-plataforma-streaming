-- Consulta básica de todos os canais
SELECT c.nome_canal, c.data_criacao, c.descricao, c.categoria
FROM tb_canais c;

-- Consulta básica de todos os usuários
SELECT u.cpf, u.nome, u.email, u.data_nascimento
FROM tb_usuarios u;

-- SELECT REF: Obtendo referências aos canais
SELECT REF(c) AS referencia_canal, c.nome_canal
FROM tb_canais c;

-- SELECT DEREF: Acessando objetos referenciados
SELECT u.nome, DEREF(u.canal).nome_canal AS canal_associado
FROM tb_usuarios u
WHERE VALUE(u) IS OF (tp_streamer);

-- Consulta mais complexa com REF e DEREF
SELECT s.nome, 
       DEREF(s.canal).nome_canal AS canal,
       (SELECT COUNT(*) FROM TABLE(DEREF(s.canal).videos)) AS total_videos
FROM tb_usuarios s
WHERE VALUE(s) IS OF (tp_streamer);

-- Consulta ao VARRAY de telefones
SELECT u.nome, t.COLUMN_VALUE AS telefone
FROM tb_usuarios u, TABLE(u.telefones) t;

-- Contagem de telefones por usuário
SELECT u.nome, COUNT(t.COLUMN_VALUE) AS quantidade_telefones
FROM tb_usuarios u, TABLE(u.telefones) t
GROUP BY u.nome;

-- Usuários com mais de 1 telefone
SELECT u.nome, LISTAGG(t.COLUMN_VALUE, ', ') WITHIN GROUP (ORDER BY t.COLUMN_VALUE) AS telefones
FROM tb_usuarios u, TABLE(u.telefones) t
GROUP BY u.nome
HAVING COUNT(t.COLUMN_VALUE) > 1;

-- Consulta à NESTED TABLE de vídeos
SELECT c.nome_canal, v.titulo, v.duracao_min, v.data_upload
FROM tb_canais c, TABLE(c.videos) v;

-- Vídeos com mais de 100 minutos de duração
SELECT c.nome_canal, v.titulo, v.duracao_min
FROM tb_canais c, TABLE(c.videos) v
WHERE v.duracao_min > 100;

-- Total de minutos de vídeo por canal
SELECT c.nome_canal, SUM(v.duracao_min) AS total_minutos
FROM tb_canais c, TABLE(c.videos) v
GROUP BY c.nome_canal;

-- Média de duração dos vídeos por canal
SELECT c.nome_canal, AVG(v.duracao_min) AS media_duracao
FROM tb_canais c, TABLE(c.videos) v
GROUP BY c.nome_canal;

-- Testando a função get_idade()
SELECT u.nome, u.data_nascimento, u.get_idade() AS idade
FROM tb_usuarios u;

-- Testando a função detalhes() polimórfica
SELECT u.nome, 
       CASE
           WHEN VALUE(u) IS OF (tp_espectador) THEN TREAT(VALUE(u) AS tp_espectador).detalhes()
           WHEN VALUE(u) IS OF (tp_streamer) THEN TREAT(VALUE(u) AS tp_streamer).detalhes()
           ELSE 'Tipo desconhecido'
       END AS detalhes
FROM tb_usuarios u;

-- Testando a função comparar() em tp_video
SELECT v1.titulo, v1.duracao_min, v2.titulo, v2.duracao_min,
       v1.comparar(v2) AS comparacao
FROM TABLE((SELECT videos FROM tb_canais WHERE nome_canal = 'Canal do Bruno')) v1,
     TABLE((SELECT videos FROM tb_canais WHERE nome_canal = 'Ana Joga')) v2
WHERE ROWNUM <= 1;

-- Testando a função ordenar_por_data() em tp_canal_base
SELECT c.nome_canal, c.data_criacao, c.ordenar_por_data() AS valor_ordenacao
FROM tb_canais c;

-- Testando o procedimento adicionar_video
DECLARE
    v_canal REF tp_canal_base;
    v_canal_obj tp_canal_base;
BEGIN
    -- Seleciona o canal "Ana Joga"
    SELECT REF(c) INTO v_canal FROM tb_canais c WHERE c.nome_canal = 'Ana Joga';
    
    -- Obtém o objeto canal
    SELECT DEREF(v_canal) INTO v_canal_obj FROM DUAL;
    
    -- Adiciona um novo vídeo
    v_canal_obj.adicionar_video('Novo Vídeo Teste', 45);
    
    -- Atualiza os vídeos no banco de dados
    UPDATE tb_canais SET videos = v_canal_obj.videos WHERE REF(tb_canais) = v_canal;
    
    COMMIT;
END;
/

-- Verificando o vídeo adicionado
SELECT c.nome_canal, v.titulo, v.duracao_min
FROM tb_canais c, TABLE(c.videos) v
WHERE c.nome_canal = 'Ana Joga';

-- Usando TREAT para acessar atributos específicos de subtipos
SELECT TREAT(VALUE(u) AS tp_espectador).data_cadastro AS data_cadastro_espectador
FROM tb_usuarios u
WHERE VALUE(u) IS OF (tp_espectador);

-- Usando IS OF para filtrar por tipo
SELECT u.nome,
       CASE
           WHEN VALUE(u) IS OF (ONLY tp_espectador) THEN 'Espectador'
           WHEN VALUE(u) IS OF (ONLY tp_streamer) THEN 'Streamer'
           ELSE 'Tipo desconhecido'
       END AS tipo_usuario
FROM tb_usuarios u;

-- Consulta complexa com TREAT e DEREF
SELECT s.nome, 
       DEREF(TREAT(VALUE(s) AS tp_streamer).canal).nome_canal AS canal,
       TREAT(VALUE(s) AS tp_streamer).dados_bancarios AS dados_bancarios
FROM tb_usuarios s
WHERE VALUE(s) IS OF (tp_streamer);

-- Ordenando canais usando MAP MEMBER FUNCTION ordenar_por_data
SELECT c.nome_canal, c.data_criacao
FROM tb_canais c
ORDER BY c;

-- Ordenando vídeos usando ORDER MEMBER FUNCTION comparar
SELECT v.titulo, v.duracao_min
FROM TABLE((SELECT videos FROM tb_canais WHERE nome_canal = 'Canal do Bruno')) v
ORDER BY v;

-- Acessando atributos do tipo endereço
SELECT u.nome, 
       u.endereco.rua, 
       u.endereco.bairro, 
       u.endereco.cidade, 
       u.endereco.estado
FROM tb_usuarios u;

-- Usuários de Recife
SELECT u.nome, u.endereco.cidade
FROM tb_usuarios u
WHERE u.endereco.cidade = 'Recife';

-- Contagem de usuários por estado
SELECT u.endereco.estado, COUNT(*) AS total_usuarios
FROM tb_usuarios u
GROUP BY u.endereco.estado;

-- Streamers com seus canais e total de vídeos
SELECT s.nome AS streamer, 
       DEREF(s.canal).nome_canal AS canal,
       (SELECT COUNT(*) FROM TABLE(DEREF(s.canal).videos)) AS total_videos,
       (SELECT SUM(v.duracao_min) FROM TABLE(DEREF(s.canal).videos) v) AS total_minutos
FROM tb_usuarios s
WHERE VALUE(s) IS OF (tp_streamer);

-- Relatório completo de vídeos por canal
SELECT c.nome_canal, 
       COUNT(v.titulo) AS total_videos,
       AVG(v.duracao_min) AS media_duracao,
       MIN(v.data_upload) AS primeiro_upload,
       MAX(v.data_upload) AS ultimo_upload
FROM tb_canais c, TABLE(c.videos) v
GROUP BY c.nome_canal;

-- Usuários com idade superior a 25 anos
SELECT u.nome, u.get_idade() AS idade
FROM tb_usuarios u
WHERE u.get_idade() > 25
ORDER BY idade DESC;

-- Primeiro, vamos implementar o corpo da função eh_popular
CREATE OR REPLACE TYPE BODY tp_canal_base AS
    -- ... (manter implementações existentes)
    
    MEMBER FUNCTION eh_popular RETURN VARCHAR2 IS
        v_total_videos NUMBER;
        v_total_minutos NUMBER;
    BEGIN
        SELECT COUNT(*), SUM(v.duracao_min) 
        INTO v_total_videos, v_total_minutos
        FROM TABLE(self.videos) v;
        
        IF v_total_videos > 1 AND v_total_minutos > 100 THEN
            RETURN 'Popular';
        ELSE
            RETURN 'Não Popular';
        END IF;
    END;
END;
/

-- Agora testando a função
SELECT c.nome_canal, c.eh_popular() AS status_popularidade
FROM tb_canais c;

-- Canais com mais vídeos que a média
SELECT c.nome_canal, COUNT(v.titulo) AS total_videos
FROM tb_canais c, TABLE(c.videos) v
GROUP BY c.nome_canal
HAVING COUNT(v.titulo) > (
    SELECT AVG(COUNT(v2.titulo))
    FROM tb_canais c2, TABLE(c2.videos) v2
    GROUP BY c2.nome_canal
);

-- Streamers mais jovens que a média de idade dos espectadores
SELECT s.nome, s.get_idade() AS idade
FROM tb_usuarios s
WHERE VALUE(s) IS OF (tp_streamer)
AND s.get_idade() < (
    SELECT AVG(e.get_idade())
    FROM tb_usuarios e
    WHERE VALUE(e) IS OF (tp_espectador)
);

-- Todos os vídeos de todos os canais (UNION ALL implícito)
SELECT c.nome_canal, v.titulo
FROM tb_canais c, TABLE(c.videos) v;

-- Títulos de vídeos que aparecem em mais de um canal (não aplicável neste caso)
-- (Exemplo ilustrativo apenas)
SELECT v.titulo, COUNT(DISTINCT c.nome_canal) AS qtd_canais
FROM tb_canais c, TABLE(c.videos) v
GROUP BY v.titulo
HAVING COUNT(DISTINCT c.nome_canal) > 1;

-- Rank de vídeos por duração em cada canal
SELECT c.nome_canal, v.titulo, v.duracao_min,
       RANK() OVER (PARTITION BY c.nome_canal ORDER BY v.duracao_min DESC) AS rank_duracao
FROM tb_canais c, TABLE(c.videos) v;

-- Diferença de duração em relação à média do canal
SELECT c.nome_canal, v.titulo, v.duracao_min,
       v.duracao_min - AVG(v.duracao_min) OVER (PARTITION BY c.nome_canal) AS diff_media
FROM tb_canais c, TABLE(c.videos) v;

