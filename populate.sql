INSERT INTO CEP_INFO (cep, rua, bairro, cidade, estado) VALUES ('50740530', 'Rua General Polidoro', 'Várzea', 'Recife', 'PE');
INSERT INTO CEP_INFO (cep, rua, bairro, cidade, estado) VALUES ('01311000', 'Avenida Paulista', 'Bela Vista', 'São Paulo', 'SP');

INSERT INTO Usuario (cpf, email, nome, descricao, cep, numero_endereco) VALUES ('11122233344', 'ana.silva@email.com', 'Ana Silva', 'Gosto de jogos de estratégia.', '50740530', '123');
INSERT INTO Usuario (cpf, email, nome, descricao, cep, numero_endereco) VALUES ('55566677788', 'bruno.costa@email.com', 'Bruno Costa', 'Streamer e desenvolvedor.', '01311000', '456A');
INSERT INTO Usuario (cpf, email, nome, descricao, cep, numero_endereco) VALUES ('99988877766', 'carla.dias@email.com', 'Carla Dias', 'Acompanho lives de música.', '50740530', '789');
INSERT INTO Usuario (cpf, email, nome, descricao, cep, numero_endereco) VALUES ('12345678900', 'daniel.santos@email.com', 'Daniel Santos', 'Espectador casual.', '01311000', '100');

INSERT INTO Dados_Bancarios (usuario_cpf, banco, agencia, conta) VALUES ('11122233344', 'Banco do Brasil', '1234-5', '123456-7');
INSERT INTO Dados_Bancarios (usuario_cpf, banco, agencia, conta) VALUES ('55566677788', 'Itaú Unibanco', '5678-9', '987654-3');

INSERT INTO Telefone (usuario_cpf, telefone) VALUES ('11122233344', '81999998888');
INSERT INTO Telefone (usuario_cpf, telefone) VALUES ('55566677788', '11988887777');
INSERT INTO Telefone (usuario_cpf, telefone) VALUES ('55566677788', '11977776666');
INSERT INTO Telefone (usuario_cpf, telefone) VALUES ('99988877766', '81966665555');

INSERT INTO Categoria (nome_categoria, descricao_categoria) VALUES ('Jogos', 'Transmissões de gameplays e e-sports.');
INSERT INTO Categoria (nome_categoria, descricao_categoria) VALUES ('Música', 'Shows, produção musical e conversas sobre música.');
INSERT INTO Categoria (nome_categoria, descricao_categoria) VALUES ('Só na Conversa', 'Bate-papo com os espectadores.');

INSERT INTO Canal (nome_canal, data_criacao_canal, descricao_canal) VALUES ('Canal do Bruno', TO_DATE('2022-01-15', 'YYYY-MM-DD'), 'Canal focado em desenvolvimento de jogos e gameplay.');
INSERT INTO Canal (nome_canal, data_criacao_canal, descricao_canal) VALUES ('Ana Joga', TO_DATE('2023-03-20', 'YYYY-MM-DD'), 'Noites de jogos estratégicos e interação.');

INSERT INTO Espectador (cpf_espectador) VALUES ('11122233344');
INSERT INTO Espectador (cpf_espectador) VALUES ('99988877766');
INSERT INTO Espectador (cpf_espectador) VALUES ('12345678900');

INSERT INTO Streamer (cpf_streamer, id_canal) VALUES ('55566677788', 1);
INSERT INTO Streamer (cpf_streamer, id_canal) VALUES ('11122233344', 2);

INSERT INTO Tem_Categoria (canal_id, categoria_id) VALUES (1, 1);
INSERT INTO Tem_Categoria (canal_id, categoria_id) VALUES (1, 3);
INSERT INTO Tem_Categoria (canal_id, categoria_id) VALUES (2, 1);

INSERT INTO Transmissao (titulo, status, data_hora_inicio, data_hora_termino, canal_id, max_espectadores_simultaneos) VALUES ('Desenvolvendo um Jogo 2D', 'Finalizada', TO_TIMESTAMP('2025-06-20 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-06-20 23:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 150);
INSERT INTO Transmissao (titulo, status, data_hora_inicio, data_hora_termino, canal_id, max_espectadores_simultaneos) VALUES ('Noite de Xadrez', 'Ao Vivo', TO_TIMESTAMP('2025-06-25 21:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, 2, 80);

INSERT INTO Video (titulo, descricao, duracao_data_upload, canal_id) VALUES ('Melhores Momentos de Junho', 'Compilado das lives de Junho.', TO_DATE('2025-06-22', 'YYYY-MM-DD'), 1);
INSERT INTO Video (titulo, descricao, duracao_data_upload, canal_id) VALUES ('Tutorial de Estratégia', 'Dicas para iniciantes.', TO_DATE('2025-05-10', 'YYYY-MM-DD'), 2);

INSERT INTO Segue (usuario_cpf, canal_id) VALUES ('99988877766', 1);
INSERT INTO Segue (usuario_cpf, canal_id) VALUES ('12345678900', 1);
INSERT INTO Segue (usuario_cpf, canal_id) VALUES ('55566677788', 2);

INSERT INTO Assina (usuario_cpf, canal_id, nivel_assinatura, data_inicio, data_fim) VALUES ('99988877766', 1, 'Premium', TO_DATE('2025-01-01', 'YYYY-MM-DD'), NULL);

INSERT INTO Acompanha (usuario_cpf, transmissao_id) VALUES ('99988877766', 1);
INSERT INTO Acompanha (usuario_cpf, transmissao_id) VALUES ('12345678900', 2);

INSERT INTO Assiste (usuario_cpf, video_id, data_assistido) VALUES ('12345678900', 1, TO_TIMESTAMP('2025-06-23 15:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Assiste (usuario_cpf, video_id, data_assistido) VALUES ('11122233344', 1, TO_TIMESTAMP('2025-06-24 18:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Indica (indicador_cpf, indicado_cpf, data_indicacao, comentario) VALUES ('11122233344', '99988877766', TO_DATE('2025-04-10', 'YYYY-MM-DD'), 'Vem assistir as lives dela!');

INSERT INTO Clipe (usuario_cpf, id_transmissao, data_criacao_clipe, titulo_clipe, tempo_clipe) VALUES ('99988877766', 1, TO_TIMESTAMP('2025-06-20 21:30:15', 'YYYY-MM-DD HH24:MI:SS'), 'Bug Engraçado!', 45);

INSERT INTO Avalia (espectador_cpf, transmissao_id, nota, comentario) VALUES ('99988877766', 1, 5, 'Live muito produtiva, aprendi bastante!');